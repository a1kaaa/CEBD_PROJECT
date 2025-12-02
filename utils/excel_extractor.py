import sqlite3
import pandas as pd
from sqlite3 import IntegrityError

def read_excel_file_V0(data: sqlite3.Connection, file):

    cursor = data.cursor()

    # ============================================================
    # 1) Chargement des sportifs + leurs équipes
    # ============================================================

    df_sportifs = pd.read_excel(file, sheet_name='LesSportifsEQ', dtype=str)
    df_sportifs = df_sportifs.where(pd.notnull(df_sportifs), None)

    for _, row in df_sportifs.iterrows():
        numSp = int(row["numSp"])
        nomSp = row["nomSp"]
        prenomSp = row["prenomSp"]
        pays = row["pays"]
        categorieSp = row["categorieSp"]
        dateNaisSp = row["dateNaisSp"]
        numEq = row["numEq"]  # peut être None

        # --- (1) Insertion du sportif ---
        try:
            cursor.execute("""
                INSERT OR IGNORE INTO LesSportifs(numSp, nomSp, prenomSp, dateNaisSp, categorieSp, pays)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (numSp, nomSp, prenomSp, dateNaisSp, categorieSp, pays))
        except IntegrityError as e:
            print("Erreur sportif :", e)

        # --- (2) Si le sportif appartient à une équipe, insertion de l'équipe ---
        if numEq not in (None, "null"):
            try:
                cursor.execute("""
                    INSERT OR IGNORE INTO LesEquipes(numEq, nomDi, pays)
                    VALUES (?, ?, ?)
                """, (int(numEq), None, pays)) 
                # nomDi = None ici car il sera mis à jour plus tard lorsqu'on lit les épreuves
            except IntegrityError as e:
                print("Erreur équipe :", e)

            # --- (3) Liaison sportif → équipe ---
            try:
                cursor.execute("""
                    INSERT OR IGNORE INTO AppartenanceEquipe(numSp, numEq)
                    VALUES (?, ?)
                """, (numSp, int(numEq)))
            except IntegrityError as e:
                print("Erreur appartenance :", e)

    # ============================================================
    # 2) Chargement des épreuves
    # ============================================================

    df_epreuves = pd.read_excel(file, sheet_name='LesEpreuves', dtype=str)
    df_epreuves = df_epreuves.where(pd.notnull(df_epreuves), None)

    # (0) Insérer les disciplines (extraites du fichier Excel)
    disciplines = df_epreuves["nomDi"].dropna().unique()

    for di in disciplines:
        try:
            cursor.execute("INSERT OR IGNORE INTO LesDisciplines(nomDi) VALUES (?)", (di,))
        except IntegrityError as e:
            print("Erreur discipline :", e)


    for _, row in df_epreuves.iterrows():
        numEp = int(row["numEp"])
        nomEp = row["nomEp"]
        formeEp = row["formeEp"]
        categorieEp = row["categorieEp"]
        nbSportifsEp = int(row["nbSportifsEp"]) if row["nbSportifsEp"] not in (None, "null") else None
        dateEp = row["dateEp"]
        nomDi = row["nomDi"]

        try:
            cursor.execute("""
                INSERT INTO LesEpreuves(numEp, nomEp, formeEp, categorieEp, nbSportifsEp, dateEp, nomDi)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (numEp, nomEp, formeEp, categorieEp, nbSportifsEp, dateEp, nomDi))
        except IntegrityError as e:
            print("Erreur épreuve :", e)

    data.commit()
    print("Importation terminée avec succès.")
