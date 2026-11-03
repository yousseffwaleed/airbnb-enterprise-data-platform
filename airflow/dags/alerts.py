import json
import logging
import os
import urllib.request

log = logging.getLogger(__name__)


def notify_failure(context):
    """Task failure callback: runs after retries are exhausted."""
    ti = context["task_instance"]
    message = (
        f"dbt task failed: {ti.dag_id}.{ti.task_id} "
        f"(run {context.get('run_id')}, try {ti.try_number}): {context.get('exception')}"
    )
    log.error(message)

    url = os.environ.get("AIRFLOW_ALERT_WEBHOOK_URL", "")
    if not url:
        return
    if not url.startswith("https://"):
        log.error("AIRFLOW_ALERT_WEBHOOK_URL must be an https URL; alert not sent")
        return

    request = urllib.request.Request(
        url,
        data=json.dumps({"text": message}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        urllib.request.urlopen(request, timeout=10).close()
    except Exception:
        log.exception("Could not deliver failure alert")
