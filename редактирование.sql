CREATE DATABASE Broker_company
GO

USE Broker_company
GO 

CREATE SCHEMA log

CREATE TABLE Broker_company.dbo.Customers 
(id INT PRIMARY KEY IDENTITY (1,1), 
 first_name varchar (30) NOT NULL,
 second_name varchar (30) NOT NULL,
 email varchar (50),
 phone BIGINT UNIQUE NOT NULL ,
 passport varchar (30) UNIQUE NOT NULL)
GO

CREATE TABLE Broker_company.log.Customers 
(id INT PRIMARY KEY IDENTITY (1,1),
 motion varchar (10) NOT NULL,
 customer_id INT NOT NULL,
 first_name_old varchar (30) NOT NULL,
 first_name_new varchar (30) NOT NULL,
 second_name_old varchar (30) NOT NULL,
 second_name_new varchar (30) NOT NULL,
 email_old varchar (50),
 email_new varchar (50),
 phone_old BIGINT NOT NULL,
 phone_new BIGINT NOT NULL,
 passport_old varchar (30) NOT NULL,
 passport_new varchar (30) NOT NULL)
 GO


  CREATE OR ALTER PROCEDURE dbo.updating_broker_company
(@c_id INT,
 @first_name varchar (30),
 @second_name varchar (30),
 @email varchar (50),
 @phone BIGINT,
 @pass_num varchar (30))
AS
DECLARE @fn_old   varchar (30) = (SELECT first_name  FROM Broker_company.dbo.Customers WHERE id = @c_id)
DECLARE @sn_old   varchar (30) = (SELECT second_name FROM Broker_company.dbo.Customers WHERE id = @c_id)
DECLARE @em_old   varchar (50) = (SELECT email       FROM Broker_company.dbo.Customers WHERE id = @c_id)
DECLARE @ph_old   BIGINT       = (SELECT phone       FROM Broker_company.dbo.Customers WHERE id = @c_id)
DECLARE @pass_old varchar (50) = (SELECT passport    FROM Broker_company.dbo.Customers WHERE id = @c_id)

BEGIN 
     IF @phone    IN (SELECT phone    FROM Broker_company.dbo.Customers WHERE id <> @c_id)
    AND @pass_num IN (SELECT passport FROM Broker_company.dbo.Customers WHERE id <> @c_id)
	    RAISERROR('ѕользователь с таким номером паспорта и номером телефона уже зарегистрирован!', 16, 1)

ELSE IF @pass_num IN (SELECT passport FROM Broker_company.dbo.Customers WHERE id <> @c_id)
        RAISERROR('ѕользователь с таким номером паспорта уже зарегистрирован!', 16, 1)

ELSE IF @phone    IN (SELECT phone    FROM Broker_company.dbo.Customers WHERE id <> @c_id)
        RAISERROR('ѕользователь с таким номером телефона уже зарегистрирован!', 16, 1)

ELSE UPDATE Broker_company.dbo.Customers
	    SET first_name  = @first_name,
		    second_name = @second_name,
            email       = @email,
			phone		= @phone,
			passport	= @pass_num
			WHERE id    = @c_id

INSERT INTO Broker_company.log.Customers 
       (motion,   customer_id, first_name_old, first_name_new, second_name_old, second_name_new, email_old, email_new, phone_old, phone_new, passport_old, passport_new)                                       
VALUES ('UPDATE', @c_id,      @fn_old,        @first_name,    @sn_old,         @second_name,    @em_old,    @email,   @ph_old,   @phone,    @pass_old,     @pass_num)

END
GO


EXEC Broker_company.dbo.updating_broker_company
     @c_id = 1,
     @first_name = 'George',
     @second_name = 'Michael',
     @email = 'george_michael@gmail.com',
     @phone = 79107771134,
     @pass_num = 'MP0123456789'