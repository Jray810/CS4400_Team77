-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase III: Stored Procedures & Views Testing Script

-- Directions:
-- Please reset the database after each test.

USE travel_reservation_service;

-- --------------------------------------------------------------------------
-- Testing
-- --------------------------------------------------------------------------

-- --------------------------------------------------------------------------
-- [1a] Test Procedure: register_customer
-- --------------------------------------------------------------------------
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

-- --------------------------------------------------------------------------
-- [1b] Test Procedure: register_owner
-- --------------------------------------------------------------------------
-- Add new owner (Does not exist in DB, Email Not-Unique Only): Expect 0 row(s) affected
CALL register_owner('aray@tiktok.com', 'Michael', 'Jackson', 'mjackson2021', '111-111-1111');
-- Add new owner (Does not exist in DB, Phone Number Not-Unique Only): Expect 0 row(s) affected
CALL register_owner('mjackson@gmail.com', 'Michael', 'Jackson', 'mjackson2021', '404-678-5555');
-- Add new owner (Does not exist in DB): Expect new entry in accounts, clients, and owners
CALL register_owner('mjackson@gmail.com', 'Michael', 'Jackson', 'mjackson2021', '111-111-1111');
SELECT * FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email = C.Email LEFT OUTER JOIN owners AS O ON C.Email = O.Email WHERE A.Email = 'mjackson@gmail.com';

-- Add new owner (Exists as Account only, Account Fields Do Not Match, Key Fields Unique): Expect 0 row(s) affected
CALL register_owner('mmoss1@travelagency.com', 'Bob', 'Ross', 'password12', '222-222-2222');
-- Add new owner (Exists as Account only, Account Fields Match, Phone Number Not-Unique Only): Expect 0 row(s) affected
CALL register_owner('mmoss1@travelagency.com', 'Mark', 'Moss', 'password1', '404-678-5555');
-- Add new owner (Exists as Account only, Account Fields Match, Key Fields Unique): Expect new entry in clients and owners
CALL register_owner('mmoss1@travelagency.com', 'Mark', 'Moss', 'password1', '222-222-2222');
SELECT * FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email = C.Email LEFT OUTER JOIN owners AS O ON C.Email = O.Email WHERE A.Email = 'mmoss1@travelagency.com';

-- Add new owner (Exists as Account and Client, Account Fields Do Not Match): Expect 0 row(s) affected
CALL register_owner('aray@tiktok.com', 'Peter', 'Parker', 'spidermanRules', '770-234-5678');
-- Add new owner (Exists as Account and Client, Client Fields Do Not Match): Expect 0 row(s) affected
CALL register_owner('aray@tiktok.com', 'Addison', 'Ray', 'password17', '333-333-3333');
-- Add new owner (Exists as Account and Client, Account/Client Fields Match): Expect new entry in owners
CALL register_owner('aray@tiktok.com', 'Addison', 'Ray', 'password17', '770-234-5678');
SELECT * FROM accounts AS A LEFT OUTER JOIN clients AS C ON A.Email = C.Email LEFT OUTER JOIN owners AS O ON C.Email = O.Email WHERE A.Email = 'aray@tiktok.com';

-- Add new owner (Exists as Account, Client, and Owner, field changes): Expect 0 row(s) affected
CALL register_owner('arthurread@gmail.com', 'Peter', 'Parker', 'spidermanRules', '555-234-5678');
-- Add new owner (Exists as Account, Client, and Owner, no field changes): Expect 0 row(s) affected
CALL register_owner('arthurread@gmail.com', 'Arthur', 'Read', 'password4', '555-234-5678');

