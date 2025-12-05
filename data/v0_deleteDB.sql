PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS LesEpreuves;
DROP TABLE IF EXISTS LesEquipes;
DROP TABLE IF EXISTS LesSportifs;
DROP TABLE IF EXISTS LesDisciplines;
DROP TABLE IF EXISTS AppartenanceEquipe;
DROP TABLE IF EXISTS ParticipationIndiv;
DROP TABLE IF EXISTS ParticipationEquipe;
DROP TABLE IF EXISTS ClassementEquipe;
DROP TABLE IF EXISTS ClassementIndiv;
DROP TABLE IF EXISTS MedailleParRang;
DROP TABLE IF EXISTS ParticipationCouple;
DROP TABLE IF EXISTS ClassementCouple;

DROP VIEW IF EXISTS LesAgesSportifs;
DROP VIEW IF EXISTS LesNbsEquipiers;
DROP VIEW IF EXISTS LesAgesMoyens_EquipesGold;
DROP VIEW IF EXISTS ClassementPaysMedaille;

DROP TRIGGER IF EXISTS trg_verif_participation_indiv;
DROP TRIGGER IF EXISTS trg_verif_participation_equipe;
DROP TRIGGER IF EXISTS trg_verif_participation_couple;
DROP TRIGGER IF EXISTS trg_classementindiv_verif_participation;
DROP TRIGGER IF EXISTS trg_classementequipe_verif_participation;
DROP TRIGGER IF EXISTS trg_classementcouple_verif_participation;

PRAGMA foreign_keys = ON;