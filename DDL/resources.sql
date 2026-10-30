USE DATABASE AIRBNB;
USE SCHEMA STAGING;

-- Requires ACCOUNTADMIN; then run DESC INTEGRATION and update the IAM role trust policy.
CREATE STORAGE INTEGRATION IF NOT EXISTS s3_airbnb_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::891377052362:role/snowflake_s3_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://snowbucketyoussef/source/');

CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;

CREATE OR REPLACE STAGE snowstage
  STORAGE_INTEGRATION = s3_airbnb_int
  URL = 's3://snowbucketyoussef/source/'
  FILE_FORMAT = csv_format;

-- Use CREATE, not CREATE OR REPLACE: replacing a pipe resets its load history.
-- S3 sends new-file events to the queue in SHOW PIPES (notification_channel).
-- Pipes load only files that arrive after creation; backfill older files with a manual COPY INTO.
CREATE PIPE IF NOT EXISTS hosts_pipe AUTO_INGEST = TRUE AS
  COPY INTO HOSTS    FROM @snowstage PATTERN = '.*hosts.*[.]csv';
CREATE PIPE IF NOT EXISTS listings_pipe AUTO_INGEST = TRUE AS
  COPY INTO LISTINGS FROM @snowstage PATTERN = '.*listings.*[.]csv';
CREATE PIPE IF NOT EXISTS bookings_pipe AUTO_INGEST = TRUE AS
  COPY INTO BOOKINGS FROM @snowstage PATTERN = '.*bookings.*[.]csv';