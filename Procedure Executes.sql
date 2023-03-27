USE P4_FBS
go
--test case
declare @display_available char(1)
EXEC Flight_Availability '2022-12-12','2022-12-13',@available=@display_available OUTPUT
PRINT cast(@display_available as varchar)+ ' There are flights which are available for booking on these dates'

--test case
go
Declare @flag1 bit
EXEC [P4_FBS].[dbo].[UpdateFlightDetails]  @flag1 output, @FlightID = 100 ,
                                                         @DeptDateTime = '2022-12-12 15:50:59.997',
                                                         @ArivalDateTime = '2022-12-13 15:50:59.997', 
                                                         @AirplaneType = 'Airbus A380'
if @flag1=1 print 'Flight Details Successfully Updated'
else
 print 'Encountered Error'


--test cases
go

    EXEC [P4_FBS].[dbo].[PassengerCRUD] @Action = 'SELECT'

    EXEC [P4_FBS].[dbo].[PassengerCRUD] @Action = 'INSERT' ,
    @Passenger_ID = 12 ,
    @FName = 'Shweta', 
    @LName = 'Garg',
    @Email = 'shwetagarg34.sg@gmail.com',
    @PNumber = 8976432265, 
    @Address = 'Smruti Appartment', 
    @city = 'Pune',
    @State = 'MH', 
    @Zipcode = '42203', 
    @Country = 'India'

  EXEC  [P4_FBS].[dbo].[PassengerCRUD] @Action = 'UPDATE',
    @Passenger_ID = 12 ,
    @FName = 'Shweta', 
    @LName = 'Garg',
    @Email = 'shwetagarg94.sg@gmail.com',
    @PNumber = 8976432265, 
    @Address = 'Smruti Appartment', 
    @city = 'Mumbai',
    @State = 'MH', 
    @Zipcode = '42500', 
    @Country = 'India'        
                  
EXEC [P4_FBS].[dbo].[PassengerCRUD] @Action= 'DELETE',
                  @Passenger_ID = 12


go
--test case
declare @display_date date
EXEC UpdatePayment  1,@paid_date=@display_date  OUTPUT
SELECT @display_date AS Date_Paid
PRINT 'The Passenger paid the amount on ' + cast(@display_date as varchar)
