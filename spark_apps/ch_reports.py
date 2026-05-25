from pyspark.sql import SparkSession
import pyspark.sql.functions as F

spark = SparkSession.builder.appName("ETL_ClickHouse").getOrCreate()

db_url = "jdbc:postgresql://petstore_dwh_db:5432/snowflake_db"
db_props = {"user": "dw_admin", "password": "dw_password", "driver": "org.postgresql.Driver"}

ch_url = "jdbc:ch://clickhouse:8123/default"
ch_props = {"user": "ch_admin", "password": "ch_password", "driver": "com.clickhouse.jdbc.ClickHouseDriver"}

df = spark.read.jdbc(url=db_url, table="stg_raw_data", properties=db_props)

rep1 = df.groupBy("product_name", "product_category").agg(F.sum("sale_total_price").alias("revenue"),F.sum("sale_quantity").alias("sales"),F.round(F.avg("product_rating"), 2).alias("avg_rating")).orderBy(F.desc("revenue")).limit(10)
rep2 = df.groupBy("customer_email", "customer_first_name", "customer_last_name").agg(F.sum("sale_total_price").alias("total_spent"),F.round(F.avg("sale_total_price"), 2).alias("avg_check")).orderBy(F.desc("total_spent")).limit(10)
rep3 = df.withColumn("y", F.substring("sale_date", -4, 4)).groupBy("y").agg(F.sum("sale_total_price").alias("year_rev"),F.count("id").alias("tx_count")).orderBy("y")
rep4 = df.groupBy("store_name", "store_city").agg(F.sum("sale_total_price").alias("store_rev")).orderBy(F.desc("store_rev")).limit(5)
rep5 = df.groupBy("supplier_name", "supplier_country").agg(F.sum("sale_total_price").alias("sup_rev"),F.round(F.avg("product_price"), 2).alias("avg_price")).orderBy(F.desc("sup_rev")).limit(5)
rep6 = df.groupBy("product_name").agg(F.round(F.avg("product_rating"), 2).alias("rating"),F.sum("product_reviews").alias("reviews")).orderBy(F.desc("reviews")).limit(10)

tables = {
    "report_products": rep1,
    "report_customers": rep2,
    "report_time": rep3,
    "report_stores": rep4,
    "report_suppliers": rep5,
    "report_quality": rep6
}

for k, v in tables.items():
    v.write \
        .mode("overwrite") \
        .option("createTableOptions", "ENGINE=MergeTree() ORDER BY tuple()") \
        .jdbc(url=ch_url, table=k, properties=ch_props)

spark.stop()