-- --------------------------------------------------------------------------
-- [1c] Test Procedure: remove_owner
-- --------------------------------------------------------------------------
-- Remove owner (Owner does not exist): Expect 0 row(s) affected
CALL remove_owner('mjackson@gmail.com');
-- Remove owner (Owner exists, has listed properties): Expect 0 row(s) affected
CALL remove_owner('arthurread@gmail.com');
-- Remove owner (Owner exists, no listed properties, also a customer): Expect removal from owners table only
CALL register_owner('aray@tiktok.com', 'Addison', 'Ray', 'password17', '770-234-5678');
SELECT * FROM customer AS C LEFT OUTER JOIN owners AS O ON C.Email = O.Email WHERE C.Email = 'aray@tiktok.com';
CALL remove_owner('aray@tiktok.com');
SELECT * FROM customer AS C LEFT OUTER JOIN owners AS O ON C.Email = O.Email WHERE C.Email = 'aray@tiktok.com';
-- Remove owner (Owner exists, no listed properties, not a customer): Expect removal from owners, clients, and accounts tables
INSERT INTO customers_rate_owners(Customer, Owner_Email, Score) VALUES ('aray@tiktok.com', 'jwayne@gmail.com', 5);
INSERT INTO owners_rate_customers(Owner_Email, Customer, Score) VALUES ('jwayne@gmail.com', 'aray@tiktok.com', 5);
SELECT * FROM owners AS O LEFT OUTER JOIN property AS P ON O.Email = P.Owner_Email LEFT OUTER JOIN customers_rate_owners AS A ON O.Email = A.Owner_Email LEFT OUTER JOIN owners_rate_customers AS B ON O.Email = B.Owner_Email WHERE O.Email = 'jwayne@gmail.com';
CALL remove_owner('jwayne@gmail.com');
SELECT * FROM owners AS O LEFT OUTER JOIN property AS P ON O.Email = P.Owner_Email LEFT OUTER JOIN customers_rate_owners AS A ON O.Email = A.Owner_Email LEFT OUTER JOIN owners_rate_customers AS B ON O.Email = B.Owner_Email WHERE O.Email = 'jwayne@gmail.com';

-- --------------------------------------------------------------------------
-- [2a] Test Procedure: schedule_flight
-- --------------------------------------------------------------------------
-- Schedule Flight (To_Airport same as From_Airport): Expect 0 row(s) affected
CALL schedule_flight(2, 'Delta Airlines', 'ATL', 'ATL', '10:00:00', '12:00:00', '2021-12-05', 400.00, 200, '2021-12-03');
-- Schedule Flight (Flight date today): Expect 0 row(s) affected
CALL schedule_flight(2, 'Delta Airlines', 'ATL', 'JFK', '10:00:00', '12:00:00', '2021-12-03', 400.00, 200, '2021-12-03');
-- Schedule Flight (Flight date yesterday): Expect 0 row(s) affected
CALL schedule_flight(2, 'Delta Airlines', 'ATL', 'JFK', '10:00:00', '12:00:00', '2021-12-02', 400.00, 200, '2021-12-03');
-- Schedule Flight (Combination exists): Expect 0 row(s) affected
CALL schedule_flight(1, 'Delta Airlines', 'ATL', 'JFK', '10:00:00', '12:00:00', '2021-12-05', 400.00, 200, '2021-12-03');
-- Schedule Flight (Combination unique): Expect changes to flight table
CALL schedule_flight(2, 'Delta Airlines', 'ATL', 'JFK', '10:00:00', '12:00:00', '2021-12-05', 400.00, 200, '2021-12-03');
SELECT * FROM flight;

-- --------------------------------------------------------------------------
-- [2b] Test Procedure: remove_flight
-- --------------------------------------------------------------------------
-- Remove flight (Date is today): Expect 0 row(s) affected
CALL remove_flight(1, 'Delta Airlines', '2021-10-18');
-- Remove flight (Date is yesterday): Expect 0 row(s) affected
CALL remove_flight(1, 'Delta Airlines', '2021-10-19');
-- Remove flight (Date is valid): Expect changes to flight table and book table
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;
CALL remove_flight(1, 'Delta Airlines', '2021-10-17');
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;

