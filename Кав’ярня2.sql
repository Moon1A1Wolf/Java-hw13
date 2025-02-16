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
    name_en VARCHAR(100),
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
VALUES ('Латте', NULL, 'Напій', 60.00);

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
VALUES ('Анна Сидоренко', '', 'Одеса, вул. Дерибасівська, 10', 'Бариста');

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



-- №1
SELECT * FROM menu 
WHERE category = 'Напій' AND name_ua IS NOT NULL AND name_en IS NOT NULL;

SELECT * FROM menu 
WHERE category = 'Напій' AND (name_ua IS NULL OR name_en IS NULL);

SELECT * FROM menu 
WHERE category = 'Десерт' AND name_ua IS NOT NULL AND name_en IS NOT NULL;

SELECT * FROM menu 
WHERE category = 'Десерт' AND (name_ua IS NULL OR name_en IS NULL);

SELECT * FROM menu 
WHERE (category = 'Десерт' OR category = 'Напій') 
AND (name_ua IS NULL OR name_en IS NULL);

SELECT * FROM menu 
WHERE (category = 'Десерт' OR category = 'Напій') 
AND name_ua IS NOT NULL AND name_en IS NOT NULL;

SELECT * FROM menu 
WHERE (category = 'Десерт' OR category = 'Напій') 
AND (name_ua IS NULL OR name_en IS NULL);


-- №2
SELECT MIN(price) AS min_drink_price FROM menu WHERE category = 'Напій';

SELECT MIN(price) AS min_dessert_price FROM menu WHERE category = 'Десерт';

SELECT name_ua, name_en, price 
FROM menu 
WHERE category = 'Напій' 
AND price = (SELECT MIN(price) FROM menu WHERE category = 'Напій');

SELECT name_ua, name_en, price 
FROM menu 
WHERE category = 'Десерт' 
AND price = (SELECT MIN(price) FROM menu WHERE category = 'Десерт');


-- №3
SELECT MAX(price) AS max_drink_price FROM menu WHERE category = 'Напій';

SELECT MAX(price) AS max_dessert_price FROM menu WHERE category = 'Десерт';

SELECT name_ua, name_en, price 
FROM menu 
WHERE category = 'Напій' 
AND price = (SELECT MAX(price) FROM menu WHERE category = 'Напій');

SELECT name_ua, name_en, price 
FROM menu 
WHERE category = 'Десерт' 
AND price = (SELECT MAX(price) FROM menu WHERE category = 'Десерт');

SELECT ROUND(CAST(AVG(price) AS NUMERIC), 2) AS avg_drink_price 
FROM menu 
WHERE category = 'Напій';

SELECT ROUND(CAST(AVG(price) AS NUMERIC), 2) AS avg_dessert_price 
FROM menu 
WHERE category = 'Десерт';

SELECT category, ROUND(CAST(AVG(price) AS NUMERIC), 2) AS avg_price 
FROM menu 
GROUP BY category;


-- №4
SELECT COUNT(*) AS barista_count 
FROM staff 
WHERE position = 'Бариста';

SELECT COUNT(*) AS waiter_count 
FROM staff 
WHERE position = 'Офіціант';

SELECT COUNT(*) AS confectioner_count 
FROM staff 
WHERE position = 'Кондитер';

SELECT COUNT(*) AS total_staff_count 
FROM staff;

SELECT * FROM staff 
ORDER BY id DESC 
LIMIT 1;

SELECT * FROM staff 
ORDER BY id ASC 
LIMIT 1;


-- №5
SELECT * FROM staff 
WHERE phone IS NULL OR phone = '';

SELECT DISTINCT split_part(full_name, ' ', 1) AS name
FROM staff;

SELECT DISTINCT split_part(full_name, ' ', 2) AS surname
FROM staff;
