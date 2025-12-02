-- Rewritten triggers in SQLite syntax

-- 1) ParticipationIndiv: verify epreuve exists, is 'individuelle', and category matches
CREATE TRIGGER IF NOT EXISTS trg_verif_participation_indiv
BEFORE INSERT ON ParticipationIndiv
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) IS NULL
            THEN RAISE(ABORT, 'Epreuve inexistante')
            -- Rewritten triggers in SQLite syntax

            -- 1) ParticipationIndiv: verify epreuve exists, is 'individuelle', and category matches
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


            -- 2) ParticipationEquipe: verify epreuve exists, equipe exists, same discipline,
            --    correct forme (not 'individuelle'), and for 'par couple' teams must have exactly 2 members
            CREATE TRIGGER IF NOT EXISTS trg_verif_participation_equipe
            BEFORE INSERT ON ParticipationEquipe
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) IS NULL
                        THEN RAISE(ABORT, 'Epreuve inexistante')
                    WHEN (SELECT nomDi FROM LesEquipes WHERE numEq = NEW.numEq) IS NULL
                        THEN RAISE(ABORT, 'Equipe inexistante')
                    WHEN (SELECT nomDi FROM LesEpreuves WHERE numEp = NEW.numEp) <> (SELECT nomDi FROM LesEquipes WHERE numEq = NEW.numEq)
                        THEN RAISE(ABORT, 'Incompatible: discipline de l''equipe et de l''epreuve differente')
                    WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) = 'individuelle'
                        THEN RAISE(ABORT, 'Erreur: cette epreuve est individuelle, ne peut pas etre pour une equipe')
                    WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) = 'par couple' AND
                         (SELECT COUNT(*) FROM AppartenanceEquipe WHERE numEq = NEW.numEq) <> 2
                        THEN RAISE(ABORT, 'Erreur: un couple doit avoir exactement 2 membres')
                END;
            END;


            -- 3) AppartenanceEquipe: ensure sportif and equipe exist and have same country
            CREATE TRIGGER IF NOT EXISTS trg_appartenance_pays_check
            BEFORE INSERT ON AppartenanceEquipe
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN (SELECT pays FROM LesSportifs WHERE numSp = NEW.numSp) IS NULL
                        THEN RAISE(ABORT, 'Sportif inconnu')
                    WHEN (SELECT pays FROM LesEquipes WHERE numEq = NEW.numEq) IS NULL
                        THEN RAISE(ABORT, 'Equipe inconnue')
                    WHEN (SELECT pays FROM LesSportifs WHERE numSp = NEW.numSp) <> (SELECT pays FROM LesEquipes WHERE numEq = NEW.numEq)
                        THEN RAISE(ABORT, 'Sportif et equipe doivent avoir le meme pays')
                END;
            END;


            -- 4) Prevent deleting a membership that would leave an equipe with fewer than 2 members
            CREATE TRIGGER IF NOT EXISTS trg_appartenance_no_underflow
            BEFORE DELETE ON AppartenanceEquipe
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN ((SELECT COUNT(*) FROM AppartenanceEquipe WHERE numEq = OLD.numEq) - 1) < 2
                        THEN RAISE(ABORT, 'Impossible: une equipe doit avoir au moins 2 membres')
                END;
            END;


            -- 5) ClassementIndiv: verify the sportif participated in the epreuve, epreuve form, and rang reasonable
            CREATE TRIGGER IF NOT EXISTS trg_classementindiv_verif_participation
            BEFORE INSERT ON ClassementIndiv
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT EXISTS(SELECT 1 FROM ParticipationIndiv WHERE numEp = NEW.numEp AND numSp = NEW.numSp)
                        THEN RAISE(ABORT, 'Le sportif n''a pas participe a cette epreuve')
                    WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) <> 'individuelle'
                        THEN RAISE(ABORT, 'Epreuve non individuelle pour un classement individuel')
                    WHEN NEW.rang > (SELECT COUNT(*) FROM ParticipationIndiv WHERE numEp = NEW.numEp)
                        THEN RAISE(ABORT, 'Rang impossible: superieur au nombre de participants')
                END;
            END;


            -- 6) ClassementEquipe: verify the equipe participated, epreuve form, and rang reasonable
            CREATE TRIGGER IF NOT EXISTS trg_classementequipe_verif_participation
            BEFORE INSERT ON ClassementEquipe
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT EXISTS(SELECT 1 FROM ParticipationEquipe WHERE numEp = NEW.numEp AND numEq = NEW.numEq)
                        THEN RAISE(ABORT, 'L''equipe n''a pas participe a cette epreuve')
                    WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) = 'individuelle'
                        THEN RAISE(ABORT, 'Epreuve individuelle: ne peut pas avoir classement par equipe')
                    WHEN NEW.rang > (SELECT COUNT(*) FROM ParticipationEquipe WHERE numEp = NEW.numEp)
                        THEN RAISE(ABORT, 'Rang impossible: superieur au nombre d''equipes participantes')
                END;
            END;
                        THEN RAISE(ABORT, 'Epreuve non individuelle pour un classement individuel')
                    WHEN NEW.rang > (SELECT COUNT(*) FROM ParticipationIndiv WHERE numEp = NEW.numEp)
                        THEN RAISE(ABORT, 'Rang impossible: superieur au nombre de participants')
                END;
            END;
            /

            -- 6) ClassementEquipe: verify the equipe participated, epreuve form, and rang reasonable
            CREATE TRIGGER IF NOT EXISTS trg_classementequipe_verif_participation
            BEFORE INSERT ON ClassementEquipe
            FOR EACH ROW
            BEGIN
                SELECT CASE
                    WHEN NOT EXISTS(SELECT 1 FROM ParticipationEquipe WHERE numEp = NEW.numEp AND numEq = NEW.numEq)
                        THEN RAISE(ABORT, 'L''equipe n''a pas participe a cette epreuve')
                    WHEN (SELECT formeEp FROM LesEpreuves WHERE numEp = NEW.numEp) = 'individuelle'
                        THEN RAISE(ABORT, 'Epreuve individuelle: ne peut pas avoir classement par equipe')
                    WHEN NEW.rang > (SELECT COUNT(*) FROM ParticipationEquipe WHERE numEp = NEW.numEp)
                        THEN RAISE(ABORT, 'Rang impossible: superieur au nombre d''equipes participantes')
                END;
            END;


