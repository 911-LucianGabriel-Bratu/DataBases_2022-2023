DROP TABLE Has_In_Inventory
DROP TABLE Performs_maintenance
DROP TABLE Instruments_Expert
DROP TABLE Cashier
DROP TABLE Workshop_Master
DROP TABLE Janitor
DROP TABLE Instruments_Left_For_Maintenance
DROP TABLE Instruments_For_Sale
DROP TABLE Client
DROP TABLE Musical_instruments_shop

CREATE TABLE Musical_instruments_shop
(
miID INT PRIMARY KEY,
address char(30),
rating INT,
since DATE
)
CREATE TABLE Instruments_Expert
(
expID INT PRIMARY KEY,
miID INT REFERENCES Musical_instruments_shop(miID),
name char(20),
y_experience char(20)
)

CREATE TABLE Cashier
(
cID INT PRIMARY KEY,
miID INT REFERENCES Musical_instruments_shop(miID),
name char(20),
CNP char(20)
)

CREATE TABLE Workshop_Master
(
mID INT PRIMARY KEY,
miID INT REFERENCES Musical_instruments_shop(miID),
name char(20),
mastered_instrument char(20)
)

CREATE TABLE Janitor
(
jID INT PRIMARY KEY,
miID INT REFERENCES Musical_instruments_shop(miID),
name char(20),
CNP char(20)
)

CREATE TABLE Instruments_Left_For_Maintenance
(
mtID INT PRIMARY KEY,
manufacturer char(20)
)

CREATE TABLE Performs_maintenance
(
mID INT REFERENCES Workshop_Master(mID),
mtID INT REFERENCES Instruments_Left_For_Maintenance(mtID),
dueDate date,
PRIMARY KEY(mID, mtID, dueDate)
)

CREATE TABLE Client
(
cID INT PRIMARY KEY,
name char(20),
address char(20),
buget DECIMAL(10,2),
age INT
)

CREATE TABLE Instruments_For_Sale
(
insID INT PRIMARY KEY,
cID INT REFERENCES Client(cID),
manufacturer char(20),
price DECIMAL(10, 2),
purchaseDate date
)

CREATE TABLE Has_In_Inventory
(
insID INT REFERENCES Instruments_For_Sale(insID),
miID INT REFERENCES Musical_instruments_shop(miID),
quantity INT,
PRIMARY KEY(insID, miID)
)


--Musical instruments shop additions
INSERT INTO Musical_instruments_shop
VALUES
('100','Freedom Street','7','2000-10-19'),
('101','Republic Street','10','2008-11-10'),
('102','Springlawn Street','4','2002-08-09'),
('103','Silver Canoe Lane','10','2022-03-10'),
('104','Freedom Street','1','2010-10-19');

--Workshop masters additions
INSERT INTO Workshop_Master
VALUES
('100', '100', 'Andrew', 'Guitar'),
('101', '101', 'John', 'Piano'),
('102', '100', 'Peter', 'Violin'),
('103', '101', 'Johnny', 'Clarinet'),
('104', '102', 'Glenn', 'Guitar'),
('105', '102', 'Chris', 'Piano'),
('106', '103', 'Cartman', 'Guitar'),
('107', '103', 'Jesse', 'Piano');


--Clients additions
INSERT INTO Client
VALUES
('100', 'Bob', 'Grandiose Drive','679.99', '17'),
('101', 'Jef', 'Melody Drive','329.99', '21'),
('102', 'Ana', 'Golden Trout Way','229.99', '22'),
('103', 'Daniel', 'Meditation Lane','999.99', '15'),
('104', 'Bogdan', 'Loch Ness Road','99.99', '27'),
('105', 'Jordan', 'Fortune Road','123.00', '22'),
('106', 'Ana', 'Melody Drive','379.99', '20'),
('107', 'Ana', 'Fortune Street','456.99', '24'),
('108', 'Eric', 'Loch Ness Road','329.99', '30'),
('109', 'Buck', 'Loch Ness Road','678.99', '35'),
('110', 'Arnold', 'Golden Trout Way','45.99', '35');


