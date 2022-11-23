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