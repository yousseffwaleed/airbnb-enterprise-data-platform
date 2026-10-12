-- The S3 URL, destination table, file name, and AWS credentials below are redacted placeholders.
-- Restore the actual values from a secure configuration before running this script; do not commit secrets.
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV' 
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


CREATE OR REPLACE STAGE snowstage
FILE_FORMAT = csv_format
URL='your_s3_bucket_path';
    

COPY INTO <your_table_name>
FROM @snowstage
FILES=('your_file_name.csv')
CREDENTIALS=(aws_key_id = 'yourkey', aws_secret_key = 'yoursecretkey');