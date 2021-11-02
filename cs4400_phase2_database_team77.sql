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

-- Table structure for table attraction
DROP TABLE IF EXISTS attraction;
CREATE TABLE attraction(
    airport_ID CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (airport_ID, name),
    CONSTRAINT FOREIGN KEY (airport_ID) REFERENCES airport (airport_ID)
) ENGINE=InnoDB;

-- Dumping data for table attraction

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

-- Dumping data for table flight

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

-- Table structure for table customer
DROP TABLE IF EXISTS customer;
CREATE TABLE customer(
    username varchar(50) NOT NULL,
    location NOT NULL,
    cvv NOT NULL,
    expiration_date NOT NULL,
    credit_card_number NOT NULL,
    PRIMARY KEY (username),
    KEY (credit_card_number),
    CONSTRAINT ?? FOREIGN KEY (username) REFERENCES client (username)
) ENGINE=InnoDB;

-- Dumping data for table customer

-- Table structure for table property
DROP TABLE IF EXISTS property;
CREATE TABLE property(
    owner NOT NULL,
    name NOT NULL,
    description NOT NULL,
    street NOT NULL,
    city NOT NULL,
    state NOT NULL,
    zip NOT NULL,
    cost_per_night_per_person NOT NULL,
    capacity NOT NULL,
    PRIMARY KEY (owner, name),
    KEY (street, city, state, zip),
    CONSTRAINT ?? FOREIGN KEY (owner) REFERENCES client (username)
) ENGINE=InnoDB;

-- Dumping data for table property

-- Table structure for table amenity
DROP TABLE IF EXISTS amenity;
CREATE TABLE amenity(
    owner NOT NULL,
    property NOT NULL,
    name NOT NULL,
    description NOT NULL,
    PRIMARY KEY (owner, property, name),
    CONSTRAINT ?? FOREIGN KEY (owner) REFERENCES property (owner),
    CONSTRAINT ?? FOREIGN KEY (property) REFERENECS property (name)
) ENGINE=InnoDB;

-- Dumping data for table amenity



-- RELATIONSHIPS BEGIN HERE

-- Table structure for table booking
DROP TABLE IF EXISTS booking;
CREATE TABLE booking(
    customer NOT NULL,
    airline NOT NULL,
    flight_number NOT NULL,
    number_seats NOT NULL,
    PRIMARY KEY (customer, airline, flight_number),
    CONSTRAINT ?? FOREIGN KEY (customer) REFERENCES customer (username),
    CONSTRAINT ?? FOREIGN KEY (airline) REFERENCES flight (airline),
    CONSTRAINT ?? FOREIGN KEY (flight_number) REFERENCES flight (flight_number)
) ENGINE=InnoDB;

-- Dumping data for table booking

-- Table structure for table nearby
DROP TABLE IF EXISTS nearby;
CREATE TABLE nearby(
    owner NOT NULL,
    property NOT NULL,
    airport NOT NULL,
    distance NOT NULL,
    PRIMARY KEY (owner, property, airport),
    CONSTRAINT ?? FOREIGN KEY (owner) REFERENCES property (owner),
    CONSTRAINT ?? FOREIGN KEY (property) REFERENCES property (name),
    CONSTRAINT ?? FOREIGN KEY (airport) REFERENCES airport (airport_ID)
) ENGINE=InnoDB;

-- Dumping data for table nearby

-- Table structure for table reservation
DROP TABLE IF EXISTS reservation;
CREATE TABLE reservation(
    customer NOT NULL,
    owner NOT NULL,
    property NOT NULL,
    start_date NOT NULL,
    end_date NOT NULL,
    num_guests NOT NULL,
    PRIMARY KEY (customer, owner, property),
    CONSTRAINT ?? FOREIGN KEY (customer) REFERENCES customer (username),
    CONSTRAINT ?? FOREIGN KEY (owner, property) REFERENCES property (owner, name)
) ENGINE=InnoDB;

-- Dumping data for table reservation

-- Table structure for table review
DROP TABLE IF EXISTS review;
CREATE TABLE review(
    customer NOT NULL,
    owner NOT NULL,
    property NOT NULL,
    content NOT NULL,
    score NOT NULL,
    PRIMARY KEY (customer, owner, property),
    CONSTRAINT ?? FOREIGN KEY (customer) REFERENCES customer (username),
    CONSTRAINT ?? FOREIGN KEY (owner, property) REFERENCES property (owner, name)
) ENGINE=InnoDB;

-- Dumping data for table review

