# NGG-NewEra

An independent, community-driven modernization project based on the legacy Next Generation Gaming SA-MP gamemode.

The project focuses on code architecture, maintainability, Pawn development practices, performance, security, and compatibility with open.mp.

**Disclaimer:** This is an unofficial community project. It is not affiliated with, endorsed by, or an official continuation of Next Generation Gaming, LLC.

**Original source:** https://github.com/NextGenerationGamingLLC/SA-MP-Development

Original authorship and applicable copyright notices are acknowledged. The redistribution and licensing terms of the original source must be clarified before any public release of modified code.

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