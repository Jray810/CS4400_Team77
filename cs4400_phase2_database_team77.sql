-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase II: Create Table & Insert Statements [v0] Thursday, October 14, 2021 @ 2:00pm EDT

-- Team 77
-- Neil Barry (nbarry7)
-- Owen Cardwell (ocardwell3)
-- Raymond Jia (rjia38)

-- Directions:
-- Please follow all instructions for Phase II as listed on Canvas.
-- Fill in the team number and names and GT usernames for all members above.
-- Create Table statements must be manually written, not taken from an SQL Dump file.
-- This file must run without error for credit.

-- ------------------------------------------------------
-- CREATE TABLE STATEMENTS AND INSERT STATEMENTS BELOW
-- ------------------------------------------------------


DROP DATABASE IF EXISTS travel_reservations;
CREATE DATABASE IF NOT EXISTS travel_reservations;
USE travel_reservations;

-- Table structure for table airline
DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
	name VARCHAR(50) NOT NULL,
    rating DECIMAL(2, 1) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    PRIMARY KEY (name)
) ENGINE=InnoDB;

-- Dumping data for table airline
INSERT INTO airline VALUES
('Delta Airlines',4.7),
('Southwest Airlines',4.4),
('American Airlines',4.6),
('United Airlines',4.2),
('JetBlue Airways',3.6),
('Spirit Airlines',3.3),
('WestJet',3.9),
('Interjet',3.7);

-- Table structure for table airport
DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
	airport_ID CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    time_zone CHAR(5) NOT NULL,
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR (2) NOT NULL,
    zip CHAR(5) NOT NULL,
    PRIMARY KEY (airport_ID),
    KEY (name, street, city, state, zip)
) ENGINE=InnoDB;

-- Dumping data for table airport
INSERT INTO airport VALUES
('ATL','Atlanta Hartsfield Jackson Airport','EST','6000 N Terminal Pkwy','Atlanta','GA','30320'),
('JFK','John F Kennedy International Airport','EST','455 Airport Ave','Queens','NY','11430'),
('LGA','Laguardia Airport','EST','790 Airport St','Queens','NY','11371'),
('LAX','Lost Angeles International Airport','PST','1 World Way','Los Angeles','CA','90045'),
('SJC','Norman Y. Mineta San Jose International Airport','PST','1702 Airport Blvd','San Jose','CA','95110'),
('ORD','O\'Hare International Airport','CST','10000 W O\'Hare Ave','Chicago','IL','60666'),
('MIA','Miami International Airport','EST','2100 NW 42nd Ave','Miami','FL','33126'),
('DFW','Dallas International Airport','CST','2400 Aviation DR','Dallas','TX','75261');

-- Table structure for table attraction
DROP TABLE IF EXISTS attraction;
CREATE TABLE attraction(
    airport_ID CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (airport_ID, name),
    CONSTRAINT FOREIGN KEY (airport_ID) REFERENCES airport (airport_ID)
) ENGINE=InnoDB;

-- Dumping data for table attraction
INSERT INTO attraction VALUES
('ATL','The Coke Factory'),
('ATL','The Georgia Aquarium'),
('JFK','The Statue of Liberty'),
('JFK','The Empire State Building'),
('LGA','The Statue of Liberty'),
('LGA','The Empire State Building'),
('LAX','Lost Angeles Lakers Stadium'),
('LAX','Los Angeles Kings Stadium'),
('SJC','Winchester Mystery House'),
('SJC','San Jose Earthquakes Soccer Team'),
('ORD','Chicago Blackhawks Stadium'),
('ORD','Chicago Bulls Stadium'),
('MIA','Crandon Park Beach'),
('MIA','Miami Heat Basketball Stadium'),
('DFW','Texas Longhorns Stadium'),
('DFW','The Original Texas Roadhouse');

-- Table structure for table flight
DROP TABLE IF EXISTS flight;
CREATE TABLE flight(
    airline VARCHAR(50) NOT NULL,
    flight_number CHAR(5) NOT NULL,
    depart_time TIME NOT NULL CHECK (depart_time >= '00:00:00' AND depart_time < '24:00:00'),
    arrive_time TIME NOT NULL CHECK (arrive_time >= '00:00:00' AND arrive_time < '24:00:00'),
    flight_date DATE NOT NULL,
    seat_cost DECIMAL(8,2) NOT NULL,
    capacity INT NOT NULL,
    airport_to CHAR(3) NOT NULL,
    airport_from CHAR(3) NOT NULL,
    PRIMARY KEY (airline, flight_number),
    CONSTRAINT FOREIGN KEY (airline) REFERENCES airline (name),
    CONSTRAINT FOREIGN KEY (airport_to) REFERENCES airport (airport_ID),
    CONSTRAINT FOREIGN KEY (airport_from) REFERENCES airport (airport_ID)
) ENGINE=InnoDB;