--Instruments for sale additions
INSERT INTO Instruments_For_Sale
VALUES
('100', NULL, 'Ibanez', '999.99', NULL),
('101', NULL, 'Fender', '1029.99', NULL),
('102', '104', 'Gibson', '899.99', '2022-10-22'),
('103', NULL, 'Schecter', '499.99', NULL),
('104', '101', 'PRS', '379.99', '2022-09-21'),
('105', NULL, 'Ibanez', '456.99', NULL),
('106', NULL, 'Fender', '699.99', NULL),
('107', NULL, 'Squier', '199.99', NULL),
('108', NULL, 'Harley-Benton', '99.99', NULL),
('109', NULL, 'PRS', '299.99', NULL),
('110', NULL, 'Gibson', '679.99', NULL),
('111', NULL, 'Gibson', '999.99', NULL);


--Update section
UPDATE Client -- Update the name and address of the client with cID 100
SET name = 'Bob Ross', address = 'Artists Way'
WHERE cID = '100';

UPDATE Instruments_For_Sale
SET cID = '100', purchaseDate = '2022-10-22'
WHERE insID = '101';

UPDATE Instruments_For_Sale
SET cID = '103', purchaseDate = '2022-10-22'
WHERE insID = '100';

UPDATE Workshop_Master
SET mastered_instrument = 'Guitar'
WHERE mID = '105';


--Deletion section
DELETE FROM Musical_instruments_shop -- Referential Integrity constraint violation. Attempted to delete a store with the primary key being referenced in other tables
WHERE miID = '100';

DELETE FROM Instruments_For_Sale -- Delete all rows with products that have been purchased
WHERE cID IS NOT NULL AND purchaseDate IS NOT NULL;

DELETE FROM Client
WHERE name = 'Jef';

--Select the rating of all musical instruments shops that are either on Freedom Street or Silver Canoe Lane
SELECT M.rating

FROM Musical_instruments_shop M

WHERE M.address = 'Freedom Street' OR M.address = 'Silver Canoe Lane';

--Select all clients IDs who have purchased something or are 18 years old or older
SELECT C.cID
FROM Client C
WHERE C.age > 17
UNION
SELECT IFS.cID
FROM Instruments_For_Sale IFS
WHERE IFS.cID <> NULL AND IFS.purchaseDate <> NULL

--Select the names of all workshop masters that work at a shop on Freedom Street and have mastered guitar as an instrument
SELECT wm.name
FROM Workshop_Master wm, Musical_instruments_shop mis
WHERE wm.miID = mis.miID AND mis.address = 'Freedom Street'
INTERSECT
SELECT wm2.mastered_instrument
FROM Workshop_Master wm2
WHERE wm2.mastered_instrument = 'Guitar'

--Select the ordered names of all workshop masters who have mastered either Guitar, Violin or Clarinet
SELECT wm.name
FROM Workshop_Master wm
WHERE wm.mastered_instrument IN ('Guitar', 'Violin', 'Clarinet')
ORDER BY wm.name

--Select the instruments that have been sold and are manufactured by Gibson excepting those who were bought by Bogdan
SELECT IFS.cID, IFS.manufacturer
FROM Instruments_For_Sale IFS
WHERE IFS.manufacturer = 'Gibson' AND IFS.cID <> NULL AND IFS.purchaseDate <> NULL
EXCEPT
SELECT IFS2.cID, IFS2.manufacturer
FROM Client C, Instruments_For_Sale IFS2
WHERE C.name = 'Bogdan' and C.cID = IFS2.cID

--Select all musical instruments shops that aren't on streets Grandiose Drive, Melody Drive and Golden Trout Way
SELECT *
FROM Musical_instruments_shop mis
WHERE mis.address NOT IN ('Grandiose Drive', 'Melody Drive', 'Golden Trout Way')

