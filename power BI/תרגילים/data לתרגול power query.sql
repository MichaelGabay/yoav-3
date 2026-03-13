-- ============================================================
-- סקריפט PostgreSQL להכנת נתונים לתרגיל Power Query ב-Power BI
-- הרץ את הסקריפט ב-PostgreSQL לפני טעינת הנתונים ל-Power BI
-- ============================================================

-- ניקוי (אופציונלי - אם רוצים להריץ מחדש)
DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS regions CASCADE;
DROP TABLE IF EXISTS raw_sales_log CASCADE;

-- טבלת אזורים
CREATE TABLE regions (
    region_code VARCHAR(5) PRIMARY KEY,
    region_name VARCHAR(100),
    country_hebrew VARCHAR(50)
);

INSERT INTO regions (region_code, region_name, country_hebrew) VALUES
('IL', 'Israel', 'ישראל'),
('US', 'United States', 'ארה"ב'),
('UK', 'United Kingdom', 'בריטניה'),
('DE', 'Germany', 'גרמניה'),
('FR', 'France', 'צרפת'),
('CA', 'Canada', 'קנדה'),
('AU', 'Australia', 'אוסטרליה'),
('XX', NULL, 'לא ידוע');

-- טבלת קטגוריות (עם ערכים כפולים במכוון - לתרגיל ניקוי)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100),
    parent_id INT REFERENCES categories(category_id)
);

INSERT INTO categories (category_name, parent_id) VALUES
('אלקטרוניקה', NULL),
('מחשבים', 1),
('טלפונים', 1),
('ביגוד', NULL),
('נעליים', 4),
('מזון', NULL),
('משקאות', 6);
INSERT INTO categories (category_name, parent_id) VALUES ('אלקטרוניקה', NULL); -- כפול במכוון

-- טבלת לקוחות (נתונים "מלוכלכים" - רווחים מיותרים, רישום מעורב)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(200),
    email VARCHAR(200),
    region_code VARCHAR(5) REFERENCES regions(region_code),
    signup_date DATE,
    status VARCHAR(20)
);

INSERT INTO customers (full_name, email, region_code, signup_date, status) VALUES
('  יוסי כהן  ', 'yosi@mail.co.il', 'IL', '2023-01-15', 'active'),
('Sarah Smith', 'sarah.smith@gmail.com', 'US', '2023-02-20', 'active'),
('DAVID JONES', 'david.j@company.uk', 'UK', '2023-03-10', 'inactive'),
('מיכל לוי', 'michal.levi@bezeq.co.il', 'IL', NULL, 'active'),
('Jean Dupont', 'jean.dupont@orange.fr', 'FR', '2023-05-01', 'active'),
('Anna Müller', 'anna.mueller@gmx.de', 'DE', '2023-06-12', 'active'),
('  john doe  ', 'JOHN.DOE@YAHOO.COM', 'US', '2023-07-22', 'pending'),
('רחל אברהם', 'rachel@walla.co.il', 'IL', '2023-08-05', 'active'),
('Michael Brown', 'michael.b@outlook.com', 'CA', '2023-09-18', 'active'),
('Emma Wilson', 'emma.wilson@mail.au', 'AU', '2023-10-30', 'inactive'),
('פרץ גולדמן', 'peretz@gmail.com', 'IL', '2022-11-11', 'active'),
('Lisa Schmidt', NULL, 'DE', '2023-12-01', 'active'),
('דני רוזן', 'danny@netvision.net.il', NULL, '2024-01-08', 'active');

-- טבלת מוצרים (מחירים במספר פורמטים, שמות עם תווים מיוחדים)
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200),
    category_id INT REFERENCES categories(category_id),
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    in_stock INT,
    discontinued BOOLEAN DEFAULT FALSE
);

INSERT INTO products (product_name, category_id, unit_price, cost_price, in_stock, discontinued) VALUES
('מקלדת אלקטרונית', 2, 299.99, 120.00, 50, FALSE),
('Laptop Pro 15', 2, 4500.00, 2800.00, 12, FALSE),
('Smartphone X', 3, 3200.50, 1800.00, 30, FALSE),
('חולצה בסיסית', 4, 79.90, 25.00, 200, FALSE),
('נעלי ספורט', 5, 349.00, 140.00, 45, TRUE),
('קפה פילטר', 6, 35.00, 12.00, 500, FALSE),
('מיץ תפוזים 1L', 7, 18.90, 6.00, 300, FALSE),
('מסך 27 אינץ', 2, 1200.00, 650.00, 25, FALSE),
('אוזניות אלחוטיות', 1, 199.00, 70.00, 80, FALSE),
('משקפי שמש', 4, 159.00, 45.00, 0, FALSE),
('חלב 1%', 7, 6.50, 3.20, 150, FALSE),
('Tablet Mini', 2, 899.00, 450.00, 18, FALSE),
('מקלדת מכנית', 2, 450.00, 200.00, 22, FALSE),
('מעקב ישן - לא למכירה', 2, 99.00, 50.00, 5, TRUE);

