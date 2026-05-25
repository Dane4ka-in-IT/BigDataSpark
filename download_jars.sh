#!/bin/bash
mkdir -p ./jars
curl -L -o ./jars/postgresql-42.7.1.jar "https://jdbc.postgresql.org/download/postgresql-42.7.1.jar"
curl -L -o ./jars/clickhouse-jdbc-0.6.0-patch5-shaded.jar "https://github.com/ClickHouse/clickhouse-java/releases/download/v0.6.0-patch5/clickhouse-jdbc-0.6.0-patch5-shaded.jar"
