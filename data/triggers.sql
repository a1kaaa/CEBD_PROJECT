-- 1 - L'eépreuve est individuelle: vérifier que l'épreuve existe, le sportif existe, et les catégories correspondent
CREATE TRIGGER IF NOT EXISTS trg_verif_participation_indiv
BEFORE INSERT ON ParticipationIndiv
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) IS NULL
            THEN RAISE(ABORT, 'Epreuve inexistante')
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) <> 'individuelle'
            THEN RAISE(ABORT, 'Impossible d''inscrire: l''epreuve n''est pas individuelle')
        WHEN (SELECT categorieSp FROM LesSportifs WHERE numSp = NEW.numSp) IS NULL
            THEN RAISE(ABORT, 'Sportif inexistant')
        WHEN (SELECT categorieSp FROM LesSportifs WHERE numSp = NEW.numSp) <> (SELECT categorieEp FROM LesEpreuves WHERE numEp = NEW.numEp)
            THEN RAISE(ABORT, 'Incompatible: categorie du sportif ne correspond pas a la categorie de l''epreuve')
    END;
END;


-- 2 - vérifier que l'épreuve existe, l'équipe existe, et formeEp = 'par équipe'.
CREATE TRIGGER IF NOT EXISTS trg_verif_participation_equipe
BEFORE INSERT ON ParticipationEquipe
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) IS NULL
            THEN RAISE(ABORT, 'Epreuve inexistante')
        WHEN (SELECT numEq FROM LesEquipes WHERE numEq = NEW.numEq) IS NULL
            THEN RAISE(ABORT, 'Equipe inexistante')
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) <> 'par equipe'
            THEN RAISE(ABORT, 'Erreur: cette epreuve n''est pas par equipe')
    END;
END;


-- 3 - vérifier que l'épreuve existe, l'équipe existe, et les catégories correspondent, et formeEp = 'par couple'.
CREATE TRIGGER IF NOT EXISTS trg_verif_participation_couple
BEFORE INSERT ON ParticipationCouple
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) IS NULL
            THEN RAISE(ABORT, 'Epreuve inexistante')
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) <> 'par couple'
            THEN RAISE(ABORT, 'Erreur: cette epreuve n''est pas par couple')
        WHEN (SELECT numEq FROM LesEquipes WHERE numEq = NEW.numEq) IS NULL
            THEN RAISE(ABORT, 'Equipe inexistante')
        WHEN (SELECT COUNT(*) FROM AppartenanceEquipe WHERE numEq = NEW.numEq) <> 2
            THEN RAISE(ABORT, 'Un couple doit avoir exactement 2 membres')
        WHEN (SELECT COUNT(DISTINCT S.pays)
              FROM AppartenanceEquipe AE
              JOIN LesSportifs S ON AE.numSp = S.numSp
              WHERE AE.numEq = NEW.numEq) > 1
            THEN RAISE(ABORT, 'Tous les membres du couple doivent être du même pays')
    END;
END;



-- 5 - Sportif a participé à l'épreuve, l'épreuve est individuelle, au moins 3 participants
CREATE TRIGGER IF NOT EXISTS trg_classementindiv_verif_participation
BEFORE INSERT ON ClassementIndiv
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NOT EXISTS(SELECT 1 FROM ParticipationIndiv WHERE numEp = NEW.numEp AND numSp = NEW.numSp)
            THEN RAISE(ABORT, 'Le sportif n''a pas participe a cette epreuve')
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) <> 'individuelle'
            THEN RAISE(ABORT, 'Epreuve non individuelle pour un classement individuel')
        WHEN (SELECT COUNT(*) FROM ParticipationIndiv WHERE numEp = NEW.numEp) < 3
            THEN RAISE(ABORT, 'Moins de 3 sportifs inscrits: classement individuel impossible')
        WHEN NEW.rang > (SELECT COUNT(*) FROM ParticipationIndiv WHERE numEp = NEW.numEp)
            THEN RAISE(ABORT, 'Rang impossible: superieur au nombre de participants')
    END;
END;


-- 6 - Equipe a participé à l'épreuve, l'épreuve est par équipe, au moins 3 participants
CREATE TRIGGER IF NOT EXISTS trg_classementequipe_verif_participation
BEFORE INSERT ON ClassementEquipe
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NOT EXISTS(SELECT 1 FROM ParticipationEquipe WHERE numEp = NEW.numEp AND numEq = NEW.numEq)
            THEN RAISE(ABORT, 'L''equipe n''a pas participe a cette epreuve')
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) <> 'par equipe'
            THEN RAISE(ABORT, 'Epreuve non par equipe pour ClassementEquipe')
        WHEN (SELECT COUNT(*) FROM ParticipationEquipe WHERE numEp = NEW.numEp) < 3
            THEN RAISE(ABORT, 'Moins de 3 equipes inscrites: classement equipe impossible')
        WHEN NEW.rang > (SELECT COUNT(*) FROM ParticipationEquipe WHERE numEp = NEW.numEp)
            THEN RAISE(ABORT, 'Rang impossible: superieur au nombre d''equipes participantes')
    END;
END;


-- 7 Couple a participé à l'épreuve, l'épreuve est par couple, au moins 3 participants
CREATE TRIGGER IF NOT EXISTS trg_classementcouple_verif_participation
BEFORE INSERT ON ClassementCouple
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NOT EXISTS(SELECT 1 FROM ParticipationCouple WHERE numEp = NEW.numEp AND numEq = NEW.numEq)
            THEN RAISE(ABORT, 'Le couple n''a pas participe a cette epreuve')
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) <> 'par couple'
            THEN RAISE(ABORT, 'Epreuve non par couple pour ClassementCouple')
        WHEN (SELECT COUNT(*) FROM ParticipationCouple WHERE numEp = NEW.numEp) < 3
            THEN RAISE(ABORT, 'Moins de 3 couples inscrits: classement couple impossible')
        WHEN NEW.rang > (SELECT COUNT(*) FROM ParticipationCouple WHERE numEp = NEW.numEp)
            THEN RAISE(ABORT, 'Rang impossible: superieur au nombre de couples participants')
    END;
END;


