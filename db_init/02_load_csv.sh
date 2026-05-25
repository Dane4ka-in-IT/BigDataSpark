#!/bin/bash
set -e
echo "--- Начинаем загрузку CSV в stg_raw_data ---"

for file in /data_csv/MOCK_DATA*.csv; do
    echo "Загрузка файла: $file"
    psql -U dw_admin -d snowflake_db -c "\COPY stg_raw_data FROM '$file' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '\"', ESCAPE '\"')"
done

echo "--- Загрузка завершена ---"