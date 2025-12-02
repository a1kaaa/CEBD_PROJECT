import sqlite3
from actions import database_functions
from actions import database_queries
from utils import db as db_utils

# Connexion à la base de données
data = sqlite3.connect("data/jo.db")
# Activer l'application des contraintes de clé étrangère dans SQLite
# (SQLite désactive foreign_keys par défaut pour les connexions)
data.execute("PRAGMA foreign_keys = ON")

# Fonction permettant de quitter le programme
def quitter():
    print("Au revoir !")
    exit(0)

# Association des actions aux fonctions
actions = {
    "1": lambda: database_functions.database_create(data),
    "2": lambda: database_functions.database_insert(data),
    "3": lambda: database_functions.database_delete(data),
    "4": lambda: database_queries.liste_epreuves(data, "Ski alpin"),
    "5": lambda: database_queries.membres_equipe(data, int(input("Entrez le numéro\n"))),
    "6": lambda: database_functions.database_create_views(data),
    "7": lambda: database_functions.inscrire_sportif_epreuve(data,
                                                         int(input("Entrez numSp (ex: 1001) : ")),
                                                         int(input("Entrez numEp (ex: 10) : "))),
    "8": lambda: database_functions.database_create_triggers(data),
    "q": quitter
}

# Fonctions d'affichage du menu
def menu():
    print("\n=== Menu principal ===")
    print("1 - Créer la base de données")
    print("2 - Insérer les données du fichier Excel")
    print("3 - Supprimer la base de données")
    print("4 - Liste des épreuves de ski alpin")
    print("5 - Membres de l'équipe n° ?")
    print("6 - Créer les vues (fichier data/v0_views.sql)")
    print("7 - Inscrire un sportif à une épreuve individuelle")
    print("8 - Installer les triggers (fichier data/triggers.sql)")
    print("q - Quitter")

# Fonction principale
def main():
     # Appel du menu en boucle et gestion du choix
    while True:
        menu()
        choix = input("Votre choix : ").strip()
        action = actions.get(choix)
        if action:
            action()
        else:
            print("Choix invalide.")

# Appel de la fonction principale
main()