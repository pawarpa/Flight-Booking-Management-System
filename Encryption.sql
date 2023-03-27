USE P4_FBS

go

--Create a master key for the database. 
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'group11';
-- drop master key 

-- very that master key exists
SELECT name KeyName,
  symmetric_key_id KeyID,
  key_length KeyLength,
  algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;

go
--Create a self signed certificate and name it EmpPass
CREATE CERTIFICATE FBS  
   WITH SUBJECT = 'FBS CERTIFICATE';  
GO  

--Create a symmetric key  with AES 256 algorithm using the certificate
-- as encryption/decryption method

CREATE SYMMETRIC KEY FBS_SM 
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE FBS;  
GO  
--drop SYMMETRIC KEY FBS_SM 

--Now we are ready to encrypt the password and also decrypt

-- Open the symmetric key with which to encrypt the data.  
OPEN SYMMETRIC KEY FBS_SM  
   DECRYPTION BY CERTIFICATE FBS;  
  


SELECT * FROM Passenger
-- Encrypt the value in column Password  with symmetric  key
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'75 Saint Alphonsus Street Jvue Apt 822')) WHERE Passenger_ID=1;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'1620 Westland Avenue Apt 25')) WHERE Passenger_ID=2;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'811 Huntington Ave')) WHERE Passenger_ID=3;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'1620 Longwood Apt 17 ')) WHERE Passenger_ID=4;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'15 taylor street Apt 1')) WHERE Passenger_ID=5;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'132 Meadow Lane')) WHERE Passenger_ID=6;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'1056 Front Street')) WHERE Passenger_ID=7;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'2000 Hillview Street')) WHERE Passenger_ID=8;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'50 Kingston Ave Apt 08')) WHERE Passenger_ID=9;
UPDATE Passenger set  P_Address = EncryptByKey(Key_GUID('FBS_SM'),  convert(varchar,'169 Saint Peters Street')) WHERE Passenger_ID=10;


GO  


SELECT * FROM Passenger
-- First open the symmetric key with which to decrypt the data.  
OPEN SYMMETRIC KEY FBS_SM  
   DECRYPTION BY CERTIFICATE FBS;  
 
   
SELECT *, 
    CONVERT(varchar, DecryptByKey([P_Address]))   
    AS 'Decrypted Address'  
    FROM dbo.Passenger;

