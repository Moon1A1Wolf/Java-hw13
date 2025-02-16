DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS work_schedule CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS menu CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- напитки и десерты
CREATE TABLE menu (
    id SERIAL PRIMARY KEY,
    name_ua VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    category VARCHAR(50) CHECK (category IN ('Напій', 'Десерт')),
    price DOUBLE PRECISION NOT NULL CHECK (price > 0)
);
-- персонал
CREATE TABLE staff (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    address VARCHAR(255),
    position VARCHAR(50) CHECK (position IN ('Бариста', 'Офіціант', 'Кондитер'))
);
-- клиент
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    address VARCHAR(255),
    discount NUMERIC(5,2) DEFAULT 0 CHECK (discount >= 0 AND discount <= 100)
);
-- график
CREATE TABLE work_schedule (
    id SERIAL PRIMARY KEY,
    staff_id INT REFERENCES staff(id) ON DELETE CASCADE,  -- ссылка на сотрудника
    work_day DATE NOT NULL,
    shift VARCHAR(50) CHECK (shift IN ('Ранок', 'День', 'Вечір')) NOT NULL
);
-- заказ
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id) ON DELETE SET NULL,  -- ссылка на клиента
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_price DOUBLE PRECISION NOT NULL CHECK (total_price > 0)
);
-- связь заказов и товаров
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,  -- ссылка на заказ
    menu_id INT REFERENCES menu(id) ON DELETE CASCADE,  -- ссылка на товар
    quantity INT NOT NULL CHECK (quantity > 0),
    item_price DOUBLE PRECISION NOT NULL CHECK (item_price > 0)
);
ALTER TABLE orders ADD COLUMN staff_id INT REFERENCES staff(id) ON DELETE SET NULL;

-- новая позиция
INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Еспресо', 'Espresso', 'Напій', 35.00);

INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Торт Шоколадний', 'Chocolate Cake', 'Десерт', 270.00);

INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Торт Чизкейк', 'Cheesecake Cake', 'Десерт', 150.00);

-- новый официант 1
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Ігор Хмир', '0951234567', 'Харків, вул. Михайлика, 26', 'Офіціант');
-- новый официант 2
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Дмитро Броменко', '0931133559', 'Одеса, вул. Генуезька, 47', 'Офіціант');

-- новый бариста
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Анна Сидоренко', '0739876543', 'Одеса, вул. Дерибасівська, 10', 'Бариста');

-- новый кондитер
INSERT INTO staff (full_name, phone, address, position)
VALUES ('Олександр Килимок', '0677654321', 'Київ, вул. Лесі Українки, 15', 'Кондитер');

-- новый клиент 1
INSERT INTO customers (full_name, birth_date, phone, address, discount)
VALUES ('Олена Іванова', '1990-01-22', '0982345678', 'Львів, вул. Шевченка, 12', 15.00);
-- новый клиент 2
INSERT INTO customers (full_name, birth_date, phone, address, discount)
VALUES ('Богдан Кулін', '2001-10-21', '0631231234', '', 10.00);

-- новый заказ
INSERT INTO orders (customer_id, total_price, staff_id)
VALUES (1, 35.00, 1);  -- клиент ID = 1, официант ID = 1
INSERT INTO orders (customer_id, total_price, staff_id)
VALUES (1, 270.00, 2);  -- клиент ID = 1, официант ID = 2

-- новый график
INSERT INTO work_schedule (staff_id, work_day, shift)
VALUES
(3, CURRENT_DATE, 					   'Ранок'),
(2, CURRENT_DATE + INTERVAL '1 day',  'День'),
(3, CURRENT_DATE + INTERVAL '2 days', 'Вечір'),
(4, CURRENT_DATE + INTERVAL '3 days', 'Ранок'),
(1, CURRENT_DATE + INTERVAL '4 days', 'День'),
(2, CURRENT_DATE + INTERVAL '5 days', 'Вечір'),
(1, CURRENT_DATE + INTERVAL '6 days', 'Ранок');

-- новый вид кофе
INSERT INTO menu (name_ua, name_en, category, price)
VALUES ('Латте', 'Latte', 'Напій', 60.00);

-- №1
SELECT MIN(discount) AS min_discount
FROM customers;

SELECT MAX(discount) AS max_discount
FROM customers;

SELECT full_name, discount
FROM customers
WHERE discount = (SELECT MIN(discount) FROM customers);

SELECT full_name, discount
FROM customers
WHERE discount = (SELECT MAX(discount) FROM customers);

SELECT AVG(discount) AS average_discount
FROM customers;


-- №2
SELECT full_name, birth_date
FROM customers
ORDER BY birth_date DESC
LIMIT 1;

SELECT full_name, birth_date
FROM customers
ORDER BY birth_date ASC
LIMIT 1;

SELECT full_name, birth_date
FROM customers
WHERE EXTRACT(MONTH FROM birth_date) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND EXTRACT(DAY FROM birth_date) = EXTRACT(DAY FROM CURRENT_DATE);

SELECT full_name
FROM customers
WHERE address IS NULL OR address = '';

-- №3
SELECT * 
FROM orders 
WHERE DATE(order_date) = '2025-01-22';

SELECT * 
FROM orders 
WHERE order_date BETWEEN '2025-01-22 00:00:00' AND '2025-01-22 02:50:00';

SELECT COUNT(*) AS dessert_orders_count
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu m ON oi.menu_id = m.id
WHERE DATE(o.order_date) = '2025-01-22'
AND m.category = 'Десерт';

SELECT COUNT(*) AS drink_orders_count
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu m ON oi.menu_id = m.id
WHERE DATE(o.order_date) = '2025-01-22'
AND m.category = 'Напій';

-- №4
SELECT c.full_name AS customer_name, c.phone AS customer_phone, 
       s.full_name AS barista_name, s.phone AS barista_phone, 
       m.name_ua AS drink_name, o.order_date
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu m ON oi.menu_id = m.id
JOIN customers c ON o.customer_id = c.id
JOIN staff s ON o.staff_id = s.id
WHERE m.category = 'Напій'
AND DATE(o.order_date) = CURRENT_DATE
AND s.position = 'Бариста';

SELECT AVG(total_price) AS avg_order_amount
FROM orders
WHERE DATE(order_date) = '2025-01-22';

SELECT MAX(total_price) AS max_order_amount
FROM orders
WHERE DATE(order_date) = '2025-01-22';

SELECT c.full_name, c.phone, o.total_price, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE DATE(o.order_date) = '2025-01-22'
ORDER BY o.total_price DESC
LIMIT 1;

-- №5
SELECT s.full_name AS barista_name, ws.work_day, ws.shift
FROM work_schedule ws
JOIN staff s ON ws.staff_id = s.id
WHERE s.position = 'Бариста'
AND s.full_name = 'Анна Сидоренко'
AND ws.work_day BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 days'
ORDER BY ws.work_day;

SELECT s.full_name AS barista_name, ws.work_day, ws.shift
FROM work_schedule ws
JOIN staff s ON ws.staff_id = s.id
WHERE s.position = 'Бариста'
AND ws.work_day BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 days'
ORDER BY ws.work_day, s.full_name;

SELECT s.full_name AS staff_name, s.position, ws.work_day, ws.shift
FROM work_schedule ws
JOIN staff s ON ws.staff_id = s.id
WHERE ws.work_day BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 days'
ORDER BY ws.work_day, s.position, s.full_name;
