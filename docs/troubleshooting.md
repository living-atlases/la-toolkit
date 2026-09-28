# Troubleshooting la-toolkit

## Where to look

Startup errors show up if you run compose in the foreground, without `-d`:

```bash
docker compose up                 # or: docker compose --profile dev up
```

Runtime errors of the running toolkit are in its container logs:

```bash
docker logs la-toolkit
```

Errors in the web interface itself usually show up in the
[browser devtools console](https://developer.chrome.com/docs/devtools/open/).

If `la-toolkit` restarts continuously, open a shell in a container of the same image to
look around:

```bash
docker run -it --network=la-toolkit_default --entrypoint /bin/bash livingatlases/la-toolkit:<version> -s
```

Please [open an issue](https://github.com/living-atlases/la-toolkit/issues) with this
information if you hit a problem.

## A first start that failed has to be cleaned up before retrying

If the very first `docker compose up` failed and `la-toolkit` keeps restarting with
`MongoServerError: Authentication failed`, fixing the cause is not enough on its own.

The mongo entrypoint runs the scripts in `/docker-entrypoint-initdb.d/` (which is where
`mongo-init.sh` creates the toolkit's database user) **only against an empty data
directory**. A single failed first start therefore leaves `/data/la-toolkit/mongo`
initialized but without that user, and every retry reuses it.

Check whether the user is there:

```bash
docker compose exec mongo mongosh -u la_toolkit_user -p la_toolkit_changeme \
  --authenticationDatabase la_toolkit --quiet --eval 'db.getName()'
```

If it fails to authenticate, wipe the directory and start again:

```bash
docker compose down && sudo rm -rf /data/la-toolkit/mongo/* && docker compose up -d
```

**This destroys the database.** It is only the right move on an installation that
never came up in the first place. If you have projects in there, do not run it: take a
dump and follow [Upgrading past MongoDB 4](mongodb-4-to-8-upgrade.md) instead.
