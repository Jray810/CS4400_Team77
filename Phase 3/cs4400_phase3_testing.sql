-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase III: Stored Procedures & Views Testing Script

-- Directions:
-- Please reset the database after each test.

USE travel_reservation_service;

-- --------------------------------------------------------------------------
-- Testing
-- --------------------------------------------------------------------------

-- [1a] Test Procedure: register_customer

-- Add new customer (Does not exist in DB, Email Not-Unique Only): Expect 0 row(s) affected
CALL register_customer('aray@tiktok.com', 'Michael', 'Jackson', 'mjackson2021', '111-111-1111', '1111 1111 1111 1111', '111', '2019-01-01', 'USA');
-- Add new customer (Does not exist in DB, Phone Number Not-Unique Only): Expect 0 row(s) affected
CALL register_customer('mjackson@gmail.com', 'Michael', 'Jackson', 'mjackson2021', '404-678-5555', '1111 1111 1111 1111', '111', '2019-01-01', 'USA');
-- Add new customer (Does not exist in DB, Credit Card Number Not-Unique Only): Expect 0 row(s) affected
CALL register_customer('mjackson@gmail.com', 'Michael', 'Jackson', 'mjackson2021', '111-111-1111', '3110 2669 7949 5605', '111', '2019-01-01', 'USA');
-- Add new customer (Does not exist in DB): Expect new entry in accounts, clients, and customer
CALL register_customer('mjackson@gmail.com', 'Michael', 'Jackson', 'mjackson2021', '111-111-1111', '1111 1111 1111 1111', '111', '2019-01-01', 'USA');
SELECT * FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email = C.Email LEFT OUTER JOIN customer AS U ON C.Email = U.Email WHERE A.Email = 'mjackson@gmail.com';

-- Add new customer (Exists as Account only, Account Fields Do Not Match, Key Fields Unique): Expect 0 row(s) affected
CALL register_customer('mmoss1@travelagency.com', 'Bob', 'Ross', 'password12', '222-222-2222', '2222 2222 2222 2222', '222', '2019-01-02', 'USA');
-- Add new customer (Exists as Account only, Account Fields Match, Phone Number Not-Unique Only): Expect 0 row(s) affected
CALL register_customer('mmoss1@travelagency.com', 'Mark', 'Moss', 'password1', '404-678-5555', '2222 2222 2222 2222', '222', '2019-01-02', 'USA');
-- Add new customer (Exists as Account only, Account Fields Match, Credit Card Number Not-Unique Only): Expect 0 row(s) affected
CALL register_customer('mmoss1@travelagency.com', 'Mark', 'Moss', 'password1', '222-222-2222', '3110 2669 7949 5605', '222', '2019-01-02', 'USA');
-- Add new customer (Exists as Account only, Account Fields Match, Key Fields Unique): Expect new entry in clients and customer
CALL register_customer('mmoss1@travelagency.com', 'Mark', 'Moss', 'password1', '222-222-2222', '2222 2222 2222 2222', '222', '2019-01-02', 'USA');
SELECT * FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email = C.Email LEFT OUTER JOIN customer AS U ON C.Email = U.Email WHERE A.Email = 'mmoss1@travelagency.com';

-- Add new customer (Exists as Account and Client, Account Fields Do Not Match, Key Fields Unique): Expect 0 row(s) affected
CALL register_customer('arthurread@gmail.com', 'Peter', 'Parker', 'spidermanRules', '555-234-5678', '3333 3333 3333 3333', '333', '2019-01-03', 'USA');
-- Add new customer (Exists as Account and Client, Client Fields Do Not Match, Key Fields Unique): Expect 0 row(s) affected
CALL register_customer('arthurread@gmail.com', 'Arthur', 'Read', 'password4', '333-333-3333', '3333 3333 3333 3333', '333', '2019-01-03', 'USA');
-- Add new customer (Exists as Account and Client, Account/Client Fields Match, Credit Card Number Not-Unique Only): Expect 0 row(s) affected
CALL register_customer('arthurread@gmail.com', 'Arthur', 'Read', 'password4', '555-234-5678', '3110 2669 7949 5605', '333', '2019-01-03', 'USA');
-- Add new customer (Exists as Account and Client, Account/Client Fields Match, Key Fields Unique): Expect new entry in customer
CALL register_customer('arthurread@gmail.com', 'Arthur', 'Read', 'password4', '555-234-5678', '3333 3333 3333 3333', '333', '2019-01-03', 'USA');
SELECT * FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email = C.Email LEFT OUTER JOIN customer AS U ON C.Email = U.Email WHERE A.Email = 'arthurread@gmail.com';

-- Add new customer (Exists as Account, Client, and Customer, field changes): Expect 0 row(s) affected
CALL register_customer('aray@tiktok.com', 'Peter', 'Parker', 'spidermanRules', '770-234-5678', '3110 2669 7949 5605', '444', '2019-01-04', 'USA');
-- Add new customer (Exists as Account, Client, and Customer, no field changes): Expect 0 row(s) affected
CALL register_customer('aray@tiktok.com', 'Addison', 'Ray', 'password17', '770-234-5678', '3110 2669 7949 5605', '744', '2022-08-01', '');


-- [1b] Test Procedure: register_owner