use P4_FBS

-- TICKET VIEW 
go
create view Ticket as

select   P.Passenger_ID, P.P_FirstName, P.P_LastName, s.AirportName as Source ,d.AirportName as Destination, fd.Departure_Date_Time, fd.Arrival_Date_time, R.Seat_ID,
	     SD.Flight_ID, tc.Travel_Class_Name 
from Passenger P 
INNER JOIN  Reservation as r ON p.Passenger_ID=r.Passenger_ID 
INNER JOIN  Seat_Details as sd ON sd.Seat_ID=r.Seat_ID 
INNER JOIN Flight_Details fd ON fd.Flight_ID=sd.Flight_ID 
INNER JOIN Airport as d ON d.Airport_ID=fd.Destination_Airport_ID 
INNER JOIN Airport as s on s.Airport_ID=fd.Source_Airport_ID
INNER JOIN Travel_Class tc on sd.Travel_Class_ID=tc.Travel_Class_ID



-- RESERVATION PAYMENT VIEW 
GO
CREATE VIEW Reservation_Status
AS
SELECT r.Reservation_ID,ps.Payment_Status_YN FROM Reservation r INNER JOIN Payment_Status ps on r.Reservation_ID=ps.Reservation_ID; 


--Services offered to classes
GO
CREATE VIEW TravelClass_Services
AS
select t.Travel_Class_Name as Travel_Class ,fs.[Service_Name], s.Offered_YN AS Offers,s.From_Month ,s.To_Month from 
Travel_Class t  INNER JOIN Service_Offering s on t.Travel_Class_ID = s.Travel_Class_ID
INNER JOIN Flight_Service fs on s.Service_ID = fs.Service_ID