-- --------------------------------------------------------------------------
-- [3a] Test Procedure: book_flight
-- --------------------------------------------------------------------------
-- Book flight (Date is today): Expect 0 row(s) affected
CALL book_flight('hwmit@gmail.com', 4, 'United Airlines', 97, '2021-10-18');
-- Book flight (Date is yesterday): Expect 0 row(s) affected
CALL book_flight('hwmit@gmail.com', 4, 'United Airlines', 97, '2021-10-19');
-- Book flight (Customer has non-cancelled flight): Expect 0 row(s) affected
CALL book_flight('aray@tiktok.com', 4, 'United Airlines', 95, '2021-10-17');
-- Book flight (Insufficient remaining seats): Expect 0 row(s) affected
CALL book_flight('hwmit@gmail.com', 4, 'United Airlines', 97, '2021-10-17');
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;
-- Book flight (Previous Booking Cancelled): Expect 0 row(s) affected
CALL book_flight('hwmit@gmail.com', 2, 'Southwest Airlines', 124, '2021-10-17');
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;
-- Book flight (Booking is new): Expect book table update with new booking
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;
CALL book_flight('hwmit@gmail.com', 7, 'WestJet', 95, '2021-10-17');
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;
-- Book flight (Booking exists): Expect book table existing booking to update
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;
CALL book_flight('hwmit@gmail.com', 7, 'WestJet', 1, '2021-10-17');
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;

-- --------------------------------------------------------------------------
-- [3b] Test Procedure: cancel_flight_booking
-- --------------------------------------------------------------------------
-- Cancel flight booking (Booking does not exist): Expect 0 row(s) affected
CALL cancel_flight_booking('aray@tiktok.com', 4, 'United Airlines', '2021-10-17');
-- Cancel flight booking (Booking exists, flight is today): Expect 0 row(s) affected
CALL cancel_flight_booking('aray@tiktok.com', 1, 'Delta Airlines', '2021-10-18');
-- Cancel flight booking (Booking exists, flight is yesterday): Expect 0 row(s) affected
CALL cancel_flight_booking('aray@tiktok.com', 1, 'Delta Airlines', '2021-10-19');
-- Cancel flight booking (Booking exists, flight is future, was previously cancelled): Expect 0 row(s) affected
CALL cancel_flight_booking('hwmit@gmail.com', 2, 'Southwest Airlines', '2021-10-17');
-- Cancel flight booking (Booking exists, flight is future, was previously cancelled): Expect book table updated
CALL cancel_flight_booking('aray@tiktok.com', 1, 'Delta Airlines', '2021-10-17');
SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Airline_Name = F.Airline_Name AND B.Flight_Num = F.Flight_Num;

