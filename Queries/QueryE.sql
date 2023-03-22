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