--Select all staff names working at a shop
SELECT j.name, c.name, wm.name, ie.name
FROM Musical_instruments_shop mis
INNER JOIN Janitor j
	on j.miID = mis.miID
INNER JOIN Cashier c
	on c.miID = mis.miID
INNER JOIN Workshop_Master wm
	on wm.miID = mis.miID
INNER JOIN Instruments_Expert ie
	on ie.miID = mis. miID

--Full join all instruments that are in a shop (including those in maintenance)
SELECT Instruments_Left_For_Maintenance.mtID, Instruments_Left_For_Maintenance.manufacturer, Instruments_For_Sale.insID, Instruments_For_Sale.manufacturer
FROM Instruments_Left_For_Maintenance
FULL OUTER JOIN Performs_maintenance ON Instruments_Left_For_Maintenance.mtID = Performs_maintenance.mtID
FULL OUTER JOIN Workshop_Master ON Performs_maintenance.mID = Workshop_Master.mID
FULL OUTER JOIN Musical_instruments_shop ON Workshop_Master.miID = Musical_instruments_shop.miID
FULL OUTER JOIN Has_In_Inventory ON Musical_instruments_shop.miID = Has_In_Inventory.miID
FULL OUTER JOIN Instruments_For_Sale ON Has_In_Inventory.insID = Instruments_For_Sale.insID

--Select all clients and any instruments they may have purchased
SELECT Client.name, Instruments_For_Sale.insID
FROM Client
LEFT JOIN Instruments_For_Sale ON Client.cID = Instruments_For_Sale.cID

--Select all cashiers and any musical instruments shops they may work at
SELECT Cashier.name, Musical_instruments_shop.miID
FROM Musical_instruments_shop
RIGHT JOIN Cashier ON Musical_instruments_shop.miID = Cashier.miID

--Find all unique manufacturers of all the instruments for sale in the inventories of all musical instruments shops on Freedom Street
SELECT DISTINCT ifs.manufacturer
FROM Instruments_For_Sale ifs
WHERE ifs.insID IN
	(
		SELECT hii.insID
		FROM Has_In_Inventory hii
		WHERE hii.miID IN
			(
				SELECT mis.miID
				FROM Musical_instruments_shop mis
				WHERE mis.address = 'Freedom Street'
			)
	)

--Find and order by the names of all unique workshop masters who have worked on instruments manufactured by Gibson
SELECT DISTINCT wm.name
FROM Workshop_Master wm
WHERE wm.mID IN
	(
		SELECT pm.mID
		FROM Performs_maintenance pm
		WHERE pm.mtID IN
			(
				SELECT ilfm.mtID
				FROM Instruments_Left_For_Maintenance ilfm
				WHERE ilfm.manufacturer = 'Gibson'
			)
	)
ORDER BY wm.name

--Find all the instruments that were on sale and still are on sale that are more expensive than any Gibson product
SELECT *
FROM Instruments_For_Sale ifs
WHERE ifs.price > ALL
	(
		SELECT ifs2.price
		FROM Instruments_For_Sale ifs2
		WHERE ifs2.manufacturer = 'Gibson'
	)

--Find all the manufacturers that had or still have a product listed for under 500 dollars and a quantity of over 5 in any musical instruments shop
SELECT DISTINCT ifs.manufacturer
FROM Instruments_For_Sale ifs
WHERE EXISTS
	(
	SELECT hii.insID
	FROM Has_In_Inventory hii
	WHERE ifs.price < 500 AND hii.insID = ifs.insID AND hii.quantity > 5
	)

--Find and order the unique names of all workshop masters who work on an instrument manufactured by Fender
SELECT DISTINCT wm.name
FROM Workshop_Master wm
WHERE EXISTS
	(
	SELECT pm.mID
	FROM Performs_maintenance pm
	WHERE wm.mID = pm.mID AND pm.mtID IN
		(
		SELECT ilfm.mtID
		FROM Instruments_Left_For_Maintenance ilfm
		WHERE ilfm.manufacturer = 'Fender'
		)
	)
