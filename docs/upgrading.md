# Upgrading la-toolkit

The general procedure is in the [README](../README.md#upgrade-the-toolkit). This page
holds the notes that only apply to some versions, and how to restore a backup.

## Every installation: backups stopped on 2026-09-09

The backup sidecar in `docker-compose.yml` used `tiredofit/db-backup:latest`. That
project moved to `nfrastack/db-backup`, and on 2026-09-09 its `:latest` was replaced by
an image that only prints a deprecation notice. The `watchtower` container pulled it
within the hour, so on any installation with the shipped `docker-compose.yml` the
`la-toolkit-mongo-db-backup` container still shows as running but has written nothing
since. Check it:

```bash
docker inspect la-toolkit-mongo-db-backup --format '{{.Config.Image}}'
sudo ls -lt /data/la-toolkit/backups | head -3   # the newest backup and its date
```

If the image is `tiredofit/db-backup:latest`, or the newest backup is older than a day,
take the `mongo-db-backup` service from the current `docker-compose.yml` (pinned to
`nfrastack/db-backup:4.9.2`, same variables) into yours, and recreate only that
container:

```bash
docker compose up -d --no-deps mongo-db-backup
docker logs la-toolkit-mongo-db-backup | grep -i 'completed successfully'
```

It takes a backup right away and then one a day. Test one with the
[restore](#restoring-a-backup) into a scratch MongoDB before relying on it. The current
file also fixes the checksum setting (`DEFAULT_CHECKSUM=MD5`), which used to leave an
empty `*.gz.` file next to every backup.

## Coming from 1.6.9 or earlier

Read [Upgrading past MongoDB 4](mongodb-4-to-8-upgrade.md) first. 1.7.0 ships
MongoDB 8, which will not start on MongoDB 4 data files, so pulling the new image is
not enough on its own. That page also explains how to check whether the backup you are
counting on is real (the backup sidecar used until 1.6.9 has been found writing empty
archives), and which restore command matches your dump format, since restoring an
older dump wholesale replaces the MongoDB accounts on the server.

## Why `:latest` still points at 1.6.9

`:latest` stays on 1.6.9, on purpose, for the whole 1.7.x series.

1.7.x ships MongoDB 8 and existing installations are on MongoDB 4, which is a
migration only you can decide to run. Moving `latest` would hand that decision to the
`watchtower` container in `docker-compose.yml`, which polls hourly: every unpinned
1.6.9 installation would be upgraded within the hour, on its own, into a database that
will not start.

So `:latest` is frozen until the 1.6.x installations have had a chance to migrate.
**Pin the version you want.** Every 1.7.x image is published under both spellings,
`1.7.1` and `v1.7.1`, so either works.

## 1.7.0 to 1.7.1

If you are on 1.7.0 and hit the install failures fixed in 1.7.1 (MongoDB init failing
with `mongo: command not found`, or the toolkit looping on `Authentication failed`),
note that `mongo-init.sh` and `docker-compose.yml` are files from this repository, not
part of the image. Copying the current ones is enough for those two; only the fixes in
the toolkit's own interface need the new image.

## Upgrading to 1.1.x

- Copy the new `docker-compose.yml`, as it includes new images and configurations.
- Move your data to `/data/la-toolkit` and create an additional `/data/la-toolkit/mongo/`.
  If you want to use different directories, edit the volumes in your
  `docker-compose.yml` accordingly. You can also use symlinks.
- Change the mongo user and passwords before starting the container.
- Your projects' json configuration is migrated to mongo at startup. Check that
  `la-toolkit` starts correctly; if not, see [Troubleshooting](troubleshooting.md).

## Restoring a backup

Backups are written by the `mongo-db-backup` sidecar (see `docker-compose.yml`). The
restore command depends on the dump format, and one of them needs a filter: a dump
taken without one also carries the `admin` database, and restoring that replaces the
MongoDB accounts on the destination server, leaving every service with credentials
that no longer work.

```bash
# current sidecar: a gzipped archive holding only la_toolkit
mongorestore -u la_toolkit_mongo_admin -p '<pass>' --authenticationDatabase admin \
  --gzip --archive=mongo_la_toolkit_mongo_<date>.archive.gz

# an older dump directory: restore the one database, not everything in it
mongorestore -u la_toolkit_mongo_admin -p '<pass>' --authenticationDatabase admin \
  --nsInclude 'la_toolkit.*' <your-backup-directory>
```

See [Upgrading past MongoDB 4](mongodb-4-to-8-upgrade.md) for how to tell the formats
apart and how to verify a dump is not empty before relying on it.