-- Dumping data for table flight TIME FORMAT NOT COMPLETE
INSERT INTO flight VALUES
('Delta Airlines','1','10:00:00','12:00:00','2021-10-18',400,150,'JFK','ATL'),
('Southwest Airlines','2','10:30:00','14:30:00','2021-10-18',350,125,'MIA','ORD'),
('American Airlines','3','13:00:00','16:00:00','2021-10-18',350,125,'DFW','MIA'),
('United Airlines','4','16:30:00','18:30:00','2021-10-18',400,100,'LGA','ATL'),
('JetBlue Airways','5','11:00:00','13:00:00','2021-10-19',400,130,'ATL','LGA'),
('Spirit Airlines','6','12:30:00','21:30:00','2021-10-19',650,140,'ATL','SJC'),
('WestJet','7','13:00:00','16:00:00','2021-10-19',700,100,'SJC','LGA'),
('Interjet','8','19:30:00','21:30:00','2021-10-19',350,125,'ORD','MIA'),
('Delta Airlines','9','8:00:00','10:00:00','2021-10-20',375,150,'ATL','JFK'),
('Delta Airlines','10','9:15:00','18:15:00','2021-10-20',700,110,'ATL','LAX'),
('Southwest Airlines','11','12:07:00','19:07:00','2021-10-20',600,95,'ORD','LAX'),
('United Airlines','12','15:35:00','17:35:00','2021-10-20',275,115,'ATL','MIA');

-- Table structure for table account
DROP TABLE IF EXISTS account;
CREATE TABLE account(
    email VARCHAR(50) NOT NULL CHECK (email LIKE '_%@_%._%'),
    fname VARCHAR(100) NOT NULL,
    lname VARCHAR(100) NOT NULL,
    acct_password VARCHAR(50) NOT NULL,
    is_admin BOOLEAN NOT NULL,
    phone_number CHAR(12),
    PRIMARY KEY (email),
    UNIQUE KEY (phone_number)
) ENGINE=InnoDB;

-- Dumping data for table account
INSERT INTO account VALUES
('mmoss1@travelagency.com','Mark','Moss','password1',TRUE,NULL),
('asmith@travelagency.com','Aviva','Smith','password2',TRUE,NULL),
('mscott22@gmail.com','Michael','Scott','password3',FALSE,'555-123-4567'),
('arthurread@gmail.com','Arthur','Read','password4',FALSE,'555-234-5678'),
('jwayne@gmail.com','John','Wayne','password5',FALSE,'555-345-6789'),
('gburdell3@gmail.com','George','Burdell','password6',FALSE,'555-456-7890'),
('mj23@gmail.com','Michael','Jordan','password7',FALSE,'555-567-8901'),
('lebron6@gmail.com','Lebron','James','password8',FALSE,'555-678-9012'),
('msmith5@gmail.com','Michael','Smith','password9',FALSE,'555-789-0123'),
('ellie2@gmail.com','Ellie','Johnson','password10',FALSE,'555-890-1234'),
('scooper3@gmail.com','Sheldon','Cooper','password11',FALSE,'678-123-4567'),
('mgeller5@gmail.com','Monica','Geller','password12',FALSE,'678-234-5678'),
('cbing10@gmail.com','Chandler','Bing','password13',FALSE,'678-345-6789'),
('hwmit@gmail.com','Howard','Wolowitz','password14',FALSE,'678-456-7890'),
('swilson@gmail.com','Samantha','Wilson','password16',FALSE,'770-123-4567'),
('aray@tiktok.com','Addison','Ray','password17',FALSE,'770-234-5678'),
('cdemilio@tiktok.com','Charlie','Demilio','password18',FALSE,'770-345-6789'),
('bshelton@gmail.com','Blake','Shelton','password19',FALSE,'770-456-7890'),
('lbryan@gmail.com','Luke','Bryan','password20',FALSE,'770-567-8901'),
('tswift@gmail.com','Taylor','Swift','password21',FALSE,'770-678-9012'),
('jseinfeld@gmail.com','Jerry','Seinfeld','password22',FALSE,'770-789-0123'),
('maddiesmith@gmail.com','Madison','Smith','password23',FALSE,'770-890-1234'),
('johnthomas@gmail.com','John','Thomas','password24',FALSE,'404-770-5555'),
('boblee15@gmail.com','Bob','Lee','password25',FALSE,'404-678-5555');

-- Table structure for table customer
DROP TABLE IF EXISTS customer;
CREATE TABLE customer(
    username VARCHAR(50) NOT NULL,
    location VARCHAR(50) NOT NULL,
    cvv CHAR(3) NOT NULL,
    expiration_date DATE NOT NULL,
    credit_card_number CHAR(16) NOT NULL,
    PRIMARY KEY (username),
    UNIQUE KEY (credit_card_number),
    CONSTRAINT FOREIGN KEY (username) REFERENCES account (email)
) ENGINE=InnoDB;

