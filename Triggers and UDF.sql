go
USE P4_FBS
go
CREATE TRIGGER Payment_Insert ON Reservation
--MAKE IDENTITY FOR PAYMENT ID

FOR INSERT
AS
BEGIN
   DECLARE @ResId int
   DECLARE @Res_date DATE
   DECLARE @due_date DATE
   DECLARE @Cost bigint
   DEClARE @seat VARCHAR(20) 
   SELECT @ResId = Reservation_ID FROM inserted
   SELECT @Res_date = Date_Of_Reservation FROM inserted
   SELECT @seat= Reservation.Seat_ID FROM Reservation WHERE Reservation_ID=@ResId
   SELECT @Cost=Cost FROM Flight_Cost WHERE Flight_Cost.Seat_ID=@seat AND Flight_Cost.Valid_From_Date=@Res_date
   SELECT @due_date=DATEADD(DAY,1,@Res_date)
   INSERT INTO Payment_Status(Payment_Status_YN,Payment_Due_Date,Payment_Amount,Reservation_ID)
   VALUES ('N',@due_date,@Cost,@ResId);


END



--UDF
--OUR UDF WILL TAKE BUSINESS DAY,Departure Date,Travel cLASS id,Deafult price
go
CREATE FUNCTION Cal_Cost(@Start_Date date,@dep_date date,@travel_id int,@business char(1))
RETURNS BIGINT
AS
BEGIN
    DECLARE @Diff int
	Select @Diff=DateDIFF(day,@Start_Date,@dep_date)
	RETURN 100+((Select
	CASE
	  WHEN @business='Y' THEN  10
	  ELSE 0
	END As Business_Inc)+
	(Select
	CASE 
	  WHEN @travel_id=1 THEN 50
	  WHEN @travel_id=2 THEN 40
	  WHEN @travel_id=3 THEN 30
	  WHEN @travel_id=4 THEN 20
	  ELSE 10
    END As Class_Inc)+
	(Select
	CASE 
	  WHEN @Diff>20 AND @Diff<=30 THEN 0
	  WHEN @Diff>10 AND @Diff<=20 THEN 20
	  ELSE 50
	END AS Interval_Inc
	))
	 
   
END


--function body end

GO
CREATE TRIGGER Set_Cost ON Seat_Details
FOR INSERT
AS
BEGIN
   Declare @Default_price BIGINT
   Set @Default_price=100
   DECLARE @Start_date date
   DECLARE @Final_Cost BIGINT
   Declare @business char(1)
   --Declare @default_price bigint
   Declare @flight_cost bigint
   DECLARE @dep_date date
   --set @default_price=100
   Declare @S_id varchar(20)
   SELECT @S_id = Seat_ID FROM inserted
   Declare @travel_id int
   SELECT @travel_id= Travel_Class_ID FROM inserted
   DECLARE @flight_id int
   SELECT @flight_id=Flight_ID FROM inserted
   
   Select @business=Business_Day_YN FROM Calendar
       WHERE Day_Date=
	   (SELECT CONVERT(Date,Departure_Date_Time) 
	    FROM Flight_Details WHERE Flight_ID=@flight_id
		)-- from Flight_Details where Flight_ID=@flight_id
	SELECT @dep_date=CONVERT(Date,Departure_Date_Time) 
	    FROM Flight_Details WHERE Flight_ID=@flight_id

	SELECT @Start_date=DATEADD(MONTH,-1,@dep_date)
	DECLARE @last_date date
	SELECT @last_date=DateADD(day,-1,@dep_date)
-- WHILE LOOP
   
   WHILE @Start_date < @last_date
   BEGIN
      

      SELECT @Final_Cost=[dbo].[Cal_Cost](@Start_date,@dep_date,@travel_id,@business)
	  DECLARE @valid_to date
	  SET @valid_to= DATEADD(Day,1,@Start_date)
	  INSERT INTO Flight_Cost(Seat_ID,Valid_From_Date,Cost,Valid_To_Date)
      VALUES(@S_id,@Start_date,@Final_Cost,@valid_to)
      SET @Start_date = DATEADD(Day,1,@Start_date)
   END

END


-- UDF 2
--   To Show Details of Total Departures Per Month 
-- Input Should be Aiplane Type

IF OBJECT_ID (N'Departure_Total_Per_Month', N'IF') IS NOT NULL
    DROP FUNCTION Departure_Total_Per_Month;
go
CREATE FUNCTION Departure_Total_Per_Month (@plane_type VARCHAR(25))
RETURNS TABLE
AS
RETURN
(
    SELECT  Airplane_Type ,YEAR(Departure_Date_Time) AS Year, DATENAME(MONTH, Departure_Date_Time) AS Month,COUNT(Airplane_Type) AS Departure_Total_Per_Month 
    FROM Flight_Details
    WHERE Airplane_Type = @plane_type
    GROUP BY  Airplane_Type,YEAR(Departure_Date_Time), DATENAME(MONTH, Departure_Date_Time)
    --ORDER BY YEAR(Departure_Date_Time) ASC, DATENAME(MONTH, Departure_Date_Time) ASC
);

go
SELECT * FROM Departure_Total_Per_Month  ('Airbus A380');

-- UDF 3
-- To Retieve Information of Passenger Details Based on Seat_ID

IF OBJECT_ID (N'Passenger_Details', N'IF') IS NOT NULL
    DROP FUNCTION Passenger_Details;
go
CREATE FUNCTION Passenger_Details (@seat_id VARCHAR(25))
RETURNS TABLE
AS
RETURN
(
        SELECT sd.Seat_ID,fd.Flight_ID,fd.Airplane_type,tc.Travel_Class_Name,p.P_FirstName, p.P_LastName, p.P_Email, p.P_PhoneNumber
        FROM Passenger p INNER JOIN Reservation r ON p.Passenger_ID = r.Reservation_ID 
                         INNER JOIN Seat_Details sd ON sd.Seat_ID = r.Seat_ID
                         INNER JOIN Flight_Details fd ON fd.Flight_ID = sd.Flight_ID
                         LEFT JOIN Travel_Class tc ON tc.Travel_Class_ID = sd.Travel_Class_ID
                         WHERE sd.Seat_ID = @seat_id
);

GO


select * from 

select * from Passenger_Details('41100FCL')