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

-- COPY INTO skips files already loaded; truncate the target first to reload.
COPY INTO HOSTS    FROM @snowstage FILES = ('hosts.csv')    ON_ERROR = ABORT_STATEMENT;
COPY INTO LISTINGS FROM @snowstage FILES = ('listings.csv') ON_ERROR = ABORT_STATEMENT;
COPY INTO BOOKINGS FROM @snowstage FILES = ('bookings.csv') ON_ERROR = ABORT_STATEMENT;