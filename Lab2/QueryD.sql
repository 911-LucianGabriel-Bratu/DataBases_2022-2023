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