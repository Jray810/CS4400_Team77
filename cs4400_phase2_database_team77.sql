-- CS4400: Introduction to Database Systems (Fall 2021)
-- Phase II: Create Table & Insert Statements [v0] Thursday, October 14, 2021 @ 2:00pm EDT

-- Team 77
-- Neil Barry (GT username)
-- Owen Cardwell (GT username)
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
	carrier NOT NULL,
    rating NOT NULL,
    PRIMARY KEY (carrier)
) ENGINE=InnoDB;

-- Dumping data for table airline

-- Table structure for table airport
DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
	airportID NOT NULL,
    airportName NOT NULL,
    timeZone NOT NULL,
    state NOT NULL,
    city NOT NULL,
    street NOT NULL,
    zipcode NOT NULL,
    PRIMARY KEY (airportID)
) ENGINE=InnoDB;
    
