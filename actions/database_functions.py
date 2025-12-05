import sys
from utils import db
from utils import excel_extractor

# Fonction permettant de créer la base de données
def database_create(data):
    print("\nCréation de la base de données")
    try:
        # On exécute les requêtes du fichier de création
        db.updateDBfile(data, "data/v0_createDB.sql")
    except Exception as e:
        # En cas d'erreur, on affiche un message
        print("L'erreur suivante s'est produite pendant lors de la création de la base : " + repr(e) + ".")
    else:
        # Si tout s'est bien passé, on affiche le message de succès et on commit
        print("La base de données a été créée avec succès.")
        data.commit()

# Fonction permettant d'insérer les données dans la base
def database_insert(data):
    print("\nInsertion des données dans la base.")
    try:
        # on lit les données dans le fichier Excel
        excel_extractor.read_excel_file_V0(data, "data/LesJO.xlsx")
    except Exception as e:
        # En cas d'erreur, on affiche un message
        print("L'erreur suivante s'est produite lors de l'insertion des données : " + repr(e) + ".", file=sys.stderr)
    else:
        # Si tout s'est bien passé, on affiche le message de succès et on commit
        print("Un jeu de test a été inséré dans la base avec succès.")
        data.commit()

# Fonction permettant de supprimer la base de données
def database_delete(data):
    print("\nSuppression de la base de données.")
    try:
        # On exécute les requêtes du fichier de suppression
        db.updateDBfile(data, "data/v0_deleteDB.sql")
    except Exception as e:
        # En cas d'erreur, on affiche un message
        print("Erreur lors de la suppression de la base de données : " + repr(e) + ".")
    else:
        # Si tout s'est bien passé, on affiche le message de succès (le commit est automatique pour un DROP TABLE)
        print("La base de données a été supprimée avec succès.")


def database_create_views(data):
    """
    Crée les vues définies dans le fichier SQL `data/v0_views.sql`.
    """
    print("\nCréation des vues à partir de data/v0_views.sql")
    try:
        db.updateDBfile(data, "data/v0_views.sql")
    except Exception as e:
        print("Erreur lors de la création des vues : " + repr(e) + ".")
    else:
        print("Les vues ont été créées avec succès.")
        data.commit()


def database_create_triggers(data):
    """
    Exécute les triggers définis dans `data/triggers.sql` (SQLite syntax).
    """
    print("\nInstallation des triggers à partir de data/triggers.sql")
    try:
        # triggers.sql contains trigger definitions which use semicolons internally.
        # updateDBfile expects trigger-separated files to use '/' as separator.
        db.updateDBfile(data, "data/triggers.sql", trigger=True)
    except Exception as e:
        print("Erreur lors de l'installation des triggers : " + repr(e) + ".")
    else:
        print("Les triggers ont été installés avec succès.")
        data.commit()


def inscrire_sportif_epreuve(data, numSp, numEp):
    """
    Inscrit un sportif (numSp) à une épreuve individuelle (numEp).
    """
    print(f"\nInscription du sportif {numSp} à l'épreuve {numEp}")

    try:
        cursor = data.cursor()
        cursor.execute(
            """
            INSERT INTO ParticipationIndiv (numEp, numSp)
            VALUES (?, ?)
            """,
            (numEp, numSp)
        )
    except Exception as e:
        print("Erreur lors de l'inscription :", repr(e))
    else:
        data.commit()
        print(f"Sportif {numSp} inscrit à l'épreuve {numEp} avec succès.")


def inscrire_equipe_epreuve(data, numEq, numEp):
    """
    Inscrit une équipe (numEq) à une épreuve par équipe (numEp).
    """
    print(f"\nInscription de l'équipe {numEq} à l'épreuve {numEp}")

    try:
        cursor = data.cursor()
        cursor.execute(
            """
            INSERT INTO ParticipationEquipe (numEp, numEq)
            VALUES (?, ?)
            """,
            (numEp, numEq)
        )
    except Exception as e:
        print("Erreur lors de l'inscription :", repr(e))
    else:
        data.commit()
        print(f"Équipe {numEq} inscrite à l'épreuve {numEp} avec succès.")


def inscrire_couple_epreuve(data, numEq, numEp):
    """
    Inscrit un couple (numEq) à une épreuve en couple (numEp).
    """
    print(f"\nInscription du couple {numEq} à l'épreuve {numEp}")

    try:
        cursor = data.cursor()
        cursor.execute(
            """
            INSERT INTO ParticipationCouple (numEp, numEq)
            VALUES (?, ?)
            """,
            (numEp, numEq)
        )
    except Exception as e:
        print("Erreur lors de l'inscription :", repr(e))
    else:
        data.commit()
        print(f"Couple {numEq} inscrit à l'épreuve {numEp} avec succès.")