# dbt_audit

Based on [dbt_artifacts](https://github.com/brooklyn-data/dbt_artifacts/tree/2.6.3) (Apache License 2.0) and [elementary](https://github.com/elementary-data/dbt-data-reliability/tree/0.15.2) (Apache License 2.0). Neither package is compatible with ClickHouse as at 2024-06-01.

## Installation

1. Add the package to your `packages.yml`:

    ```yaml
    packages:
      - package: https://github.com/netbek/dbt_audit
        version: 0.0.3
    ```

2. Configure the package in your `dbt_project.yml`:

    ```yaml
    models:
      dbt_audit:
        +schema: dbt_audit

    vars:
      dbt_audit_columns: [dbt_run_id]
    ```

3. Run `dbt deps` to install the package.

4. Create the tables:

    ```shell
    dbt run -s tag:dbt_audit
    ```

## License

Copyright (c) 2024 Hein Bekker. Licensed under the Apache License, version 2.
