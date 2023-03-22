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