-- --------------------------------------------------------------------------
-- [4a] Test Procedure: add_property
-- --------------------------------------------------------------------------
SELECT * FROM property;
-- Add property (Property Name & Owner Not Unique): Expect 0 row(s) affected
CALL add_property('Atlanta Great Property', 'scooper3@gmail.com', 'hello', 1, 100.00, '350 Ferst Dr', 'ATL', 'GA', '30332', 'ATL', 10);
-- Add property (Address Not Unique): Expect 0 row(s) affected
CALL add_property('Georgia Tech', 'gburdell3@gmail.com', 'hello', 1, 100.00, 'North Ave', 'ATL', 'GA', '30008', 'ATL', 10);
-- Add property (Nearest Airport Id invalid): Expect property table updated
CALL add_property('Georgia Tech', 'gburdell3@gmail.com', 'hello', 1, 100.00, '350 Ferst Dr', 'ATL', 'GA', '30332', 'BER', 10);
SELECT * FROM property AS P LEFT OUTER JOIN is_close_to AS I ON P.Property_Name = I.Property_Name AND P.Owner_Email = I.Owner_Email;
-- Add property (Nearest Airport Id not given): Expect property table updated
CALL add_property('Georgia Tech', 'gburdell3@gmail.com', 'hello', 1, 100.00, '350 Ferst Dr', 'ATL', 'GA', '30332', NULL, 10);
SELECT * FROM property AS P LEFT OUTER JOIN is_close_to AS I ON P.Property_Name = I.Property_Name AND P.Owner_Email = I.Owner_Email;
-- Add property (Distance invalid): Expect property table updated
CALL add_property('Georgia Tech', 'gburdell3@gmail.com', 'hello', 1, 100.00, '350 Ferst Dr', 'ATL', 'GA', '30332', 'ATL', -1);
SELECT * FROM property AS P LEFT OUTER JOIN is_close_to AS I ON P.Property_Name = I.Property_Name AND P.Owner_Email = I.Owner_Email;
-- Add property (Distance not given): Expect property table updated
CALL add_property('Georgia Tech', 'gburdell3@gmail.com', 'hello', 1, 100.00, '350 Ferst Dr', 'ATL', 'GA', '30332', 'ATL', NULL);
SELECT * FROM property AS P LEFT OUTER JOIN is_close_to AS I ON P.Property_Name = I.Property_Name AND P.Owner_Email = I.Owner_Email;
-- Add property (All valid): Expect property and is_close_to table updated
CALL add_property('Georgia Tech', 'gburdell3@gmail.com', 'hello', 1, 100.00, '350 Ferst Dr', 'ATL', 'GA', '30332', 'ATL', 10);
SELECT * FROM property AS P LEFT OUTER JOIN is_close_to AS I ON P.Property_Name = I.Property_Name AND P.Owner_Email = I.Owner_Email;

-- --------------------------------------------------------------------------
-- [4b] Test Procedure: remove_property
-- --------------------------------------------------------------------------
-- Remove property (Today is beginning of reservation): Expect 0 row(s) affected
CALL remove_property('New York City Property', 'cbing10@gmail.com', '2021-10-18');
-- Remove property (Today is middle of reservation): Expect 0 row(s) affected
CALL remove_property('New York City Property', 'cbing10@gmail.com', '2021-10-20');
-- Remove property (Today is end of reservation): Expect 0 row(s) affected
CALL remove_property('New York City Property', 'cbing10@gmail.com', '2021-10-23');
-- Remove property (All valid): Expect property, reservations, reviews, amenity, and is_close_to to be updated
CALL remove_property('New York City Property', 'cbing10@gmail.com', '2021-10-31');
-- Remove property (Today is middle of cancelled reservation): Expect property, reservations, reviews, amenity, and is_close_to to be updated
CALL remove_property('New York City Property', 'cbing10@gmail.com', '2021-11-04');
SELECT * FROM property AS P NATURAL JOIN reserve AS R WHERE Property_Name = 'New York City Property';
SELECT * FROM property AS P NATURAL JOIN review AS R WHERE Property_Name = 'New York City Property';
SELECT * FROM property AS P NATURAL JOIN amenity AS R WHERE Property_Name = 'New York City Property';
SELECT * FROM is_close_to WHERE Property_Name = 'New York City Property';

