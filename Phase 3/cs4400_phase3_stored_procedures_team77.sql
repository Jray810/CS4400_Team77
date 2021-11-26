-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase III: Stored Procedures & Views [v0] Tuesday, November 9, 2021 @ 12:00am EDT

-- Team 77
-- Neil Barry (nbarry7)
-- Owen Cardwell (ocardwell3)
-- Raymond Jia (rjia38)

-- Directions:
-- Please follow all instructions for Phase III as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.

-- --------------------------------------------------------------------------
-- Custom Functions
-- --------------------------------------------------------------------------
-- For calculating the number of seats booked on a given flight
DROP FUNCTION IF EXISTS seats_booked;
delimiter //
CREATE FUNCTION seats_booked (
    i_airline_name VARCHAR(50),
	i_flight_num CHAR(5)
)
RETURNS INT
DETERMINISTIC
sp_main: BEGIN
	DECLARE o_num_seats INT;
	DECLARE tmp_count INT;
	SELECT SUM(Num_Seats) FROM book WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name AND Was_Cancelled = 0 INTO tmp_count;
	SET o_num_seats = IFNULL(tmp_count, 0);
    RETURN (o_num_seats);
END //
delimiter ;

-- For extracting the date of a given flight
DROP FUNCTION IF EXISTS fl_date;
delimiter //
CREATE FUNCTION fl_date (
	i_airline_name VARCHAR(50),
    i_flight_num CHAR(5)
)
RETURNS DATE
DETERMINISTIC
sp_main: BEGIN
	DECLARE flight_date DATE;
    SELECT Flight_Date FROM flight WHERE Flight_Num = i_flight_num AND Airline_Name = i_airline_name INTO flight_date;
    RETURN (flight_date);
END //
delimiter ;

-- --------------------------------------------------------------------------
-- End Custom Functions Section
-- --------------------------------------------------------------------------


-- ID: 1a
-- Name: register_customer
drop procedure if exists register_customer;
delimiter //
create procedure register_customer (
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12),
    in i_cc_number varchar(19),
    in i_cvv char(3),
    in i_exp_date date,
    in i_location varchar(50)
) 
sp_main: begin
-- TODO: Implement your solution here
	-- Check if user exists as both Account and Client but not as a Customer yet
	IF i_email IN (SELECT Email FROM accounts) AND i_phone_number IN (SELECT Phone_Number FROM clients) AND i_cc_number NOT IN (SELECT CcNumber FROM customer)
		THEN INSERT INTO customer (Email, CcNumber, Cvv, Exp_Date, Location) VALUES (i_email, i_cc_number, i_cvv, i_exp_date, i_location);
        LEAVE sp_main;
    END IF;
    -- Check if user does not exist in the system at all
    IF i_email NOT IN (SELECT Email FROM accounts) AND i_phone_number NOT IN (SELECT Phone_Number FROM clients) AND i_cc_number NOT IN (SELECT CcNumber FROM customer)
		THEN INSERT INTO accounts (Email, First_Name, Last_Name, Pass) VALUES (i_email, i_first_name, i_last_name, i_password);
		INSERT INTO clients (Email, Phone_Number) VALUES (i_email, i_phone_number);
		INSERT INTO customer (Email, CcNumber, Cvv, Exp_Date, Location) VALUES (i_email, i_cc_number, i_cvv, i_exp_date, i_location);
	END IF;
end //
delimiter ;


-- ID: 1b
-- Name: register_owner
drop procedure if exists register_owner;
delimiter //
create procedure register_owner (
    in i_email varchar(50),
    in i_first_name varchar(100),
    in i_last_name varchar(100),
    in i_password varchar(50),
    in i_phone_number char(12)
) 
sp_main: begin
-- TODO: Implement your solution here
	-- Check if user exists as both Account and Client but not as an Owner yet
	IF i_email IN (SELECT Email FROM accounts) AND i_phone_number IN (SELECT Phone_Number FROM clients) AND i_email NOT IN (SELECT Email FROM owners)
		THEN INSERT INTO owners (Email) VALUES (i_email);
        LEAVE sp_main;
	END IF;
    -- Check if user does not exist in the system at all
    IF i_email NOT IN (SELECT Email FROM accounts) AND i_phone_number NOT IN (SELECT Phone_Number FROM clients)
		THEN INSERT INTO accounts (Email, First_Name, Last_Name, Pass) VALUES (i_email, i_first_Name, i_last_name, i_password);
        INSERT INTO clients (Email, Phone_Number) VALUES (i_email, i_phone_number);
        INSERT INTO owners (Email) VALUES (i_email);
	END IF;
