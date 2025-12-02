# Fonction permettant de créer les triggers
def create_triggers(data):
    print("\nCréation des triggers")
    try:
        cursor = data.cursor()
        # Exécuter toutes les commandes SQL du fichier trigger.sql
        with open("data/triggers.sql", "r") as f:
            sql_script = f.read()
        cursor.executescript(sql_script)  # Pour SQLite, pour PostgreSQL utiliser cursor.execute
    except Exception as e:
        data.rollback()
        print("Impossible de créer les triggers : " + repr(e))
    else:
        data.commit()
        print("Les triggers ont été créés avec succès.")
