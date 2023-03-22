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