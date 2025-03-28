DROP DATABASE IF EXISTS  `sql_Library`;
CREATE DATABASE  `sql_Library`;
USE  `sql_Library`;

SET NAMES utf8 ;
SET character_set_client = utf8mb4 ;


CREATE TABLE  `Books`(
`Book_id` tinyint(4) NOT NULL AUTO_INCREMENT,
`title` varchar(50) NOT NULL,
`author` varchar(50) NOT NULL,
`genre` varchar(50) NOT NULL,
`pub_year` YEAR NOT NULL,
`ISBN` varchar(50) NOT NULL,
`pub_id` tinyint(4) NOT NULL,
PRIMARY KEY (`Book_id`),
KEY `FK_pub_id` (`pub_id`),
CONSTRAINT `fk_pub_id` FOREIGN KEY (`pub_id`) REFERENCES `Publishers` (`pub_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `Books` VALUES (1, 'The Great Adventure','Alice Monroe','Fiction','2020','9781234567890',1);
INSERT INTO `Books` VALUES (2, 'Mystery in the Woods','Bob Smith','Mystery','2019','9789876543210',2);
INSERT INTO `Books` VALUES (3, 'Advanced Python Programming','Clara Lee','Technology','2021','9781111222233',3);
INSERT INTO `Books` VALUES (4, 'Climate Change and Society','Dr. Mark Thomas','Science','2022','9784444555566',1);
INSERT INTO `Books` VALUES (5, 'Secrets of the Universe','Sophie Chen','Non-Fiction','2018','9789998887777',2);

CREATE TABLE `Members`(
`member_id` tinyint(4) NOT NULL auto_increment,
`name` varchar(50) NOT NULL,
`email` varchar(50) NOT NULL,
`phone` varchar(50) NOT NULL,
`membership_start` date NOT NULL,
`membership_type` varchar(50) NOT NULL,
primary key (`member_id`)
);
INSERT INTO `Members` VALUES (1,'Alice Johnson','alice.johnson@gmail.com','123-456-7890','2023-01-15','Premium');
INSERT INTO `Members` VALUES (2,'Bob Carter','bob.carter@gmail.com','234-567-8901','2022-07-10','Regular');
INSERT INTO `Members` VALUES (3,'Clara Edwards','clara.edwards@gmail.com','345-678-9012','2021-11-20','Regular');
INSERT INTO `Members` VALUES (4,'David Foster','david.foster@gmail.com','456-789-0123','2023-05-05','Premium');
INSERT INTO `Members` VALUES (5,'Emma Green','emma.green@gmail.com','567-890-1234','2022-02-22','Regular');

CREATE TABLE `Borrowing_records`(
`record_id` tinyint(4) NOT NULL auto_increment,
`member_id` tinyint(4) NOT NULL,
`book_id` tinyint(4) NOT NULL,
`borrow_date` datetime,
`due_date` datetime,
`return_date` datetime,
primary key (`record_id`),
KEY `FK_member_id` (`member_id`),
KEY `FK_book_id` (`book_id`),
CONSTRAINT `fk_member_id` FOREIGN KEY (`member_id`) REFERENCES `Members` (`member_id`) ON UPDATE CASCADE,
CONSTRAINT `fk_book_id` FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `Borrowing_records` VALUES (1,1,1,'2023-08-01','2023-08-15','2023-08-10');
INSERT INTO `Borrowing_records` VALUES (2,2,3,'2023-08-05','2023-08-19','2023-08-18');
INSERT INTO `Borrowing_records` VALUES (3,3,2,'2023-09-01','2023-09-15','2023-08-15');
INSERT INTO `Borrowing_records` VALUES (4,4,5,'2023-10-01','2023-10-15','2023-10-14');
INSERT INTO `Borrowing_records` VALUES (5,5,4,'2023-11-01','2023-11-15','2023-12-01');

CREATE TABLE `Staff`(
`staff_id` tinyint(4) not null auto_increment,
`name` varchar(50) not null,
`role` varchar(50) not null,
`email` varchar(50) not null,
`phone` varchar(50) not null,
`hire_date` datetime,
primary key (`staff_id`)
);
INSERT INTO `Staff` VALUES (1,'John Williams','Librarian','john.williams@gmail.com','123-123-1234','2020-03-01');
INSERT INTO `Staff` VALUES (2,'Sarah Davis','Assistant','sarah.davis@gmail.com','456-456-4567','2021-06-15');
INSERT INTO `Staff` VALUES (3,'Michael Brown','Manager','michael.brown@gmail.com','789-789-7890','2019-09-10');

CREATE TABLE `Publishers`(
`pub_id` tinyint(4) not null auto_increment,
`name` varchar(50) NOT NULL,
`address` varchar(50) NOT NULL,
`contact` varchar(50),
`website` varchar(50) not null,
primary key (`pub_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `Publishers` values(1,'Pearson','123 Main St, New York','555-123-4567','http://www.pearson.com/');
INSERT INTO `Publishers` values(2,'HarperCollins','456 Elm St, London','555-234-5678','http://www.harpercollins.com/');
INSERT INTO `Publishers` values(3,"O'Reilly Media",'789 Oak St, San Francisco','555-345-6789','http://www.oreilly.com/');


