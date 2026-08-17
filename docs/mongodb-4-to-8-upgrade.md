# Upgrading la-toolkit past MongoDB 4

la-toolkit 1.7.0 ships MongoDB 8. Installations that have been running since 1.6.9
or earlier are on MongoDB 4, and **MongoDB 8 will not start on MongoDB 4 data
files**. This note is the upgrade path.

It should take about ten minutes. The database is small — it holds your projects
and servers, not portal data. On a real installation the compressed dump is around
200 KB.

---

## Are you affected?

```bash
grep 'image: mongo' docker-compose.yml
```

- `mongo:8.x` — already done, nothing to do here.
- `mongo:4` — read on.

If you have already updated the compose file and started it, the symptom is
MongoDB restarting in a loop, usually with **exit code 62**:

```bash
docker compose logs mongo | tail -30
docker compose ps
```

la-toolkit itself will then park with a message on the console and stay up so you
can read it. Nothing is damaged at that point: MongoDB refuses to touch data files
from an older major rather than upgrade them silently.

---

## One warning before anything else

**Watchtower can start this upgrade for you.** Compose files up to 1.6.9 run
`livingatlases/la-toolkit:latest` alongside a `watchtower` container that polls
hourly and updates images on its own. That combination — a new toolkit against your
existing `mongo:4` — is not a tested one.

`latest` is deliberately *not* being moved to 1.7.0 for this reason, and the current
`docker-compose.yml` pins the image instead. But your own file is the one that
decides. If it still says `:latest` and you are not upgrading today, either stop
watchtower or pin it:

```yaml
  la-toolkit:
    image: livingatlases/la-toolkit:1.6.9   # instead of :latest
```

Note the tag spelling: the 1.7.0 image is published as `1.7.0` **and** `v1.7.0`,
while earlier releases carry only the `v` form (`v1.6.9`, `v1.6.8`, …).

---

## 1. Get a dump you have verified

> **Check the size before you trust it.** On at least one real installation the
> backup sidecar shipped with 1.6.9 had been writing **empty** archives for
> months, silently. Do not skip this.

The compose file runs a `mongo-db-backup` sidecar that dumps the database daily:

```bash
ls -lt /data/la-toolkit/backups | head
```

### If your files are named `mongo__mongo_*.tar.xz`

Then you are on the old sidecar (`tiredofit/mongodb-backup`) and **your backups
are very likely empty**. A healthy dump of this database is around 200 KB; an
empty one is 76 bytes:

```bash
ls -l /data/la-toolkit/backups/mongo__mongo_*.tar.xz
```

The giveaway is in the filename itself: `mongo__mongo_` has an empty slot where
the database name belongs, because that sidecar's configuration in 1.6.9 sets no
`DB_NAME` (nor `DB_AUTH`). Confirm it if you like — an empty archive lists nothing:

```bash
xz -dc /data/la-toolkit/backups/<one-of-them>.tar.xz | tar -tv
```

Fix it before upgrading anything. Replace just the backup service in your
`docker-compose.yml` with the current one — new image, and the two environment
variables that were missing:

```yaml
  mongo-db-backup:
    image: tiredofit/db-backup:latest
    container_name: la-toolkit-mongo-db-backup
    restart: always
    depends_on:
      mongo:
        condition: service_healthy
    environment:
      - DB_TYPE=mongodb
      - DB_HOST=mongo
      - DB_USER=la_toolkit_mongo_admin
      - DB_PASS=<your-mongo-admin-password>
      - DB_AUTH=admin
      - DB_NAME=la_toolkit
      - DEFAULT_BACKUP_INTERVAL=1440
      - DEFAULT_CLEAN_UP_TIME=8640
      - DEFAULT_CHECKSUM=TRUE
      - DEFAULT_CHECKSUM_TYPE=MD5
    volumes:
      - /data/la-toolkit/backups:/backup
```

This is safe to do while still on MongoDB 4: the new image carries modern
`mongodb-database-tools`, which support MongoDB 4.0 and up. Then take a dump and
**check the size**:

```bash
docker compose up -d mongo-db-backup
docker compose exec mongo-db-backup backup-now
ls -lt /data/la-toolkit/backups | head -3
```

Around 200 KB: good. 76 bytes or 0: stop and fix the credentials before going any
further — you do not have a backup.

### If your files are named `mongo_la_toolkit_mongo_*.archive.gz`

You are on the current sidecar and in good shape. These are **gzipped archives,
not dump directories** — it matters for the restore command below. A
`latest-mongo_la_toolkit_mongo` symlink points at the newest.

Check the date and the size of the newest one. If it is not recent, take a fresh
one:

```bash
docker compose exec mongo-db-backup backup-now
ls -lt /data/la-toolkit/backups | head -3
```

Around 200 KB is normal and correct. A file of 0 or 76 bytes is not — see above.

### Do not dump with the tools inside the mongo:4 container