ORDER BY wm.name

--Find the number of workshop masters for each mastered instrument
SELECT COUNT(wm.mID) AS nr_of_people, wm.mastered_instrument
FROM Workshop_Master wm
GROUP BY wm.mastered_instrument
ORDER BY COUNT(wm.mID) DESC;

--Find the number of instruments from each brand that have a price higher than 300
SELECT COUNT(IFS.insID) AS nr_of_instruments, IFS.manufacturer
FROM Instruments_For_Sale IFS
GROUP BY IFS.price, IFS.manufacturer
HAVING IFS.price > 300
ORDER BY COUNT(IFS.insID);

--Find the amount of clients for each age that are over 18 and are older than all clients named Ana
SELECT COUNT(c.age) AS nr_per_age, c.age
FROM Client c
GROUP BY c.age
HAVING c.age > 17 AND c.age > ALL (
	SELECT c2.age
	FROM Client c2
	WHERE c2.name = 'Ana'
)
ORDER BY COUNT(c.age) DESC;

--Find the number of instruments from each brand that have a price higher than 300 and are more expensive than any instrument sold by Fender
SELECT COUNT(IFS.insID) AS nr_of_instruments, IFS.manufacturer
FROM Instruments_For_Sale IFS
GROUP BY IFS.price, IFS.manufacturer
HAVING IFS.price > 300 AND IFS.price > ALL (
	SELECT IFS2.price
	FROM Instruments_For_Sale IFS2
	WHERE IFS2.manufacturer = 'Fender'
)
ORDER BY COUNT(IFS.insID);

--Find the first 3 records for all instruments with their price > average price of all instruments and have a quantity > 5
SELECT TOP 3 *
FROM (
	SELECT AVG(Instruments_For_Sale.price) AS average_price
	FROM Instruments_For_Sale
) AS Price, Has_In_Inventory hii, Instruments_For_Sale ifs
WHERE ifs.insID = hii.insID AND hii.quantity > 5 AND Price.average_price < ifs.price

--Find the top 5 records for all instruments with their price > average price of all client bugets
SELECT TOP 5 *
FROM (
	SELECT AVG(Client.buget) AS average_buget
	FROM Client
) AS Buget, Instruments_For_Sale
WHERE Instruments_For_Sale.price > Buget.average_buget

--Arithmetic operations in at least 3 select clauses VVV

--Find the instrument id, manufacturer and compute the total value (price*quantity) for all instruments
SELECT ifs.insID, ifs.manufacturer, ifs.price*hii.quantity AS 'Total price regarding quantity'
FROM Instruments_For_Sale ifs, Has_In_Inventory hii
WHERE ifs.insID = hii.insID

--Find the time in industry of all musical instruments shops
SELECT Musical_instruments_shop.miID, Musical_instruments_shop.address, DATEDIFF(year, Musical_instruments_shop.since, CAST(GETDATE() AS date)) AS 'Time in industry'
FROM Musical_instruments_shop

--There is a flash sale applicable to all products. Show all the instruments with a 10% off discount to each of them
SELECT ifs.insID, ifs.manufacturer, ifs.price-ifs.price*0.1 AS 'Price after discount'
FROM Instruments_For_Sale ifs
WHERE ifs.cID is NULL
ORDER BY ifs.price

--Find the oldest shop
SELECT *
FROM Musical_instruments_shop mis
WHERE DATEDIFF(year, mis.since, CAST(GETDATE() AS date)) > ALL
(
	SELECT DATEDIFF(year, mis2.since, CAST(GETDATE() AS date))
	FROM Musical_instruments_shop mis2
	WHERE mis2.address <> mis.address
)

