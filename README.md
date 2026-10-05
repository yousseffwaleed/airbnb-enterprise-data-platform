# Airbnb Enterprise Data Platform

A starter data platform project for loading Airbnb-style booking, listing, and host data into Snowflake and transforming it with dbt.

## Current status

The repository contains three sample CSV files, Snowflake table DDL, and a dbt project. The dbt models are still the default example models; there are not yet models that transform the Airbnb data, nor an automated CSV-to-Snowflake ingestion process. The SQL in `DDL/resources.sql` is a template and contains placeholder S3 and file values, so it is not ready to run as-is.

## Repository layout

| Path | Purpose |
| --- | --- |
| `sourceData/` | Sample `bookings.csv`, `hosts.csv`, and `listings.csv` files |
| `DDL/ddl.sql` | Snowflake table definitions for hosts, listings, and bookings |
| `DDL/resources.sql` | Starter CSV file format, stage, and `COPY INTO` template |
| `aws_snowflake_project/` | dbt project, profile, models, tests, and generated artifacts |
| `main.py` | Minimal Python entry point; no pipeline logic is implemented yet |

## Requirements

- Python 3.12 or newer
- [uv](https://docs.astral.sh/uv/) for Python dependency management
- A Snowflake account with permissions to create or use the target database, schema, warehouse, and role

Install the project dependencies from the repository root:

```powershell
uv sync
```

## Configure Snowflake access

The dbt profile is `aws_snowflake_project`, configured in `aws_snowflake_project/profiles.yml`. Before running dbt, configure the account, user, password, role, warehouse, database, and schema for your own Snowflake environment. Keep credentials in environment variables or another local secret store; do not commit passwords, access keys, or populated local environment files.

The current profile file contains hard-coded credentials. Treat them as exposed: rotate the Snowflake password, then replace the values with local, environment-backed configuration before sharing or pushing this repository.

## Run dbt

From the repository root in PowerShell:

```powershell
Set-Location aws_snowflake_project
uv run dbt debug --profiles-dir .
uv run dbt run --profiles-dir .
uv run dbt test --profiles-dir .
```

These commands currently validate and run the starter dbt models, not transformations of the Airbnb CSV data. Generated dbt artifacts are written under `aws_snowflake_project/target/`.

## Snowflake setup

Review and run `DDL/ddl.sql` in Snowflake to create the three raw tables. To load files from S3, first adapt `DDL/resources.sql` with your own stage URL, file names, and secure AWS credentials. Do not place access keys directly in SQL committed to this repository. The CSV files currently live in `sourceData/`; no upload or load automation is included.

## Next steps

- Configure protected Snowflake credentials and verify the connection with `dbt debug`.
- Create dbt sources for the raw tables and replace the example models with Airbnb transformations.
- Add schema tests and document the resulting models.
- Implement and test an ingestion workflow for the source CSV files.
