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