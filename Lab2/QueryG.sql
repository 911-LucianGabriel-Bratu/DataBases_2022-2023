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