-- --------------------------------------------------------------------------
-- [5a] Test Procedure: reserve_property
-- --------------------------------------------------------------------------
-- Reserve property (Non-unique reservation Uncancelled): Expect 0 row(s) affected
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com', '2021-10-23', '2021-10-24', 2, '2021-10-22');
-- Reserve property (Non-unique reservation Cancelled): Expect 0 row(s) affected
CALL reserve_property('Chicago Romantic Getaway', 'mj23@gmail.com', 'aray@tiktok.com', '2021-10-23', '2021-10-24', 2, '2021-10-22');
-- Reserve property (Start Date is today): Expect 0 row(s) affected
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'cbing10@gmail.com', '2021-10-26', '2021-10-28', 2, '2021-10-26');
-- Reserve property (Start Date is yesterday): Expect 0 row(s) affected
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'cbing10@gmail.com', '2021-10-26', '2021-10-28', 2, '2021-10-27');
-- Reserve property (Overlapping reservations): Expect 0 row(s) affected
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'cbing10@gmail.com', '2021-10-25', '2021-10-28', 2, '2021-10-24');
-- Reserve property (Insufficient capacity on first day): Expect 0 row(s) affected
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'mgeller5@gmail.com', '2021-10-22', '2021-10-28', 3, '2021-10-20');
-- Reserve property (Insufficient capacity on middle day): Expect 0 row(s) affected
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'mgeller5@gmail.com', '2021-10-18', '2021-10-23', 3, '2021-10-17');
-- Reserve property (Insufficient capacity on last day): Expect 0 row(s) affected
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'mgeller5@gmail.com', '2021-10-21', '2021-10-22', 3, '2021-10-20');
-- Reserve property (All valid): Reserve table updated
CALL reserve_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'mgeller5@gmail.com', '2021-10-21', '2021-10-22', 2, '2021-10-20');
SELECT * FROM property AS P NATURAL JOIN reserve AS R WHERE Property_Name = 'Beautiful San Jose Mansion';

