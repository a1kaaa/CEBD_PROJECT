-- 1) View: LesAgesSportifs
-- Colonnes: numSp, nomSp, prenomSp, pays, categorieSp, dateNaisSp, ageSp (in years, integer)
CREATE VIEW IF NOT EXISTS LesAgesSportifs AS
SELECT
  numSp,
  nomSp,
  prenomSp,
  pays,
  categorieSp,
  dateNaisSp,
  CAST((julianday('now') - julianday(dateNaisSp)) / 365.25 AS INTEGER) AS ageSp
FROM LesSportifs;


-- 2) View: LesNbsEquipiers
-- Colonnes: numEq, nbEquipiersEq
CREATE VIEW IF NOT EXISTS LesNbsEquipiers AS
SELECT
  numEq,
  COUNT(numSp) AS nbEquipiersEq
FROM AppartenanceEquipe
GROUP BY numEq;


-- 3) View: Moyenne des âges des équipes ayant gagné la médaille d'or
-- Colonnes: numEq, ageMoyenEq
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


-- 4) View: Classement des pays par nombre de médailles
-- Colonnes: pays, nbOr, nbArgent, nbBronze
CREATE VIEW IF NOT EXISTS ClassementPaysMedaille AS
SELECT
  pays,
  SUM(CASE WHEN medaille = 'or' THEN 1 ELSE 0 END) AS nbOr,
  SUM(CASE WHEN medaille = 'argent' THEN 1 ELSE 0 END) AS nbArgent,
  SUM(CASE WHEN medaille = 'bronze' THEN 1 ELSE 0 END) AS nbBronze
FROM (
  -- médailles individuelles
  SELECT s.pays AS pays, m.medaille AS medaille
  FROM ClassementIndiv ci
  JOIN MedailleParRang m ON ci.rang = m.rang
  JOIN LesSportifs s ON ci.numSp = s.numSp

  UNION ALL

  -- médailles par équipe
  SELECT e.pays AS pays, m.medaille AS medaille
  FROM ClassementEquipe ce
  JOIN MedailleParRang m ON ce.rang = m.rang
  JOIN LesEquipes e ON ce.numEq = e.numEq
)
GROUP BY pays
ORDER BY nbOr DESC, nbArgent DESC, nbBronze DESC;
