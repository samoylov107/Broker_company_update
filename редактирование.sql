CREATE DATABASE Broker_company
GO

USE Broker_company
GO 

CREATE SCHEMA log
GO

IF OBJECT_ID('dbo.Customers1', 'U') IS NULL 
CREATE TABLE Broker_company.dbo.Customers1
(id INT PRIMARY KEY IDENTITY(1,1), 
 first_name  varchar(30) CHECK(first_name  <> '') NOT NULL,
 second_name varchar(30) CHECK(second_name <> '') NOT NULL,
 email varchar(50),
 phone BIGINT UNIQUE NOT NULL,
 passport varchar (30) UNIQUE NOT NULL,
 age TINYINT CHECK(age BETWEEN 14 AND 140))
GO

IF OBJECT_ID('log.Customers', 'U') IS NULL 
CREATE TABLE Broker_company.log.Customers 
(id INT PRIMARY KEY IDENTITY (1,1),
 motion_date datetime2 DEFAULT SYSDATETIME(),
 motion varchar (10) NOT NULL,
 customer_id INT NOT NULL,
 first_name varchar (30) NOT NULL,
 second_name varchar (30) NOT NULL,
 email varchar (50),
 phone BIGINT NOT NULL,
 passport varchar (30) NOT NULL,
 age TINYINT)
 GO

CREATE OR ALTER PROCEDURE dbo.updating_broker_company
(@c_id INT,
 @first_name varchar (30),
 @second_name varchar (30),
 @email varchar (50),
 @phone BIGINT,
 @pass_num varchar (30),
 @age TINYINT)
AS
DECLARE	@msg_err varchar(MAX)
DECLARE @errors_table TABLE (error_list varchar (255))
DECLARE @old_values TABLE (first_name varchar (30),
                           second_name varchar (30),
                           email varchar (50),
                           phone BIGINT,
                           passport varchar (30),
			   age TINYINT)
						   		
IF @phone IN (SELECT phone FROM Broker_company.dbo.Customers WHERE id <> @c_id)
     INSERT INTO @errors_table  
     VALUES ('Пользователь с таким номером телефона уже зарегистрирован!')  

IF @pass_num IN (SELECT passport FROM Broker_company.dbo.Customers WHERE id <> @c_id)
     INSERT INTO @errors_table  
     VALUES ('Пользователь с таким номером паспорта уже зарегистрирован!')  
 
IF @age < 14
     INSERT INTO @errors_table  
     VALUES ('Минимально допустимый возраст - 14 лет!')  

SELECT @msg_err = STRING_AGG(error_list, '
')
  FROM @errors_table 

IF EXISTS (SELECT error_list FROM @errors_table)
     THROW 50000, @msg_err, 1

UPDATE Broker_company.dbo.Customers
   SET first_name  = ISNULL(@first_name, first_name),
       second_name = ISNULL(@second_name, second_name),
       email       = ISNULL(@email, email),
       phone       = ISNULL(@phone, phone),
       passport    = ISNULL(@pass_num, passport),
       age         = ISNULL(@age, age)
OUTPUT deleted.first_name,	
       deleted.second_name,
       deleted.email,
       deleted.phone,
       deleted.passport,
       deleted.age
  INTO @old_values  
 WHERE id = @c_id

IF
  (SELECT CONCAT(first_name, second_name, email, phone, passport, age) 
     FROM @old_values) 
          <>
  (SELECT CONCAT(first_name, second_name, email, phone, passport, age) 
     FROM Broker_company.dbo.Customers
    WHERE id = @c_id)

 INSERT INTO Broker_company.log.Customers
        (motion, customer_id, first_name, second_name, email, phone, passport, age)                                       
 SELECT 'UPDATE', @c_id, first_name, second_name, email, phone, passport, age
   FROM @old_values
GO

EXEC Broker_company.dbo.updating_broker_company
     @c_id = 1,
     @first_name = 'George',
     @second_name = 'Michael',
     @email = 'george_michael@gmail.com',
     @phone = 79107771134,
     @pass_num = 'MP0123456789',
     @age = 53
