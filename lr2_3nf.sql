-- =====================================================
--  1. Создаём схему
-- =====================================================
CREATE SCHEMA IF NOT EXISTS videorental;
SET search_path TO videorental;

-- =====================================================
--  2. Таблицы справочников: Страны, Города, Адреса
-- =====================================================
CREATE TABLE countries (
    country_id    SERIAL PRIMARY KEY,
    country_name  VARCHAR(100) NOT NULL
);

CREATE TABLE cities (
    city_id     SERIAL PRIMARY KEY,
    city_name   VARCHAR(100) NOT NULL,
    country_id  INTEGER NOT NULL,
    CONSTRAINT fk_cities_country
        FOREIGN KEY (country_id)
        REFERENCES countries (country_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE addresses (
    address_id    SERIAL PRIMARY KEY,
    address_line  VARCHAR(255) NOT NULL,
    postal_code   VARCHAR(50),
    city_id       INTEGER NOT NULL,
    CONSTRAINT fk_addresses_city
        FOREIGN KEY (city_id)
        REFERENCES cities (city_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =====================================================
--  3. Категории, Актёры, Фильмы и их связи
-- =====================================================
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE actors (
    actor_id    SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL
);

CREATE TABLE films (
    film_id          SERIAL PRIMARY KEY,
    title            VARCHAR(255) NOT NULL,
    description      TEXT,
    release_year     INTEGER,
    language         VARCHAR(50),
    rental_rate      DECIMAL(5,2) NOT NULL DEFAULT 0.99,
    replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 9.99,
    rating           VARCHAR(10),
    category_id      INTEGER,
    CONSTRAINT fk_films_category
        FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

CREATE TABLE film_actors (
    film_id  INTEGER NOT NULL,
    actor_id INTEGER NOT NULL,
    PRIMARY KEY (film_id, actor_id),
    CONSTRAINT fk_film_actors_film
        FOREIGN KEY (film_id)
        REFERENCES films (film_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_film_actors_actor
        FOREIGN KEY (actor_id)
        REFERENCES actors (actor_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- =====================================================
--  4. Магазины и Инвентарь
-- =====================================================
CREATE TABLE stores (
    store_id        SERIAL PRIMARY KEY,
    store_name      VARCHAR(100) NOT NULL,
    address_id      INTEGER NOT NULL,
    CONSTRAINT fk_stores_address
        FOREIGN KEY (address_id)
        REFERENCES addresses (address_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    film_id      INTEGER NOT NULL,
    store_id     INTEGER NOT NULL,
    added_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_film
        FOREIGN KEY (film_id)
        REFERENCES films (film_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_store
        FOREIGN KEY (store_id)
        REFERENCES stores (store_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =====================================================
--  5. Клиенты, Сотрудники, Прокаты, Платежи
-- =====================================================
CREATE TABLE customers (
    customer_id       SERIAL PRIMARY KEY,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    email             VARCHAR(100),
    phone             VARCHAR(20),
    address_id        INTEGER NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_customers_address
        FOREIGN KEY (address_id)
        REFERENCES addresses (address_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE staff (
    staff_id      SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100),
    username      VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255),
    store_id      INTEGER NOT NULL,
    active        BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_staff_store
        FOREIGN KEY (store_id)
        REFERENCES stores (store_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE rentals (
    rental_id     SERIAL PRIMARY KEY,
    rental_date   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    inventory_id  INTEGER NOT NULL,
    customer_id   INTEGER NOT NULL,
    staff_id      INTEGER NOT NULL,
    return_date   TIMESTAMP,
    CONSTRAINT fk_rentals_inventory
        FOREIGN KEY (inventory_id)
        REFERENCES inventory (inventory_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_rentals_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_rentals_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff (staff_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE payments (
    payment_id    SERIAL PRIMARY KEY,
    customer_id   INTEGER NOT NULL,
    staff_id      INTEGER NOT NULL,
    rental_id     INTEGER,
    amount        DECIMAL(5,2) NOT NULL,
    payment_date  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_payments_staff
        FOREIGN KEY (staff_id)
        REFERENCES staff (staff_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_payments_rental
        FOREIGN KEY (rental_id)
        REFERENCES rentals (rental_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- =====================================================
--  6. Завершение
-- =====================================================
-- Структура таблиц для видеопроката в 3NF с учётом связей.
-- При необходимости можно добавить индексы, триггеры и т.д.

COMMIT;
