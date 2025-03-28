DROP DATABASE IF EXISTS `sql_hospital`;
CREATE DATABASE `sql_hospital`;
USE   `sql_hospital`;

SET NAMES utf8;

CREATE TABLE `patients`(
`patient_id` tinyint(4) NOT NULL AUTO_INCREMENT,
`first_name` VARCHAR(50) NOT NULL,
`last_name` VARCHAR(50) NOT NULL,
`DOB` VARCHAR(50) NOT NULL,
`age` integer NOT NULL,
`gender` VARCHAR(50) NOT NULL,
`address` VARCHAR(50) NOT NULL , 
`contact` VARCHAR(50) NOT NULL,
`emerg_contact` VARCHAR(50),
`admi_date` datetime NOT NULL,
`discharge_date` datetime NOT NULL,
PRIMARY KEY (`patient_id`)
);
-- making procedure to automate 50 items
DELIMITER $$

CREATE PROCEDURE AutoInsertpatients()
BEGIN
    DECLARE i INT DEFAULT 1; -- Counter for patient ID
    DECLARE age INT DEFAULT 10; -- Starting age
    DECLARE gender CHAR(1); -- Gender variable
    
    WHILE i <= 50 DO
        -- Randomly assign gender
        SET gender = CASE WHEN RAND() > 0.5 THEN 'M' ELSE 'F' END;

        -- Insert record into Patients table
        INSERT INTO patients (patient_id, first_name, last_name, DOB, age , gender, address, contact,emerg_contact,admi_date,discharge_date)
        VALUES (
            i, -- Patient ID
            CONCAT('firstName_', i), -- Example first name
            CONCAT('lastName_', i), -- Example last name
            DATE_ADD('1980-01-01', INTERVAL (age - 10) * 365 DAY), -- Simulated DOB based on age
			age, -- Incremented age
			gender, -- Random gender
			CONCAT('Address ', i, ', City'), -- Example address
            CONCAT('555-000-', LPAD(i, 4, '0')), -- Example phone number
            CONCAT('666-111-', LPAD(i,4,'0')), -- emargency contact
            DATE_ADD('2015-10-01', INTERVAL (i - 1) * 2 DAY), -- Increment admission dates by 2 days
            DATE_ADD('2016-01-01', INTERVAL (1+1) * 3 DAY) -- increment discharge dates by 3
        );

        -- Increment counters
        SET i = i + 1;
        SET age = age + 5;
        
        -- Reset age if it exceeds 60 (to create variation)
        IF age > 60 THEN
            SET age = 10;
        END IF;
    END WHILE;
END $$

DELIMITER ;
CALL AutoInsertpatients();



