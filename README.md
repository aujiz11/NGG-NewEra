# NGG-NewEra

An independent modernization of the legacy Next Generation Gaming SA-MP gamemode for open.mp.

Original code belongs to its respective authors. This unofficial project is not affiliated with Next Generation Gaming, LLC. See the [original source](https://github.com/NextGenerationGamingLLC/SA-MP-Development) for attribution and applicable notices.

## Why this project exists

NGG-NewEra maintains and improves a gamemode that stopped receiving updates in 2017. Development focuses on:

- Supporting open.mp and updated libraries through a sampctl-managed environment.
- Fixing longstanding gameplay, command, loading and saving bugs.
- Improving performance and resource cleanup across timers, jobs and world entities.
- Protecting account credentials, player transactions and ownership transfers.
- Simplifying legacy code and organizing systems for easier maintenance.

The goal is to resolve nearly all identified legacy issues while preserving core gameplay and existing data. Completed fixes and improvements are documented in the [changelog](CHANGES.md).

## Requirements

- Install [sampctl](https://github.com/Southclaws/sampctl/blob/master/docs/install.md).
- [MariaDB](https://mariadb.org/download/) is recommended.

## Database setup

Create a database and a user with access to it, then import [database/ngrp.sql](database/ngrp.sql).

Update [scriptfiles/mysql.cfg](scriptfiles/mysql.cfg) with your connection settings:

```ini
HOST=127.0.0.1
PORT=3306
DB=ngrp
USER=ngrp
PASS=your_database_password
SERVER=1
BETASERVER=1
SHOPAUTOMATED=0
```

`SERVER` identifies the server instance. Use `BETASERVER=1` for testing or `0` for a normal server.
To enable a separate shop database, set `SHOPAUTOMATED=1` and configure `SHOST`, `SDB`, `SUSER` and `SPASS`.

## Build and run

Run these commands from the repository root:

```sh
sampctl ensure
sampctl build
sampctl run
```

The build produces `gamemodes/NGRP.amx`. Configure server settings under `runtime` in [pawn.json](pawn.json).