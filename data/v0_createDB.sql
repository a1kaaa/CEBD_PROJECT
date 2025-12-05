CREATE TABLE IF NOT EXISTS LesDisciplines (
  nomDi VARCHAR(100) PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS LesEpreuves (
  numEp INT PRIMARY KEY,
  nomEp VARCHAR(200) NOT NULL,
  formeEp VARCHAR(20) NOT NULL CHECK (formeEp IN ('individuelle','par equipe','par couple')),
  categorieEp VARCHAR(10) NOT NULL CHECK (categorieEp IN ('feminin','masculin','mixte')),
  nbSportifsEp INT NULL CHECK(nbSportifsEp > 0),
  dateEp DATE,
  nomDi VARCHAR(100) NOT NULL REFERENCES LesDisciplines(nomDi) -- References c'est genre les foreign keys
);

CREATE TABLE IF NOT EXISTS LesSportifs (
  numSp INT PRIMARY KEY CHECK (numSp BETWEEN 1000 AND 1500),
  nomSp VARCHAR(100) NOT NULL,
  prenomSp VARCHAR(100) NOT NULL,
  dateNaisSp DATE NOT NULL,
  categorieSp VARCHAR(10) NOT NULL CHECK (categorieSp IN ('feminin','masculin')),
  pays VARCHAR(100) NOT NULL,
  UNIQUE (nomSp, prenomSp)
);

CREATE TABLE IF NOT EXISTS LesEquipes (
  numEq INT PRIMARY KEY CHECK (numEq BETWEEN 1 AND 100),
  pays VARCHAR(100) NOT NULL
);


CREATE TABLE IF NOT EXISTS AppartenanceEquipe (
  numSp INT NOT NULL REFERENCES LesSportifs(numSp),
  numEq INT NOT NULL REFERENCES LesEquipes(numEq),
  PRIMARY KEY (numSp, numEq)
  -- zéquipe >= 2 membres /// trigger 
  -- membres et équipe même pays trigger
);

CREATE TABLE IF NOT EXISTS ParticipationIndiv (
  numEp INT NOT NULL REFERENCES LesEpreuves(numEp),
  numSp INT NOT NULL REFERENCES LesSportifs(numSp),
  PRIMARY KEY (numEp, numSp)
  -- LesEpreuves.formeEp = 'individuelle' ttrigger)
  -- LesSportifs.categorieSp marche avec LesEpreuves.categorieEp (trigger)
);

CREATE TABLE IF NOT EXISTS ParticipationEquipe (
  numEp INT NOT NULL REFERENCES LesEpreuves(numEp),
  numEq INT NOT NULL REFERENCES LesEquipes(numEq),
  PRIMARY KEY (numEp, numEq)
  -- LesEpreuves.nomDi = LesEquipes.nomDi (trigger)
  -- LesEpreuves.formeEp = 'par equipe' (trigger)
);

CREATE TABLE IF NOT EXISTS ParticipationCouple (
  numEp INT NOT NULL REFERENCES LesEpreuves(numEp),
  numEq INT NOT NULL REFERENCES LesEquipes(numEq),
  PRIMARY KEY (numEp, numEq)
  -- LesEpreuves.formeEp = 'par couple'
);

CREATE TABLE IF NOT EXISTS MedailleParRang (
  rang INT PRIMARY KEY CHECK (rang > 0),
  medaille VARCHAR(10) NOT NULL CHECK (medaille IN ('or','argent','bronze'))
);

CREATE TABLE IF NOT EXISTS ClassementIndiv (
  numEp INT NOT NULL REFERENCES LesEpreuves(numEp),
  rang INT NOT NULL,
  numSp INT NOT NULL REFERENCES LesSportifs(numSp),
  PRIMARY KEY (numEp, rang),
  UNIQUE (numEp, numSp)
  -- medaille déterminée par JOIN MedailleParRang ON rang
);

CREATE TABLE IF NOT EXISTS ClassementEquipe (
  numEp INT NOT NULL REFERENCES LesEpreuves(numEp),
  rang INT NOT NULL,
  numEq INT NOT NULL REFERENCES LesEquipes(numEq),
  PRIMARY KEY (numEp, rang),
  UNIQUE (numEp, numEq)
  -- medaille par JOIN MedailleParRang ON rang
);

CREATE TABLE IF NOT EXISTS ClassementCouple (
  numEp INT NOT NULL REFERENCES LesEpreuves(numEp),
  rang INT NOT NULL,
  numEq INT NOT NULL REFERENCES LesEquipes(numEq),
  PRIMARY KEY (numEp, rang),
  UNIQUE (numEp, numEq)
  -- LesEpreuves.formeEp = 'par couple'
);


-- on met les médailles
INSERT OR IGNORE INTO MedailleParRang  (rang, medaille)
VALUES
(1, 'or'),
(2, 'argent'),
(3, 'bronze');


