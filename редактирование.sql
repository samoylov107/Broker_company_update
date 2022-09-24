CREATE DATABASE Broker_company
GO

USE Broker_company
GO 

CREATE SCHEMA log
GO

IF OBJECT_ID('dbo.Customers', 'U') IS NULL 
CREATE TABLE Broker_company.dbo.Customers 
(id INT PRIMARY KEY IDENTITY (1,1), 
 first_name varchar (30) NOT NULL,
 second_name varchar (30) NOT NULL,
 email varchar (50),
 phone BIGINT UNIQUE NOT NULL ,
 passport varchar (30) UNIQUE NOT NULL)
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
 passport varchar (30) NOT NULL)
 GO

CREATE OR ALTER PROCEDURE dbo.updating_broker_company
(@c_id INT,
 @first_name varchar (30),
 @second_name varchar (30),
 @email varchar (50),
 @phone BIGINT,
 @pass_num varchar (30))
AS
DECLARE @fn_old varchar (30), 
        @sn_old varchar (30), 
    	@em_old varchar (50), 
	@ph_old BIGINT, 
        @pass_old varchar (50),
        @ph_err varchar (20) = NULL,
	@pass_err varchar (20) = NULL,
	@msg_err varchar (255)

 SELECT @fn_old = first_name, 
        @sn_old = second_name, 
	@em_old = email, 
	@ph_old = phone,
	@pass_old = passport 
   FROM Broker_company.dbo.Customers 
  WHERE id = @c_id

     IF @phone IN (SELECT phone FROM Broker_company.dbo.Customers WHERE id <> @c_id)
    SET @ph_err = 'номером телефона'
    
     IF @pass_num IN (SELECT passport FROM Broker_company.dbo.Customers WHERE id <> @c_id)
    SET @pass_err = 'номером паспорта' 

    SET @msg_err = CONCAT('Пользователь с таким ', CONCAT_WS(', ', @ph_err, @pass_err), ' уже зарегистрирован!')

     IF @phone IN (SELECT phone FROM Broker_company.dbo.Customers WHERE id <> @c_id)
     OR @pass_num IN (SELECT passport FROM Broker_company.dbo.Customers WHERE id <> @c_id)
	RAISERROR(@msg_err, 16, 1)

ELSE IF ISNULL(@first_name,'')  <> ISNULL(@fn_old,'') 
     OR ISNULL(@second_name,'') <> ISNULL(@sn_old,'')
     OR ISNULL(@email,'')       <> ISNULL(@em_old,'')
     OR ISNULL(@phone,0)        <> ISNULL(@ph_old,0)
     OR ISNULL(@pass_num,'')    <> ISNULL(@pass_old,'')

BEGIN	
  UPDATE Broker_company.dbo.Customers
     SET first_name  = ISNULL(@first_name, first_name),
         second_name = ISNULL(@second_name, second_name),
         email       = ISNULL(@email, email),
         phone       = ISNULL(@phone, phone),
         passport    = ISNULL(@pass_num, passport)
   WHERE id = @c_id

  INSERT INTO Broker_company.log.Customers
         (motion, customer_id, first_name, second_name, email, phone, passport)                                       
  VALUES ('UPDATE', @c_id, @fn_old, @sn_old, @em_old, @ph_old, @pass_old)
END
GO

EXEC Broker_company.dbo.updating_broker_company
     @c_id = 1,
     @first_name = 'George',
     @second_name = 'Michael',
     @email = 'george_michael@gmail.com',
     @phone = 79107771134,
     @pass_num = 'MP0123456789'
