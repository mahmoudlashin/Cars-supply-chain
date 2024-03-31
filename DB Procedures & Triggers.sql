-------------------------Stored procedure to Get Customers by job -------

CREATE OR ALTER PROCEDURE Get_Customers_By_Job
    @job VARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM customer WHERE job = @job)
    BEGIN
        SELECT 
            c.customer_full_name,
            c.customer_city,
            c.job
        FROM 
            customer c
        WHERE 
           c.job = @job;
    END
    ELSE
    BEGIN
        SELECT 
            'There are no customers with the job: ' + @job AS error_message;
    END
END;

EXEC Get_Customers_By_Job @job = 'Engineer';




---------------------------------------cusstomers insert Stored Procedure

CREATE OR ALTER proc Insert_Customer
@id INT ,
@fname VARCHAR(20),
@lname VARCHAR(50),
@full_name VARCHAR(100),
@phone varchar(50),
@city varchar(50),
@country_code int,
@address varchar(100),
@state varchar(50),
@email varchar(50),
@gender varchar(50),
@job varchar(50)

AS
 BEGIN TRY

	 INSERT INTO dbo.customer(customer_id , customer_first_name, customer_last_name, customer_full_name,customer_phone_number
	 ,customer_city  , customer_country_code , customer_address , customer_state , customer_email , gender, job)
	 VALUES(@id  , @fname,@lname ,@full_name ,@phone, @city ,@country_code ,@address ,@state ,@email ,@gender, @job )
END TRY

BEGIN CATCH

	SELECT 'It seems that there is a customer with the same id '
	SELECT ERROR_MESSAGE()
END CATCH


--------try the error message with a not valid id
EXEC Insert_Customer
    @id = 1,
    @fname = 'John',
    @lname = 'Doe',
    @full_name = 'John Doe',
    @phone = '1234567890',
    @city = 'New York',
    @country_code = 1,
    @address = '123 Main Street',
    @state = 'NY',
    @email = 'john@example.com',
    @gender = 'Male',
    @job = 'Engineer';
	
	
	---------------------------------Stored Procedure to Update customers
	CREATE OR ALTER PROCEDURE Update_Customer
    @id INT,
    @fname VARCHAR(20),
    @lname VARCHAR(50),
    @full_name VARCHAR(100),
    @phone VARCHAR(50),
    @city VARCHAR(50),
    @country_code INT,
    @address VARCHAR(100),
    @state VARCHAR(50),
    @email VARCHAR(50),
    @gender VARCHAR(50),
    @job VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        UPDATE dbo.customer
        SET 
            customer_first_name = @fname,
            customer_last_name = @lname,
            customer_full_name = @full_name,
            customer_phone_number = @phone,
            customer_city = @city,
            customer_country_code = @country_code,
            customer_address = @address,
            customer_state = @state,
            customer_email = @email,
            gender = @gender,
            job = @job
        WHERE
            customer_id = @id
			  IF @@ROWCOUNT = 0
        BEGIN
 RAISERROR('Customer with ID %d not found.', 16)  --- ( 16 , state(optional) )severity level and state are values based on the nature of the error depending on how we want the error to be handled
      return
	  END
    END TRY

    BEGIN CATCH 
       DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    SELECT 'Error: ' + ERROR_MESSAGE() AS ErrorMessage ,
   'Error Severity: ' + CAST(@ErrorSeverity AS NVARCHAR(10)) as Error_nature
    END CATCH
END;

--------Try error message with an id which doesn`t exit
EXEC Update_Customer 
    @id = 125555553,
    @fname = 'John',
    @lname = 'Doe',
    @full_name = 'John Doe',
    @phone = '1234567890',
    @city = 'New York',
    @country_code = 1,
    @address = '123 Main Street',
    @state = 'NY',
    @email = 'john@example.com',
    @gender = 'Male',
    @job = 'Engineer';


	------------------stored procedur to insert cars

CREATE OR ALTER PROCEDURE insert_car
    @car_id INT,
    @maker VARCHAR(50),
    @model VARCHAR(50),
    @year INT,
    @price INT,
    @color VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Check if the car_id already exists
        IF NOT EXISTS (SELECT 1 FROM cars WHERE car_id = @car_id)
        BEGIN
            -- If the car_id does not exist, insert the new car record
            INSERT INTO cars (car_id, maker, model, year, price, color)
            VALUES (@car_id, @maker, @model, @year, @price, @color);
        END
        ELSE
        BEGIN
            -- If the car_id already exists, raise an error
            RAISERROR ('Car with ID %d already exists.', 16, 1, @car_id);
        END
    END TRY
    BEGIN CATCH
        -- Handle the error
        SELECT 'Error: ' + ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;


---------------------------Stored procedure to update cars

CREATE OR ALTER PROCEDURE update_car
    @car_id INT,
    @maker VARCHAR(50),
    @model VARCHAR(50),
    @year INT,
    @price INT,
    @color VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Check if the car_id already exists
        IF EXISTS (SELECT 1 FROM cars WHERE car_id = @car_id)
        BEGIN
            -- If the car_id exists, update the car record
            UPDATE cars
            SET maker = @maker,
                model = @model,
                year = @year,
                price = @price,
                color = @color
            WHERE car_id = @car_id;
        END
        ELSE
        BEGIN
            -- If the car_id does not exist, raise an error
            RAISERROR ('Car with ID %d does not exist.', 16, 1, @car_id);
        END
    END TRY
    BEGIN CATCH
        -- Handle the error
        SELECT 'Error: ' + ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;

---------------------------------------------Trigger from updating orders


CREATE or alter TRIGGER order_update_trigger 
ON orders 
AFTER UPDATE
AS
BEGIN
  DECLARE @oldid INT , @newid INT 
  SELECT @newid = order_id FROM INSERTED
  SELECT @oldid = order_id FROM DELETED

  IF @newid IS NULL
  BEGIN
    SELECT @newid = order_id FROM orders WHERE order_id = @oldid
  END

  INSERT INTO history VALUES(@newid , @oldid , GETDATE() , SUSER_NAME())
END


--------------------------------------trigger for delete Orders


create or alter trigger order_delete_trigger
on orders
instead of delete
as
	select 'Delete is Not allowed for user : '+suser_name()



	-----------------------------------------Procedure to return suppliers info

	create or alter procedure supplier_info @supplier_id int
	as 
	select * from supplier s
	where s.supplier_id = @supplier_id

	-----

exec supplier_info 1

-----------------------------procedure to print cars models info in range of years

create or alter procedure cars_info @year1 int ,@year2 int
as
select * from car
where car_model_year between @year1 and @year2

---
exec cars_info 2019,2020


----------------------------------trigger for updating any car price

CREATE TRIGGER order_update_trigger 
on car

AFTER UPDATE

AS
BEGIN
		  IF UPDATE(car_price)
		  begin
  DECLARE @oldprice INT , @newprice INT 
  SELECT @newprice = car_price FROM INSERTED
  SELECT @oldprice = car_price FROM DELETED


  INSERT INTO history VALUES(@newprice , @oldprice , GETDATE() , SUSER_NAME())
END
end