-- Dumping data for table customer
INSERT INTO customer VALUES
('scooper3@gmail.com',NULL,'551',' Feb 2024','6518 5559 7446 1663'),
('mgeller5@gmail.com',NULL,'644',' March 2024','2328 5670 4310 1965'),
('cbing10@gmail.com',NULL,'201',' Feb 2023','8387 9523 9827 9291'),
('hwmit@gmail.com',NULL,'102',' April 2023','6558 8596 9852 5299'),
('swilson@gmail.com',NULL,'455',' Aug 2022','9383 3212 4198 1836'),
('aray@tiktok.com',NULL,'744',' Aug 2022','3110 2669 7949 5605'),
('cdemilio@tiktok.com',NULL,'606',' Feb 2025','2272 3555 4078 4744'),
('bshelton@gmail.com',NULL,'862',' Sept 2023','9276 7639 7883 4273'),
('lbryan@gmail.com',NULL,'258',' May 2023','4652 3726 8864 3798'),
('tswift@gmail.com',NULL,'857',' Dec 2024','5478 8420 4436 7471'),
('jseinfeld@gmail.com',NULL,'295',' June 2022','3616 8977 1296 3372'),
('maddiesmith@gmail.com',NULL,'794',' July 2022','9954 5698 6355 6952'),
('johnthomas@gmail.com',NULL,'269',' Oct 2025','7580 3274 3724 5356'),
('boblee15@gmail.com',NULL,'858',' Nov 2025','7907 3513 7161 4248');

-- Table structure for table owner
DROP TABLE IF EXISTS owner;
CREATE TABLE owner(
    username VARCHAR(50) NOT NULL,
    PRIMARY KEY (username),
    CONSTRAINT FOREIGN KEY (username) REFERENCES account (email)
) ENGINE=InnoDB;

-- Dumping data for table owner

-- Table structure for table property
DROP TABLE IF EXISTS property;
CREATE TABLE property(
    owner VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(300) NOT NULL,
    street VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state CHAR(2) NOT NULL,
    zip CHAR(5) NOT NULL,
    cost_per_night_per_person DECIMAL(8,2) NOT NULL CHECK (cost_per_night_per_person >= 0),
    capacity INT NOT NULL,
    PRIMARY KEY (owner, name),
    KEY (street, city, state, zip),
    CONSTRAINT FOREIGN KEY (owner) REFERENCES owner (username)
) ENGINE=InnoDB;

-- Dumping data for table property

-- Table structure for table amenity
DROP TABLE IF EXISTS amenity;
CREATE TABLE amenity(
    owner VARCHAR(50) NOT NULL,
    property VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (owner, property, name),
    CONSTRAINT FOREIGN KEY (owner, property) REFERENCES property (owner, name)
) ENGINE=InnoDB;

-- Dumping data for table amenity

-- RELATIONSHIPS BEGIN HERE

-- Table structure for table booking
DROP TABLE IF EXISTS booking;
CREATE TABLE booking(
    customer VARCHAR(50) NOT NULL,
    airline VARCHAR(50) NOT NULL,
    flight_number CHAR(5) NOT NULL,
    number_seats INT NOT NULL,
    PRIMARY KEY (customer, airline, flight_number),
    CONSTRAINT FOREIGN KEY (customer) REFERENCES customer (username),
    CONSTRAINT FOREIGN KEY (airline, flight_number) REFERENCES flight (airline, flight_number)
) ENGINE=InnoDB;

-- Dumping data for table booking

-- Table structure for table nearby
DROP TABLE IF EXISTS nearby;
CREATE TABLE nearby(
    owner VARCHAR(50) NOT NULL,
    property VARCHAR(50) NOT NULL,
    airport CHAR(3) NOT NULL,
    distance INT NOT NULL CHECK (distance >= 0 AND distance < 50),
    PRIMARY KEY (owner, property, airport),
    CONSTRAINT FOREIGN KEY (owner, property) REFERENCES property (owner, name),
    CONSTRAINT FOREIGN KEY (airport) REFERENCES airport (airport_ID)
) ENGINE=InnoDB;

-- Dumping data for table nearby

-- Table structure for table reservation
DROP TABLE IF EXISTS reservation;
CREATE TABLE reservation(
    customer VARCHAR(50) NOT NULL,
    owner VARCHAR(50) NOT NULL,
    property VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    num_guests INT NOT NULL,
    PRIMARY KEY (customer, owner, property),
    CONSTRAINT FOREIGN KEY (customer) REFERENCES customer (username),
    CONSTRAINT FOREIGN KEY (owner, property) REFERENCES property (owner, name)
) ENGINE=InnoDB;

-- Dumping data for table reservation

-- Table structure for table review
DROP TABLE IF EXISTS review;
CREATE TABLE review(
    customer VARCHAR(50) NOT NULL,
    owner VARCHAR(50) NOT NULL,
    property VARCHAR(50) NOT NULL,
    content VARCHAR(500) NOT NULL,
    score INT NOT NULL CHECK (score >= 1 AND score <=5),
    PRIMARY KEY (customer, owner, property),
    CONSTRAINT FOREIGN KEY (customer) REFERENCES customer (username),
    CONSTRAINT FOREIGN KEY (owner, property) REFERENCES property (owner, name)
) ENGINE=InnoDB;

-- Dumping data for table review

