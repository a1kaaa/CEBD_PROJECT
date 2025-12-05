-- LesAgesSportifs
CREATE VIEW IF NOT EXISTS LesAgesSportifs AS
SELECT
  numSp,
  nomSp,
  prenomSp,
  pays,
  categorieSp,
  dateNaisSp,
  strftime('%Y', 'now') - strftime('%Y', dateNaisSp) - (strftime('%m-%d', 'now') < strftime('%m-%d', dateNaisSp)) AS ageSp
FROM LesSportifs;



-- LesNbsEquipiers
CREATE VIEW IF NOT EXISTS LesNbsEquipiers AS
SELECT
  numEq,
  COUNT(numSp) AS nbEquipiersEq
FROM AppartenanceEquipe
GROUP BY numEq;


-- Moyenne des âges des équipes ayant gagné la médaille d'or
CREATE VIEW IF NOT EXISTS LesAgesMoyens_EquipesGold AS
SELECT
  e.numEq,
  AVG( (julianday('now') - julianday(s.dateNaisSp)) / 365.25 ) AS ageMoyenEq
FROM LesEquipes e
JOIN AppartenanceEquipe a ON e.numEq = a.numEq
JOIN LesSportifs s ON a.numSp = s.numSp
WHERE e.numEq IN (
  SELECT DISTINCT numEq FROM ClassementEquipe WHERE rang = 1
)
GROUP BY e.numEq;


-- Classement des pays par nombre de médailles
CREATE VIEW IF NOT EXISTS ClassementPaysMedaille AS
SELECT
  pays,
  SUM(CASE WHEN medaille = 'or' THEN 1 ELSE 0 END) AS nbOr,
  SUM(CASE WHEN medaille = 'argent' THEN 1 ELSE 0 END) AS nbArgent,
  SUM(CASE WHEN medaille = 'bronze' THEN 1 ELSE 0 END) AS nbBronze
FROM (
  -- individuelle
  SELECT s.pays AS pays, m.medaille AS medaille
  FROM ClassementIndiv ci
  JOIN MedailleParRang m ON ci.rang = m.rang
  JOIN LesSportifs s ON ci.numSp = s.numSp

  UNION ALL

  -- équipe
  SELECT e.pays AS pays, m.medaille AS medaille
  FROM ClassementEquipe ce
  JOIN MedailleParRang m ON ce.rang = m.rang
  JOIN LesEquipes e ON ce.numEq = e.numEq

  UNION ALL
  SELECT s.pays AS pays, m.medaille AS medaille
  FROM ClassementCouple CC
  JOIN MedailleParRang m ON CC.rang = m.rang
  JOIN LesEquipes s ON CC.numEq = s.numEq
)
GROUP BY pays
ORDER BY nbOr DESC, nbArgent DESC, nbBronze DESC;


