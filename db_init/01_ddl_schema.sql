DROP TABLE IF EXISTS stg_raw_data CASCADE;

CREATE TABLE stg_raw_data (
    id INT, customer_first_name VARCHAR(100), customer_last_name VARCHAR(100), customer_age INT,
    customer_email VARCHAR(200), customer_country VARCHAR(100), customer_postal_code VARCHAR(50),
    customer_pet_type VARCHAR(50), customer_pet_name VARCHAR(100), customer_pet_breed VARCHAR(100),
    seller_first_name VARCHAR(100), seller_last_name VARCHAR(100), seller_email VARCHAR(200),
    seller_country VARCHAR(100), seller_postal_code VARCHAR(50), product_name VARCHAR(200),
    product_category VARCHAR(100), product_price DECIMAL(10,2), product_quantity INT,
    sale_date VARCHAR(20), sale_customer_id INT, sale_seller_id INT, sale_product_id INT,
    sale_quantity INT, sale_total_price DECIMAL(10,2), store_name VARCHAR(200),
    store_location VARCHAR(200), store_city VARCHAR(100), store_state VARCHAR(100),
    store_country VARCHAR(100), store_phone VARCHAR(50), store_email VARCHAR(200),
    pet_category VARCHAR(50), product_weight DECIMAL(10,2), product_color VARCHAR(50),
    product_size VARCHAR(50), product_brand VARCHAR(100), product_material VARCHAR(100),
    product_description TEXT, product_rating DECIMAL(3,1), product_reviews INT,
    product_release_date VARCHAR(20), product_expiry_date VARCHAR(20), supplier_name VARCHAR(200),
    supplier_contact VARCHAR(200), supplier_email VARCHAR(200), supplier_phone VARCHAR(50),
    supplier_address VARCHAR(300), supplier_city VARCHAR(100), supplier_country VARCHAR(100)
);

CREATE TABLE ref_countries (id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE);
CREATE TABLE ref_brands (id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE);
CREATE TABLE ref_categories (id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE);
CREATE TABLE ref_pet_categories (id SERIAL PRIMARY KEY, name VARCHAR(50) NOT NULL UNIQUE);
CREATE TABLE ref_pet_types (id SERIAL PRIMARY KEY, name VARCHAR(50) NOT NULL UNIQUE);
CREATE TABLE ref_pet_breeds (id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE);
CREATE TABLE ref_materials (id SERIAL PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE);

CREATE TABLE dim_suppliers (
    id SERIAL PRIMARY KEY, name VARCHAR(200) NOT NULL UNIQUE, contact_name VARCHAR(200),
    email VARCHAR(200), phone VARCHAR(50), address VARCHAR(300), city VARCHAR(100),
    country_id INT REFERENCES ref_countries(id)
);

CREATE TABLE dim_buyers (
    id INT PRIMARY KEY, first_name VARCHAR(100), last_name VARCHAR(100), age INT,
    email VARCHAR(200), postal_code VARCHAR(50), country_id INT REFERENCES ref_countries(id),
    pet_type_id INT REFERENCES ref_pet_types(id), pet_name VARCHAR(100), breed_id INT REFERENCES ref_pet_breeds(id)
);

CREATE TABLE dim_vendors (
    id INT PRIMARY KEY, first_name VARCHAR(100), last_name VARCHAR(100), email VARCHAR(200),
    postal_code VARCHAR(50), country_id INT REFERENCES ref_countries(id)
);

CREATE TABLE dim_stores (
    id SERIAL PRIMARY KEY, name VARCHAR(200) NOT NULL UNIQUE, location VARCHAR(200),
    city VARCHAR(100), state VARCHAR(100), country_id INT REFERENCES ref_countries(id),
    phone VARCHAR(50), email VARCHAR(200)
);

CREATE TABLE dim_products (
    id INT PRIMARY KEY, name VARCHAR(200), category_id INT REFERENCES ref_categories(id),
    price DECIMAL(10,2), quantity INT, pet_category_id INT REFERENCES ref_pet_categories(id),
    weight DECIMAL(10,2), color VARCHAR(50), size VARCHAR(50), brand_id INT REFERENCES ref_brands(id),
    material_id INT REFERENCES ref_materials(id), description TEXT, rating DECIMAL(3,1),
    reviews INT, release_date DATE, expiry_date DATE, supplier_id INT REFERENCES dim_suppliers(id)
);

CREATE TABLE fct_transactions (
    transaction_id BIGSERIAL PRIMARY KEY, source_id BIGINT, buyer_id INT REFERENCES dim_buyers(id),
    vendor_id INT REFERENCES dim_vendors(id), product_id INT REFERENCES dim_products(id),
    store_id INT REFERENCES dim_stores(id), transaction_date DATE,
    qty INT, total_amount DECIMAL(10,2)
);