end //
delimiter ;


-- ID: 1c
-- Name: remove_owner
drop procedure if exists remove_owner;
delimiter //
create procedure remove_owner ( 
    in i_owner_email varchar(50)
)
sp_main: begin
-- TODO: Implement your solution here
	-- Check if owner exists
	IF i_owner_email NOT IN (SELECT Email FROM owners)
		THEN LEAVE sp_main;
	END IF;
    -- Check if owner has listed properties
	IF i_owner_email IN (SELECT Owner_Email FROM property)
		THEN LEAVE sp_main;
	END IF;
    -- Check if owner exists as a customer
    IF i_owner_email IN (SELECT Email FROM customer)
		THEN DELETE FROM owners WHERE Email = i_owner_email;
        LEAVE sp_main;
	END IF;
    -- Check if owner only exists as an owner
    IF i_owner_email NOT IN (SELECT Email FROM customer)
		THEN DELETE FROM accounts WHERE Email = i_owner_email;
	END IF;
end //
delimiter ;


-- ID: 2a
-- Name: schedule_flight
drop procedure if exists schedule_flight;
delimiter //
create procedure schedule_flight (
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_from_airport char(3),
    in i_to_airport char(3),
    in i_departure_time time,
    in i_arrival_time time,
    in i_flight_date date,
    in i_cost decimal(6, 2),
    in i_capacity int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here
	-- Check if to_airport and from_airport are the same
    IF i_from_airport = i_to_airport
		THEN LEAVE sp_main;
	END IF;
    -- Check if flight date is in the future
    IF i_flight_date <= i_current_date
		THEN LEAVE sp_main;
	END IF;
    -- Check if Airline and Flight Number combination already exists
    IF (i_airline_name, i_flight_num) IN (SELECT Airline_Name, Flight_Num FROM flight)
		THEN LEAVE sp_main;
	END IF;
    -- Add Airline and Flight Number combination
    INSERT INTO flight (Flight_Num, Airline_Name, From_Airport, To_Airport, Departure_Time, Arrival_Time, Flight_Date, Cost, Capacity)
		VALUES (i_flight_num, i_airline_name, i_from_airport, i_to_airport, i_departure_time, i_arrival_time, i_flight_date, i_cost, i_capacity);
end //
delimiter ;


-- ID: 2b
-- Name: remove_flight
drop procedure if exists remove_flight;
delimiter //
create procedure remove_flight ( 
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
) 
sp_main: begin
-- TODO: Implement your solution here
    -- Check departure date and remove flight and bookings
    IF EXISTS(SELECT * FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Flight_Date > i_current_date)
		THEN DELETE FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num;
        DELETE FROM book WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num;
	END IF;
end //
delimiter ;


-- ID: 3a
-- Name: book_flight
drop procedure if exists book_flight;
delimiter //
create procedure book_flight (
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_num_seats int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here
	-- Check number of seats left is sufficient and flight date is valid
    IF NOT EXISTS(SELECT * FROM flight WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND i_num_seats <= capacity - seats_booked(Airline_Name, Flight_Num) AND Flight_Date > i_current_date)
		THEN LEAVE sp_main;
	END IF;
    -- Check if customer already has a flight today (that is not the desired flight)
    IF EXISTS(SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Flight_Num = F.Flight_Num AND B.Airline_Name = F.Airline_Name WHERE B.Customer = i_customer_email AND NOT (B.Airline_Name = i_airline_name AND B.Flight_Num = i_flight_num) AND B.Was_Cancelled = 0 AND F.Flight_Date = fl_date(i_airline_name, i_flight_date))
		THEN LEAVE sp_main;
	END IF;
    -- Check if customer already cancelled a booking for this flight
    IF EXISTS(SELECT * FROM book WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Customer = i_customer_email AND Was_Cancelled = 1)
		THEN LEAVE sp_main;
	END IF;
    -- Check if customer has a valid booking for this flight
    IF EXISTS(SELECT * FROM book WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Customer = i_customer_email AND Was_Cancelled = 0)
		THEN UPDATE book SET Num_Seats = Num_Seats + i_num_seats WHERE Airline_Name = i_airline_name AND Flight_Num = i_flight_num AND Customer = i_customer_email;
        LEAVE sp_main;
	END IF;
	-- No flights booked yet on this day
    INSERT INTO book (Customer, Flight_Num, Airline_Name, Num_Seats, Was_Cancelled) VALUES (i_customer_email, i_flight_num, i_airline_Name, i_num_seats, 0);
end //
delimiter ;

-- ID: 3b
-- Name: cancel_flight_booking
drop procedure if exists cancel_flight_booking;
delimiter //
create procedure cancel_flight_booking ( 
    in i_customer_email varchar(50),
    in i_flight_num char(5),
    in i_airline_name varchar(50),
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here
	IF EXISTS(SELECT * FROM book AS B LEFT OUTER JOIN flight AS F ON B.Flight_Num = F.Flight_Num AND B.Airline_Name = F.Airline_Name WHERE B.Customer = i_customer_email AND B.Flight_Num = i_flight_num AND B.Airline_Name AND i_airline_name AND i_current_date < F.Flight_Date)
		THEN UPDATE book SET Was_Cancelled = 1 WHERE Customer = i_customer_email AND Flight_Num = i_flight_num AND Airline_Name = i_airline_name;
	END IF;
end //
delimiter ;


-- ID: 3c
-- Name: view_flight
create or replace view view_flight (
    flight_id,
    flight_date,
    airline,
    destination,
    seat_cost,
    num_empty_seats,
    total_spent
) as
-- TODO: replace this select query with your solution
SELECT Flight_Num, Flight_Date, Airline_Name, To_Airport, Cost, Capacity - seats_booked(Airline_Name, Flight_Num), Cost * seats_booked(Airline_Name, Flight_Num) FROM flight;

-- ID: 4a
-- Name: add_property
drop procedure if exists add_property;
delimiter //
create procedure add_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_description varchar(500),
    in i_capacity int,
    in i_cost decimal(6, 2),
    in i_street varchar(50),
    in i_city varchar(50),
    in i_state char(2),
    in i_zip char(5),
    in i_nearest_airport_id char(3),
    in i_dist_to_airport int
) 
sp_main: begin
-- TODO: Implement your solution here
	-- Check if address is unique
    IF EXISTS(SELECT * FROM property WHERE Street = i_street AND City = i_city AND State = i_state AND Zip = i_zip)
		THEN LEAVE sp_main;
	END IF;
    -- Check if peroperty name and owner name unique
    IF NOT EXISTS(SELECT * FROM property WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email)
		THEN INSERT INTO property (Property_Name, Owner_Email, Descr, Capacity, Cost, Street, City, State, Zip)
			VALUES (i_property_name, i_owner_email, i_description, i_capacity, i_cost, i_street, i_city, i_state, i_zip);
		IF EXISTS(SELECT * FROM airport WHERE Airport_Id = i_nearest_airport_id)
			THEN INSERT INTO is_close_to (Property_Name, Owner_Email, Airport, Distance) VALUES (i_property_name, i_owner_email, i_nearest_airport_id, i_dist_to_airport);
		END IF;
	END IF;            
end //
delimiter ;


-- ID: 4b
-- Name: remove_property
drop procedure if exists remove_property;
delimiter //
create procedure remove_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here
    -- Check if a reservation currently exists
    IF EXISTS(SELECT * FROM reserve WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email AND i_current_date BETWEEN Start_Date AND END_DATE)
		THEN LEAVE sp_main;
	END IF;
    -- Perform deletion
    DELETE FROM property WHERE Property_Name = i_property_name AND Owner_Email = i_owner_email;
end //
delimiter ;


-- ID: 5a
-- Name: reserve_property
drop procedure if exists reserve_property;
delimiter //
create procedure reserve_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_start_date date,
    in i_end_date date,
    in i_num_guests int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

end //
delimiter ;


-- ID: 5b
-- Name: cancel_property_reservation
drop procedure if exists cancel_property_reservation;
delimiter //
create procedure cancel_property_reservation (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

end //
delimiter ;


-- ID: 5c
-- Name: customer_review_property
drop procedure if exists customer_review_property;
delimiter //
create procedure customer_review_property (
    in i_property_name varchar(50),
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_content varchar(500),
    in i_score int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here
    
end //
delimiter ;


-- ID: 5d
-- Name: view_properties
create or replace view view_properties (
    property_name, 
    average_rating_score, 
    description, 
    address, 
    capacity, 
    cost_per_night
) as
-- TODO: replace this select query with your solution
SELECT Property_Name, 'col2', Descr, CONCAT(Street, ', ', City, ', ', State, ', ', Zip), Capacity, Cost FROM property;


-- ID: 5e
-- Name: view_individual_property_reservations
drop procedure if exists view_individual_property_reservations;
delimiter //
create procedure view_individual_property_reservations (
    in i_property_name varchar(50),
    in i_owner_email varchar(50)
)
sp_main: begin
    drop table if exists view_individual_property_reservations;
    create table view_individual_property_reservations (
        property_name varchar(50),
        start_date date,
        end_date date,
        customer_email varchar(50),
        customer_phone_num char(12),
        total_booking_cost decimal(6,2),
        rating_score int,
        review varchar(500)
    ) as
    -- TODO: replace this select query with your solution
    select 'col1', 'col2', 'col3', 'col4', 'col5', 'col6', 'col7', 'col8' from reserve;

end //
delimiter ;


-- ID: 6a
-- Name: customer_rates_owner
drop procedure if exists customer_rates_owner;
delimiter //
create procedure customer_rates_owner (
    in i_customer_email varchar(50),
    in i_owner_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

end //
delimiter ;


-- ID: 6b
-- Name: owner_rates_customer
drop procedure if exists owner_rates_customer;
delimiter //
create procedure owner_rates_customer (
    in i_owner_email varchar(50),
    in i_customer_email varchar(50),
    in i_score int,
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here

end //
delimiter ;


-- ID: 7a
-- Name: view_airports
create or replace view view_airports (
    airport_id, 
    airport_name, 
    time_zone, 
    total_arriving_flights, 
    total_departing_flights, 
    avg_departing_flight_cost
) as
-- TODO: replace this select query with your solution
SELECT Airport_Id, Airport_Name, Time_Zone, 'col4', 'col5', 'col6' FROM airport;

-- ID: 7b
-- Name: view_airlines
create or replace view view_airlines (
    airline_name, 
    rating, 
    total_flights, 
    min_flight_cost
) as
-- TODO: replace this select query with your solution
SELECT Airline_Name, Rating, 'col3', 'col4' FROM airline;


-- ID: 8a
-- Name: view_customers
create or replace view view_customers (
    customer_name, 
    avg_rating, 
    location, 
    is_owner, 
    total_seats_purchased
) as
-- TODO: replace this select query with your solution
-- view customers
SELECT CONCAT(First_Name, ' ', Last_Name), 'col2', 'col3', 'col4', 'col5' FROM customer AS C INNER JOIN accounts AS A ON C.Email = A.Email ORDER BY First_Name ASC;

-- ID: 8b
-- Name: view_owners
create or replace view view_owners (
    owner_name, 
    avg_rating, 
    num_properties_owned, 
    avg_property_rating
) as
-- TODO: replace this select query with your solution
SELECT CONCAT(First_Name, ' ', Last_Name), 'col2', 'col3', 'col4' FROM owners AS O INNER JOIN accounts AS A ON O.Email = A.Email ORDER BY First_Name ASC;


-- ID: 9a
-- Name: process_date
drop procedure if exists process_date;
delimiter //
create procedure process_date ( 
    in i_current_date date
)
sp_main: begin
-- TODO: Implement your solution here
    
end //
delimiter ;
