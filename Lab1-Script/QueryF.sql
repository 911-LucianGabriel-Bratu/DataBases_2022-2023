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