-- --------------------------------------------------------------------------
-- [5b] Test Procedure: cancel_property_reservation
-- --------------------------------------------------------------------------
-- Cancel property reservation (Reservation does not exist): Expect 0 row(s) affected
CALL cancel_property_reservation('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'mgeller5@gmail.com', '2021-12-03');
-- Cancel property reservation (Already Cancelled): Expect 0 row(s) affected
CALL cancel_property_reservation('Family Beach House', 'ellie2@gmail.com', 'hwmit@gmail.com', '2021-10-17');
-- Cancel property reservation (Reservation ends today): Expect 0 row(s) affected
CALL cancel_property_reservation('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com', '2021-10-22');
-- Cancel property reservation (Reservation begins today): Expect 0 row(s) affected
CALL cancel_property_reservation('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com', '2021-10-19');
-- Cancel property reservation (Reservation already ended): Expect 0 row(s) affected
CALL cancel_property_reservation('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com', '2021-10-23');
-- Cancel property reservation (All valid): Expect reserve table updated
CALL cancel_property_reservation('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com', '2021-10-18');
SELECT * FROM property AS P NATURAL JOIN reserve AS R WHERE Property_Name = 'Beautiful San Jose Mansion';

-- --------------------------------------------------------------------------
-- [5c] Test Procedure: customer_review_property
-- --------------------------------------------------------------------------
-- Customer review property (Existing review): Expect 0 row(s) affected
CALL customer_review_property('Beautiful San Jose Mansion', 'arthurread@gmail.com', 'tswift@gmail.com', 'Nice!', 5, '2021-10-23');
-- Customer review property (Was Cancelled): Expect 0 row(s) affected
CALL customer_review_property('Family Beach House', 'ellie2@gmail.com', 'hwmit@gmail.com', 'Nice!', 5, '2021-10-29');
-- Customer review property (Today is before reservation): Expect 0 row(s) affected
CALL customer_review_property('Beautiful Beach Property', 'msmith5@gmail.com', 'cbing10@gmail.com', 'Nice!', 5, '2021-10-17');
-- Customer review property (Today is first day of reservation): Expect review table update
CALL customer_review_property('Beautiful Beach Property', 'msmith5@gmail.com', 'cbing10@gmail.com', 'Nice!', 5, '2021-10-18');
SELECT * FROM property AS P NATURAL JOIN reserve AS R LEFT OUTER JOIN review AS Q ON P.Property_Name = Q.Property_Name;
-- Customer review property (Today is after first day of reservation): Expect review table update
CALL customer_review_property('Beautiful Beach Property', 'msmith5@gmail.com', 'cbing10@gmail.com', 'Nice!', 5, '2021-10-20');
SELECT * FROM property AS P NATURAL JOIN reserve AS R LEFT OUTER JOIN review AS Q ON P.Property_Name = Q.Property_Name;

-- --------------------------------------------------------------------------
-- [5e] Test Procedure: view_individual_property_reservations
-- --------------------------------------------------------------------------
-- Test for nonexistent property (Should be empty table)
CALL view_individual_property_reservations('Georgia Tech', 'cbing10@gmail.com');
SELECT * FROM view_individual_property_reservations;
-- Test it for New York City Property
CALL view_individual_property_reservations('New York City Property', 'cbing10@gmail.com');
SELECT * FROM view_individual_property_reservations;
-- Should look similar to
SELECT R.Property_Name, Start_Date, End_Date, R.Customer, Phone_Number, Num_Guests, Score, Content FROM reserve AS R INNER JOIN clients AS C ON R.Customer = C.Email RIGHT OUTER JOIN review AS Q ON R.Customer = Q.Customer WHERE R.Property_Name = 'New York City Property';
SELECT Customer, Cost, Num_Guests, Start_Date, End_Date, Was_Cancelled FROM property NATURAL JOIN reserve WHERE Property_Name = 'New York City Property';
-- Test it for House near Georgia Tech
CALL view_individual_property_reservations('House near Georgia Tech', 'swilson@gmail.com');
SELECT * FROM view_individual_property_reservations;
-- Should look similar to
SELECT R.Property_Name, Start_Date, End_Date, R.Customer, Phone_Number, Num_Guests, Score, Content FROM reserve AS R INNER JOIN clients AS C ON R.Customer = C.Email RIGHT OUTER JOIN review AS Q ON R.Customer = Q.Customer WHERE R.Property_Name = 'House near Georgia Tech';
SELECT Customer, Cost, Num_Guests, Start_Date, End_Date, Was_Cancelled FROM property NATURAL JOIN reserve WHERE Property_Name = 'House near Georgia Tech';

-- --------------------------------------------------------------------------
-- [6b] Test Procedure: owner_rates_customer
-- --------------------------------------------------------------------------
CALL owner_rates_customer('msmith5@gmail.com', 'cbing10@gmail.com', 4, '2021-10-18');
-- Owner Rates Customer (All Valid): Expect add to owners_rate_customers table
CALL owner_rates_customer('msmith5@gmail.com', 'tswift@gmail.com', 4, '2021-10-18'); 
-- Owner Rates Customer (Customer hasn't stayed at owner's property): Expect 0 row(s) affected
CALL owner_rates_customer('msmith5@gmail.com', 'fuiya@gmail.com', 4, '2021-10-18'); 
-- Owner Rates Customer (Customer doesn't exist): Expect 0 row(s) affected
CALL owner_rates_customer('fuiya@gmail.com', 'tswift@gmail.com', 4, '2021-10-18'); 
-- Owner Rates Customer (Owner doesn't exist): Expect 0 row(s) affected
CALL owner_rates_customer('msmith5@gmail.com', 'cbing10@gmail.com', 4, '2021-10-18');
-- Owner Rates Customer (Tries to rate the same customer twice): Expect 1 row(s) affected
CALL owner_rates_customer('msmith5@gmail.com', 'cbing10@gmail.com', 4, '2021-10-18');

-- --------------------------------------------------------------------------
-- [9a] Test Procedure: process_date
-- --------------------------------------------------------------------------

CALL process_date('2021-10-19');
-- Process Date (All Valid): Expect 4 row(s) affected
CALL process_date('2021-10-18');
-- Process Date (All Valid): Expect 3 row(s) affected
CALL process_date('2021-10-20');
-- Process Date (No Bookings): Expect 0 row(s) affected
CALL process_date('2021-10-10');
-- Process Date (No Flights): Expect 0 row(s) affected
