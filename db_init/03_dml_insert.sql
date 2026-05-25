INSERT INTO ref_countries (name)
SELECT DISTINCT val FROM (
    SELECT customer_country AS val FROM stg_raw_data UNION ALL
    SELECT seller_country FROM stg_raw_data UNION ALL
    SELECT store_country FROM stg_raw_data UNION ALL
    SELECT supplier_country FROM stg_raw_data
) sub WHERE val IS NOT NULL AND val <> '' ON CONFLICT (name) DO NOTHING;

INSERT INTO ref_brands (name) SELECT DISTINCT product_brand FROM stg_raw_data WHERE product_brand IS NOT NULL AND product_brand <> '' ON CONFLICT (name) DO NOTHING;
INSERT INTO ref_categories (name) SELECT DISTINCT product_category FROM stg_raw_data WHERE product_category IS NOT NULL AND product_category <> '' ON CONFLICT (name) DO NOTHING;
INSERT INTO ref_pet_categories (name) SELECT DISTINCT pet_category FROM stg_raw_data WHERE pet_category IS NOT NULL AND pet_category <> '' ON CONFLICT (name) DO NOTHING;
INSERT INTO ref_pet_types (name) SELECT DISTINCT customer_pet_type FROM stg_raw_data WHERE customer_pet_type IS NOT NULL AND customer_pet_type <> '' ON CONFLICT (name) DO NOTHING;
INSERT INTO ref_pet_breeds (name) SELECT DISTINCT customer_pet_breed FROM stg_raw_data WHERE customer_pet_breed IS NOT NULL AND customer_pet_breed <> '' ON CONFLICT (name) DO NOTHING;
INSERT INTO ref_materials (name) SELECT DISTINCT product_material FROM stg_raw_data WHERE product_material IS NOT NULL AND product_material <> '' ON CONFLICT (name) DO NOTHING;

INSERT INTO dim_suppliers (name, contact_name, email, phone, address, city, country_id)
SELECT DISTINCT ON (r.supplier_name) r.supplier_name, r.supplier_contact, r.supplier_email, r.supplier_phone, r.supplier_address, r.supplier_city, c.id
FROM stg_raw_data r LEFT JOIN ref_countries c ON c.name = r.supplier_country
WHERE r.supplier_name IS NOT NULL AND r.supplier_name <> '' ORDER BY r.supplier_name ON CONFLICT (name) DO NOTHING;

INSERT INTO dim_stores (name, location, city, state, country_id, phone, email)
SELECT DISTINCT ON (r.store_name) r.store_name, r.store_location, r.store_city, r.store_state, c.id, r.store_phone, r.store_email
FROM stg_raw_data r LEFT JOIN ref_countries c ON c.name = r.store_country
WHERE r.store_name IS NOT NULL AND r.store_name <> '' ORDER BY r.store_name ON CONFLICT (name) DO NOTHING;

INSERT INTO dim_buyers (id, first_name, last_name, age, email, postal_code, country_id, pet_type_id, pet_name, breed_id)
SELECT DISTINCT ON (r.sale_customer_id) r.sale_customer_id, r.customer_first_name, r.customer_last_name, r.customer_age, r.customer_email, r.customer_postal_code, c.id, pt.id, r.customer_pet_name, pb.id
FROM stg_raw_data r
LEFT JOIN ref_countries c ON c.name = r.customer_country
LEFT JOIN ref_pet_types pt ON pt.name = r.customer_pet_type
LEFT JOIN ref_pet_breeds pb ON pb.name = r.customer_pet_breed
WHERE r.sale_customer_id IS NOT NULL ORDER BY r.sale_customer_id ON CONFLICT (id) DO NOTHING;

INSERT INTO dim_vendors (id, first_name, last_name, email, postal_code, country_id)
SELECT DISTINCT ON (r.sale_seller_id) r.sale_seller_id, r.seller_first_name, r.seller_last_name, r.seller_email, r.seller_postal_code, c.id
FROM stg_raw_data r LEFT JOIN ref_countries c ON c.name = r.seller_country
WHERE r.sale_seller_id IS NOT NULL ORDER BY r.sale_seller_id ON CONFLICT (id) DO NOTHING;

INSERT INTO dim_products (id, name, category_id, price, quantity, pet_category_id, weight, color, size, brand_id, material_id, description, rating, reviews, release_date, expiry_date, supplier_id)
SELECT DISTINCT ON (r.sale_product_id) r.sale_product_id, r.product_name, cat.id, r.product_price, r.product_quantity, pc.id, r.product_weight, r.product_color, r.product_size, b.id, m.id, r.product_description, r.product_rating, r.product_reviews,
    CASE WHEN r.product_release_date ~ '^[0-9]+/[0-9]+/[0-9]+$' THEN TO_DATE(r.product_release_date, 'MM/DD/YYYY') ELSE NULL END,
    CASE WHEN r.product_expiry_date ~ '^[0-9]+/[0-9]+/[0-9]+$' THEN TO_DATE(r.product_expiry_date, 'MM/DD/YYYY') ELSE NULL END,
    sup.id
FROM stg_raw_data r
LEFT JOIN ref_categories cat ON cat.name = r.product_category
LEFT JOIN ref_pet_categories pc ON pc.name = r.pet_category
LEFT JOIN ref_brands b ON b.name = r.product_brand
LEFT JOIN ref_materials m ON m.name = r.product_material
LEFT JOIN dim_suppliers sup ON sup.name = r.supplier_name
WHERE r.sale_product_id IS NOT NULL ORDER BY r.sale_product_id ON CONFLICT (id) DO NOTHING;

INSERT INTO fct_transactions (source_id, buyer_id, vendor_id, product_id, store_id, transaction_date, qty, total_amount)
SELECT r.id, r.sale_customer_id, r.sale_seller_id, r.sale_product_id, s.id,
    CASE WHEN r.sale_date ~ '^[0-9]+/[0-9]+/[0-9]+$' THEN TO_DATE(r.sale_date, 'MM/DD/YYYY') ELSE NULL END,
    r.sale_quantity, r.sale_total_price
FROM stg_raw_data r LEFT JOIN dim_stores s ON s.name = r.store_name;