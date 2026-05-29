---
name: query-db
description:
  Run SQL queries against the local PostgreSQL database in Docker Compose. Use
  this skill whenever the user wants to query the database, inspect tables,
  check data, or run any SQL against the local dev postgres instance.
---

Run the query using psql:

```bash
psql --pset=pager=off -x -c "<SQL>"
```

- Connection details come from env vars: `PGHOST`, `PGPORT`, `PGUSER`,
  `PGPASSWORD`, `PGDATABASE`
- `-x` enables expanded (vertical) display — one field per line, much easier to
  read
- Use `-c` for a single statement, or `-f <file>` for a script
- For schema inspection use information_schema queries rather than `\dt` / `\d`
  meta-commands

Show the output directly to the user.
