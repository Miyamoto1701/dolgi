-- ==========================================================
-- Скрипт базы данных аэропорта (airport_db)
-- Включает 6 таблиц, тестовые данные, представление, функцию и процедуру
-- ==========================================================

CREATE DATABASE IF NOT EXISTS airport_db;
USE airport_db;

-- 1. Таблица авиакомпаний
CREATE TABLE airlines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- 2. Таблица самолетов
CREATE TABLE airplanes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    airline_id INT,
    FOREIGN KEY (airline_id) REFERENCES airlines(id) ON DELETE SET NULL
);

-- 3. Таблица рейсов
CREATE TABLE flights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    departure_airport VARCHAR(50) NOT NULL,
    arrival_airport VARCHAR(50) NOT NULL,
    departure_time DATETIME NOT NULL,
    airplane_id INT,
    FOREIGN KEY (airplane_id) REFERENCES airplanes(id) ON DELETE SET NULL
);

-- 4. Таблица пассажиров
CREATE TABLE passengers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(20) NOT NULL UNIQUE
);

-- 5. Таблица билетов
CREATE TABLE tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (flight_id) REFERENCES flights(id) ON DELETE CASCADE,
    FOREIGN KEY (passenger_id) REFERENCES passengers(id) ON DELETE CASCADE
);

-- 6. Таблица персонала (экипаж)
CREATE TABLE crew_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    airline_id INT,
    FOREIGN KEY (airline_id) REFERENCES airlines(id) ON DELETE SET NULL
);

-- ==========================================================
-- Наполнение тестовыми данными
-- ==========================================================
INSERT INTO airlines (name, country) VALUES ('Aeroflot', 'Russia'), ('Emirates', 'UAE');
INSERT INTO airplanes (model, capacity, airline_id) VALUES ('Boeing 737', 150, 1), ('Airbus A380', 500, 2);
INSERT INTO flights (flight_number, departure_airport, arrival_airport, departure_time, airplane_id) 
VALUES ('SU-100', 'SVO', 'LED', '2026-11-20 10:00:00', 1), ('EK-131', 'DXB', 'SVO', '2026-11-21 23:30:00', 2);
INSERT INTO passengers (first_name, last_name, passport_number) VALUES ('Ivan', 'Ivanov', '1234-567890'), ('John', 'Doe', '9876-543210');
INSERT INTO tickets (flight_id, passenger_id, seat_number, price) VALUES (1, 1, '12A', 5500.00), (2, 2, '05B', 45000.00);

-- ==========================================================
-- ПРЕДСТАВЛЕНИЕ (VIEW)
-- Сводное расписание рейсов с названиями авиакомпаний и моделей
-- ==========================================================
CREATE OR REPLACE VIEW view_flight_schedule AS
SELECT 
    f.flight_number AS 'Номер Рейса',
    a.name AS 'Авиакомпания',
    ap.model AS 'Модель Самолета',
    f.departure_airport AS 'Вылет',
    f.arrival_airport AS 'Прилет',
    f.departure_time AS 'Время Вылета'
FROM flights f
JOIN airplanes ap ON f.airplane_id = ap.id
JOIN airlines a ON ap.airline_id = a.id;

-- ==========================================================
-- ФУНКЦИЯ (FUNCTION)
-- Возвращает количество билетов, проданных на конкретный рейс
-- ==========================================================
DELIMITER //

CREATE FUNCTION get_sold_tickets_count(target_flight_id INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE tickets_count INT;
    
    SELECT COUNT(*) INTO tickets_count 
    FROM tickets 
    WHERE flight_id = target_flight_id;
    
    RETURN tickets_count;
END //

DELIMITER ;

-- ==========================================================
-- ПРОЦЕДУРА (STORED PROCEDURE)
-- Добавление нового пассажира в базу данных
-- ==========================================================
DELIMITER //

CREATE PROCEDURE add_new_passenger(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_passport VARCHAR(20)
)
BEGIN
    INSERT INTO passengers (first_name, last_name, passport_number) 
    VALUES (p_first_name, p_last_name, p_passport);
END //

DELIMITER ;