It is tempting to run `docker compose exec mongo mongodump` instead. Don't, on
MongoDB 4. Those older images bundle the tools that shipped with the server
(pre-100, e.g. `mongodump 3.6`), which write the **legacy archive format**.
Restoring one of those with a current `mongorestore` is the one combination in
this whole procedure that can genuinely fail on you.

The sidecar avoids the problem because it carries its own modern
`mongodb-database-tools`, and those support MongoDB 4.0 and up. Verified on a
stock installation:

| Where | Tool version |
|---|---|
| `mongo-db-backup` sidecar | mongodump / mongorestore **100.9.4** |
| `mongo:8.0.17` image | mongorestore **100.14.0** |

Both are 100.x — one generation, one archive format — so a dump the sidecar took
while you were still on MongoDB 4 restores cleanly into MongoDB 8. That is why
the existing daily backups are usable as-is, and why the dump is worth taking
through the sidecar rather than the database container.

---

## 2. Move the old data aside, do not delete it

```bash
docker compose down
sudo mv /data/la-toolkit/mongo /data/la-toolkit/mongo.v4
sudo mkdir -p /data/la-toolkit/mongo
```

Keeping `mongo.v4` costs nothing and is what lets you go back. Delete it once you
have confirmed your projects are in the new instance, not before.

---

## 3. Start an empty MongoDB 8 and restore into it

Update `docker-compose.yml` to the current one (or just change the mongo image to
`mongo:8.0.17`), then bring up the database on its own first:

```bash
docker compose up -d mongo
docker compose logs -f mongo     # wait for "Waiting for connections"
```

Then restore, and **which command depends on the format you have**.

### From a `.archive.gz` (current sidecar)

These contain only the `la_toolkit` database, so they can go back wholesale:

```bash
docker compose cp /data/la-toolkit/backups/<your-dump>.archive.gz mongo:/tmp/restore.gz

docker compose exec mongo mongorestore \
  --username la_toolkit_mongo_admin --password '<your-mongo-admin-password>' \
  --authenticationDatabase admin \
  --gzip --archive=/tmp/restore.gz
```

### From a dump directory, or an old `.tar.xz` that turned out not to be empty

**Do not restore the whole thing.** Those dumps were taken with no database
filter, so alongside `la_toolkit/` they contain an `admin/` directory holding
`system.users.bson` — replaying it replaces the MongoDB accounts on the server,
and every service loses the credentials it was configured with. Restore the one
database you actually want:

```bash
# extract first if it is a .tar.xz
xz -dc /data/la-toolkit/backups/<your-dump>.tar.xz | tar -x -C /tmp/ladump

docker compose cp /tmp/ladump mongo:/tmp/ladump

docker compose exec mongo mongorestore \
  --username la_toolkit_mongo_admin --password '<your-mongo-admin-password>' \
  --authenticationDatabase admin \
  --nsInclude 'la_toolkit.*' /tmp/ladump
```

`--nsInclude` is the safety belt: whatever else the dump carries, only the
`la_toolkit` collections are written.

Then start everything:

```bash
docker compose up -d
```

---

## 4. What happens on that first start

la-toolkit runs its database migrations automatically when the container starts.
Two things are worth knowing.

**A failed migration does not stop the toolkit.** It logs a warning and starts the
app anyway, which is easy to miss. Check for it:

```bash
docker compose logs la-toolkit | grep -i -A3 migrat
```

**One migration in this release deletes data, by design, and cannot be undone.**
`service-deploy-type-and-dedup` backfills a `type` field that the model used to
drop silently, and then removes the duplicate service deploys that its absence
created. Those duplicates are the reason the toolkit could revert a version you
had picked in the UI back to whatever the imported inventory said — so the cleanup
is wanted. But it is a deletion, and its `down` step cannot restore them. That is
the whole reason step 1 comes first.

---

## 5. Verify before you clean up

In the toolkit UI:

- every project you had is listed
- open one and check its servers, its assigned services, and the versions you had
  selected

Then, and only then:

```bash
sudo rm -rf /data/la-toolkit/mongo.v4
```

---

## If you would rather upgrade the data files in place

Restoring a dump is recommended because this database is tiny. The alternative is
the official path — upgrade one major at a time, `4 → 5 → 6 → 7 → 8`, letting each
version convert the data files and setting the feature compatibility version at
each step. It is correct, and it is a lot of work for a few hundred KB of project
configuration.

<https://www.mongodb.com/docs/manual/release-notes/8.0-upgrade-standalone/>

## If you have no dump and cannot make one

Last resort: start clean and re-import. You lose deploy history and per-project
tuning done in the UI, but not your portals.

```bash
docker compose down
sudo rm -rf /data/la-toolkit/mongo/*
docker compose up -d
```

Then re-import each portal from its `.yo-rc.json` with the (+) button, and restore
your existing `*-local-passwords.ini` over the generated one so services keep their
current credentials.
