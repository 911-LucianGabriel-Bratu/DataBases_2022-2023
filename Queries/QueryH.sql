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

--Expand this so in having it doesn't have the same argument by which it groups by. 