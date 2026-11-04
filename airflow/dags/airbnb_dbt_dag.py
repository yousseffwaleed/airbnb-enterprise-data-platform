import os
from datetime import datetime, timedelta
from pathlib import Path

from alerts import notify_failure
from cosmos import DbtDag, ExecutionConfig, ProfileConfig, ProjectConfig, RenderConfig
from cosmos.constants import InvocationMode, TestBehavior

DBT_PROJECT_DIR = Path(os.environ.get("DBT_PROJECT_DIR", "/opt/airflow/dbt/aws_snowflake_project"))
DBT_EXECUTABLE = os.environ.get("DBT_EXECUTABLE_PATH", "/home/airflow/dbt_venv/bin/dbt")

# Reuses the credential-free CI profile; the Snowflake settings come from environment variables.
profile_config = ProfileConfig(
    profile_name="aws_snowflake_project",
    target_name="ci",
    profiles_yml_filepath=DBT_PROJECT_DIR / "ci" / "profiles.yml",
)

airbnb_dbt_daily = DbtDag(
    dag_id="airbnb_dbt_daily",
    project_config=ProjectConfig(DBT_PROJECT_DIR),
    profile_config=profile_config,
    execution_config=ExecutionConfig(
        dbt_executable_path=DBT_EXECUTABLE,
        invocation_mode=InvocationMode.SUBPROCESS,
    ),
    render_config=RenderConfig(
        test_behavior=TestBehavior.AFTER_EACH,
        should_detach_multiple_parents_tests=True,
        dbt_executable_path=DBT_EXECUTABLE,
        invocation_mode=InvocationMode.SUBPROCESS,
    ),
    operator_args={"install_deps": False, "append_env": True},
    schedule="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    max_active_runs=1,
    default_args={
        "retries": 2,
        "retry_delay": timedelta(minutes=5),
        "retry_exponential_backoff": True,
        "max_retry_delay": timedelta(minutes=30),
        "on_failure_callback": notify_failure,
    },
    tags=["dbt", "snowflake", "cosmos"],
)
