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
 motion_date datetime2 DEFAULT SYSDATETIME(),
 motion varchar (10) NOT NULL,
 customer_id INT NOT NULL,
 first_name varchar (30) NOT NULL,
 second_name varchar (30) NOT NULL,
 email varchar (50),
 phone BIGINT NOT NULL,
 passport varchar (30) NOT NULL)
 GO


 CREATE OR ALTER PROCEDURE brok.updating_broker_company
(@c_id INT,
 @first_name varchar (30),
 @second_name varchar (30),
 @email varchar (50),
 @phone BIGINT,
 @pass_num varchar (30))
AS
DECLARE @fn_old   varchar (30) = (SELECT first_name  FROM samoilov.brok.Customers WHERE id = @c_id)
DECLARE @sn_old   varchar (30) = (SELECT second_name FROM samoilov.brok.Customers WHERE id = @c_id)
DECLARE @em_old   varchar (50) = (SELECT email       FROM samoilov.brok.Customers WHERE id = @c_id)
DECLARE @ph_old   BIGINT       = (SELECT phone       FROM samoilov.brok.Customers WHERE id = @c_id)
DECLARE @pass_old varchar (50) = (SELECT passport    FROM samoilov.brok.Customers WHERE id = @c_id)

BEGIN 
     IF @phone    IN (SELECT phone    FROM samoilov.brok.Customers WHERE id <> @c_id)
    AND @pass_num IN (SELECT passport FROM samoilov.brok.Customers WHERE id <> @c_id)
	RAISERROR('Пользователь с таким номером паспорта и номером телефона уже зарегистрирован!', 16, 1)

ELSE IF @pass_num IN (SELECT passport FROM samoilov.brok.Customers WHERE id <> @c_id)
        RAISERROR('Пользователь с таким номером паспорта уже зарегистрирован!', 16, 1)

ELSE IF @phone    IN (SELECT phone    FROM samoilov.brok.Customers WHERE id <> @c_id)
        RAISERROR('Пользователь с таким номером телефона уже зарегистрирован!', 16, 1)

ELSE IF ISNULL(@first_name,'')  = ISNULL(@fn_old,'') 
    AND ISNULL(@second_name,'') = ISNULL(@sn_old,'')
    AND ISNULL(@email,'')       = ISNULL(@em_old,'')
    AND ISNULL(@phone,0)        = ISNULL(@ph_old,0)
    AND ISNULL(@pass_num,'')    = ISNULL(@pass_old,'')
	RAISERROR('Старые данные совпадают с новыми.', 16, 1)
		
ELSE IF ISNULL(@first_name,'')  <> ISNULL(@fn_old,'') 
     OR ISNULL(@second_name,'') <> ISNULL(@sn_old,'')
     OR ISNULL(@email,'')       <> ISNULL(@em_old,'')
     OR ISNULL(@phone,0)        <> ISNULL(@ph_old,0)
     OR ISNULL(@pass_num,'')    <> ISNULL(@pass_old,'')
	
UPDATE samoilov.brok.Customers
   SET first_name  = @first_name,
       second_name = @second_name,
       email       = @email,
       phone       = @phone,
       passport    = @pass_num
 WHERE id = @c_id

  IF ISNULL(@first_name,'')  <> ISNULL(@fn_old,'') 
     OR ISNULL(@second_name,'') <> ISNULL(@sn_old,'')
     OR ISNULL(@email,'')       <> ISNULL(@em_old,'')
     OR ISNULL(@phone,0)        <> ISNULL(@ph_old,0)
     OR ISNULL(@pass_num,'')    <> ISNULL(@pass_old,'')
     
INSERT INTO samoilov.brok.log_Customers
       (motion,   customer_id, first_name, second_name,  email,  phone,  passport)                                       
VALUES ('UPDATE_new', @c_id,  @first_name, @second_name, @email, @phone,  @pass_num),
       ('UPDATE_old', @c_id,  @fn_old,     @sn_old,     @em_old, @ph_old,  @pass_old)
 
END
GO



EXEC Broker_company.dbo.updating_broker_company
     @c_id = 1,
     @first_name = 'George',
     @second_name = 'Michael',
     @email = 'george_michael@gmail.com',
     @phone = 79107771134,
     @pass_num = 'MP0123456789'
