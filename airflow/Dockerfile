FROM apache/airflow:3.3.2-python3.12

# Optional corporate CA certificates (*.crt in airflow/certs) so pip and Snowflake work behind a TLS-inspecting proxy.
USER root
COPY certs/ /tmp/extra-certs/
RUN find /tmp/extra-certs -name '*.crt' -exec cp {} /usr/local/share/ca-certificates/ \; \
    && update-ca-certificates \
    && rm -rf /tmp/extra-certs
USER airflow
ENV PIP_CERT=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

# dbt runs from its own virtualenv so its dependencies cannot conflict with Airflow's.
RUN python -m venv /home/airflow/dbt_venv \
    && /home/airflow/dbt_venv/bin/pip install --no-cache-dir "dbt-core>=1.12.5" "dbt-snowflake>=1.12.1"

COPY --chown=airflow requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Directory for the SQLite metadata database; created here so the named volume inherits its ownership.
RUN mkdir -p /opt/airflow/state