-- טבלת הזמנות (תאריכים, סטטוסים מעורבים)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    order_datetime TIMESTAMP,
    status VARCHAR(30),
    ship_region VARCHAR(5),
    notes TEXT
);

INSERT INTO orders (customer_id, order_date, order_datetime, status, ship_region, notes) VALUES
(1, '2024-01-10', '2024-01-10 09:15:00', 'Shipped', 'IL', 'משלוח express'),
(2, '2024-01-12', '2024-01-12 14:30:00', 'Delivered', 'US', NULL),
(3, '2024-01-14', '2024-01-14 10:00:00', 'cancelled', 'UK', 'ביטול מלקוח'),
(1, '2024-02-01', '2024-02-01 11:20:00', 'Shipped', 'IL', NULL),
(5, '2024-02-05', '2024-02-05 16:45:00', 'Pending', 'FR', NULL),
(6, '2024-02-08', '2024-02-08 09:00:00', 'delivered', 'DE', NULL),
(4, '2024-02-10', '2024-02-10 12:00:00', 'Shipped', 'IL', 'דחוף'),
(7, '2024-02-15', '2024-02-15 08:30:00', 'Pending', 'US', NULL),
(8, '2024-03-01', '2024-03-01 13:00:00', 'Delivered', 'IL', NULL),
(9, '2024-03-05', '2024-03-05 10:15:00', 'Shipped', 'CA', NULL),
(10, '2024-03-10', '2024-03-10 11:00:00', 'cancelled', 'AU', NULL),
(1, '2024-03-12', '2024-03-12 09:45:00', 'Delivered', 'IL', NULL),
(11, '2024-03-15', '2024-03-15 14:20:00', 'Shipped', 'IL', NULL),
(2, '2024-03-20', '2024-03-20 16:00:00', 'Pending', 'US', NULL),
(12, '2024-03-22', '2024-03-22 08:00:00', 'delivered', 'DE', NULL),
(13, NULL, '2024-03-25 12:30:00', 'Pending', NULL, 'תאריך הזמנה לא ידוע');

-- טבלת פרטי הזמנה
CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    unit_price_at_order DECIMAL(10,2),
    discount_pct DECIMAL(5,2) DEFAULT 0
);

INSERT INTO order_details (order_id, product_id, quantity, unit_price_at_order, discount_pct) VALUES
(1, 1, 2, 299.99, 0),
(1, 6, 5, 35.00, 10),
(2, 3, 1, 3200.50, 5),
(2, 9, 2, 199.00, 0),
(3, 2, 1, 4500.00, 0),
(4, 4, 10, 79.90, 15),
(4, 7, 6, 18.90, 0),
(5, 8, 1, 1200.00, 0),
(6, 1, 1, 299.99, 0),
(6, 12, 1, 899.00, 20),
(7, 10, 3, 159.00, 0),
(8, 2, 1, 4500.00, 10),
(9, 5, 2, 349.00, 0),
(9, 6, 4, 35.00, 0),
(10, 3, 1, 3200.50, 0),
(11, 4, 5, 79.90, 0),
(12, 8, 2, 1200.00, 5),
(12, 13, 1, 450.00, 0),
(13, 7, 24, 18.90, 10),
(14, 2, 1, 4500.00, 0),
(15, 9, 4, 199.00, 15),
(16, 1, 3, 299.99, 0);

-- טבלת לוג גולמי (טקסט שדורש פירוק ב-Power Query)
CREATE TABLE raw_sales_log (
    log_id SERIAL PRIMARY KEY,
    log_date DATE,
    log_text TEXT
);

INSERT INTO raw_sales_log (log_date, log_text) VALUES
('2024-01-15', 'Sale|ProductId=1|Qty=3|Price=299.99'),
('2024-01-16', 'Sale|ProductId=6|Qty=10|Price=35.00'),
('2024-01-17', 'Return|OrderId=1|Amount=599.98'),
('2024-02-01', 'Sale|ProductId=2|Qty=1|Price=4500.00'),
('2024-02-02', 'Sale|ProductId=4|Qty=20|Price=79.90'),
('2024-02-03', 'Sale|ProductId=7|Qty=12|Price=18.90'),
('2024-03-01', 'Return|OrderId=5|Amount=1200.00'),
('2024-03-10', 'Sale|ProductId=3|Qty=2|Price=3200.50');

-- סיום
SELECT 'Setup completed. Tables: regions, categories, customers, products, orders, order_details, raw_sales_log' AS message;