--Rewritten in order to replace ALL with MAX (aggregation operator)
SELECT *
FROM Musical_instruments_shop mis
WHERE DATEDIFF(year, mis.since, CAST(GETDATE() AS date)) >
(
	SELECT MAX(DATEDIFF(year, mis2.since, CAST(GETDATE() AS date)))
	FROM Musical_instruments_shop mis2
	WHERE mis2.address <> mis.address
)

--Find the newest musical intruments shop
SELECT *
FROM Musical_instruments_shop mis
WHERE DATEDIFF(year, mis.since, CAST(GETDATE() AS date)) < ALL
(
	SELECT DATEDIFF(year, mis2.since, CAST(GETDATE() AS date))
	FROM Musical_instruments_shop mis2
	WHERE mis2.address <> mis.address
)

--Rewritten in order to replace ALL with MIN (aggregation operator)
SELECT *
FROM Musical_instruments_shop mis
WHERE DATEDIFF(year, mis.since, CAST(GETDATE() AS date)) <
(
	SELECT MIN(DATEDIFF(year, mis2.since, CAST(GETDATE() AS date)))
	FROM Musical_instruments_shop mis2
	WHERE mis2.address <> mis.address
)

--Find any instrument fitting perfectly for the buget of any client named Ana
SELECT *
FROM Instruments_For_Sale ifs
WHERE ifs.cID is NULL AND ifs.price = ANY
(
	SELECT c.buget
	FROM Client c
	WHERE c.name = 'Ana'
)

--Rewritten in order to replace ANY with IN (aggregation operator)
SELECT *
FROM Instruments_For_Sale ifs
WHERE ifs.cID is NULL AND ifs.price IN
(
	SELECT c.buget
	FROM Client c
	WHERE c.name = 'Ana'
)

--Find the clients that have the buget equal to the price of any Gibson product
SELECT *
FROM Client c
WHERE c.buget = ANY
(
	SELECT ifs.price
	FROM Instruments_For_Sale ifs
	WHERE ifs.manufacturer = 'Gibson'
)

--Rewritten in order to replace ANY with IN (aggregation operator)
SELECT *
FROM Client c
WHERE c.buget IN
(
	SELECT ifs.price
	FROM Instruments_For_Sale ifs
	WHERE ifs.manufacturer = 'Gibson'
)

----TODO FOR LAB2: 
--	--  ADD DATA FOR AT LEAST 4 TABLES (~DONE~)
--	--  UPDATE DATA FOR AT LEAST THREE TABLES (~DONE~)
--	--  DELETE DATA FOR AT LEAST 2 TABLES (~DONE~)
--	--	WHEN ADDING, UPDATING OR DELETING PERFORM AN OPERATION THAT VIOLATES THE REFERENTIAL INTEGRITY CONSTRAINTS (~DONE~)
--	--  In the UPDATE / DELETE statements, use at least once: {AND, OR, NOT},  {<,<=,=,>,>=,<> }, IS [NOT] NULL, IN, BETWEEN, LIKE (~DONE~)
--	--  2 queries with the union operation; use UNION [ALL] and OR (~DONE~)
--	--  2 queries with the intersection operation; use INTERSECT and IN (~DONE~)
--	--  2 queries with the difference operation; use EXCEPT and NOT IN (~DONE~)
--	--  4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator); one query will join at least 3 tables, while another one will join at least two many-to-many relationships
--	    --^^^ (~DONE~) but still take a look

--	--  2 queries with the IN operator and a subquery in the WHERE clause; in at least one case, the subquery must include a subquery in its own WHERE clause; (~DONE~)
--	--  2 queries with the EXISTS operator and a subquery in the WHERE clause; (~DONE~)
--	--  4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 
--			--2 of the latter will also have a subquery in the HAVING clause; use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;
				--^^^ (~DONE~)
--	--  2 queries with a subquery in the FROM clause; (~DONE~)
--  --  TOP in at least 2 queries. (~DONE~)
--  --  arithmetic expressions in the SELECT clause in at least 3 queries; (~DONE~)
--	--  4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator); rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.
--  --  ^^^^ (~DONE~)