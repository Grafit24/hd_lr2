BEGIN;

-- ----------------------------------------
-- Создаём схему
-- ----------------------------------------
CREATE SCHEMA IF NOT EXISTS dv;

-- ******************************************************************
-- 1. Хаб: Клиенты (hub_customer)
-- ******************************************************************
CREATE TABLE dv.hub_customer (
    hk_customer     VARCHAR(64) NOT NULL PRIMARY KEY,  -- Hash Key
    bk_customer     VARCHAR(50) NOT NULL,             -- Business Key
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL
);

-- ----------------------------------------
-- Сателлит для hub_customer (sat_customer_details)
-- ----------------------------------------
CREATE TABLE dv.sat_customer_details (
    hk_customer     VARCHAR(64) NOT NULL,
    effective_from  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to    TIMESTAMP,
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL,

    -- Атрибуты клиента
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    email           VARCHAR(255),
    phone           VARCHAR(20),
    address         VARCHAR(255),
    city            VARCHAR(100),
    state           VARCHAR(100),
    postal_code     VARCHAR(20),

    PRIMARY KEY (hk_customer, effective_from),
    CONSTRAINT fk_sat_customer_details
        FOREIGN KEY (hk_customer)
        REFERENCES dv.hub_customer(hk_customer)
);

-- ******************************************************************
-- 2. Хаб: Фильмы (hub_movie)
-- ******************************************************************
CREATE TABLE dv.hub_movie (
    hk_movie        VARCHAR(64) NOT NULL PRIMARY KEY,
    bk_movie        VARCHAR(50) NOT NULL,
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL
);

-- ----------------------------------------
-- Сателлит для hub_movie (sat_movie_details)
-- ----------------------------------------
CREATE TABLE dv.sat_movie_details (
    hk_movie        VARCHAR(64) NOT NULL,
    effective_from  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to    TIMESTAMP,
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL,

    title           VARCHAR(255),
    genre           VARCHAR(100),
    year_released   INTEGER,
    rating          VARCHAR(10),

    PRIMARY KEY (hk_movie, effective_from),
    CONSTRAINT fk_sat_movie_details
        FOREIGN KEY (hk_movie)
        REFERENCES dv.hub_movie(hk_movie)
);

-- ******************************************************************
-- 3. Хаб: Магазины (hub_store)
-- ******************************************************************
CREATE TABLE dv.hub_store (
    hk_store        VARCHAR(64) NOT NULL PRIMARY KEY,
    bk_store        VARCHAR(50) NOT NULL, 
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL
);

-- ----------------------------------------
-- Сателлит для hub_store (sat_store_details)
-- ----------------------------------------
CREATE TABLE dv.sat_store_details (
    hk_store        VARCHAR(64) NOT NULL,
    effective_from  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to    TIMESTAMP,
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL,

    store_name      VARCHAR(255),
    address         VARCHAR(255),
    city            VARCHAR(100),
    state           VARCHAR(100),
    postal_code     VARCHAR(20),
    phone           VARCHAR(20),

    PRIMARY KEY (hk_store, effective_from),
    CONSTRAINT fk_sat_store_details
        FOREIGN KEY (hk_store)
        REFERENCES dv.hub_store(hk_store)
);

-- ******************************************************************
-- 4. Линк: Факт аренды (link_rental)
-- ******************************************************************
CREATE TABLE dv.link_rental (
    lk_rental       VARCHAR(64) NOT NULL PRIMARY KEY, -- Hash Key для связи
    hk_customer     VARCHAR(64) NOT NULL,             -- Ссылка на hub_customer
    hk_movie        VARCHAR(64) NOT NULL,             -- Ссылка на hub_movie
    hk_store        VARCHAR(64),
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL,

    -- Связи:
    CONSTRAINT fk_link_rental_customer
        FOREIGN KEY (hk_customer)
        REFERENCES dv.hub_customer(hk_customer),
    CONSTRAINT fk_link_rental_movie
        FOREIGN KEY (hk_movie)
        REFERENCES dv.hub_movie(hk_movie),
    CONSTRAINT fk_link_rental_store
        FOREIGN KEY (hk_store)
        REFERENCES dv.hub_store(hk_store)
);

-- ----------------------------------------
-- Сателлит для link_rental (sat_rental_details)
-- ----------------------------------------
CREATE TABLE dv.sat_rental_details (
    lk_rental       VARCHAR(64) NOT NULL,
    effective_from  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to    TIMESTAMP,
    load_date       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(50) NOT NULL,

    rental_date     DATE,           -- Дата взятия фильма
    return_date     DATE,           -- Дата возврата
    rental_rate     NUMERIC(10,2),  -- Стоимость аренды

    PRIMARY KEY (lk_rental, effective_from),
    CONSTRAINT fk_sat_rental_details
        FOREIGN KEY (lk_rental)
        REFERENCES dv.link_rental(lk_rental)
);

COMMIT;
