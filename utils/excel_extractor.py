import sqlite3
import pandas as pd
from sqlite3 import IntegrityError

def read_excel_file_V0(data: sqlite3.Connection, file):

    cursor = data.cursor()


    # 1 - Chargement des sportifs + leurs équipes
    df_sportifs = pd.read_excel(file, sheet_name='LesSportifsEQ', dtype=str)
    df_sportifs = df_sportifs.where(pd.notnull(df_sportifs), None)

    for _, row in df_sportifs.iterrows():
        numSp = int(row["numSp"])
        nomSp = row["nomSp"]
        prenomSp = row["prenomSp"]
        pays = row["pays"]
        categorieSp = row["categorieSp"]
        dateNaisSp = row["dateNaisSp"]
        numEq = row["numEq"] #NULL si pas d'équipe

        # Insertion du sportiff
        try:
            cursor.execute("""
                INSERT OR IGNORE INTO LesSportifs(numSp, nomSp, prenomSp, dateNaisSp, categorieSp, pays)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (numSp, nomSp, prenomSp, dateNaisSp, categorieSp, pays))
        except IntegrityError as e:
            print("Erreur sportif :", e)

        # Insertion de l'équipe si elle existe
        if numEq not in (None, "null"):
            try:
                cursor.execute("""
                    INSERT OR IGNORE INTO LesEquipes(numEq, pays)
                    VALUES (?, ?)
                """, (int(numEq), pays))
            except IntegrityError as e:
                print("Erreur équipe :", e)

            # Insertion de l'appartenance du sportif à l'équipe
            try:
                cursor.execute("""
                    INSERT OR IGNORE INTO AppartenanceEquipe(numSp, numEq)
                    VALUES (?, ?)
                """, (numSp, int(numEq)))
            except IntegrityError as e:
                print("Erreur appartenance :", e)


    # 2 - Chargement des épreuves
    df_epreuves = pd.read_excel(file, sheet_name='LesEpreuves', dtype=str)
    df_epreuves = df_epreuves.where(pd.notnull(df_epreuves), None)

    # Insertion des disciplines
    disciplines = df_epreuves["nomDi"].dropna().unique()

    for di in disciplines:
        try:
            cursor.execute("INSERT OR IGNORE INTO LesDisciplines(nomDi) VALUES (?)", (di,))
        except IntegrityError as e:
            print("Erreur discipline :", e)

    # Insertion des épreuves
    for _, row in df_epreuves.iterrows():
        numEp = int(row["numEp"])
        nomEp = row["nomEp"]
        formeEp = row["formeEp"]
        categorieEp = row["categorieEp"]
        nbSportifsEp = row["nbSportifsEp"]
        dateEp = row["dateEp"]
        nomDi = row["nomDi"]

        try:
            cursor.execute("""
                INSERT INTO LesEpreuves(numEp, nomEp, formeEp, categorieEp, nbSportifsEp,dateEp, nomDi)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (numEp, nomEp, formeEp, categorieEp, nbSportifsEp, dateEp, nomDi))
        except IntegrityError as e:
            print("Erreur épreuve :", e)



    # 3 - Chargement des inscriptions (individuelle, par équipe ou par couple)
    #     - si 1000 <= numIn <= 1500  -> sportif  -> ParticipationIndiv(numEp, numSp)
    #     - sinon
    #           - si formeEp = 'par equipe'  -> ParticipationEquipe
    #           - si formeEp = 'par couple'  -> ParticipationCouple
                
    df_inscriptions = pd.read_excel(file, sheet_name='LesInscriptions', dtype=str)
    df_inscriptions = df_inscriptions.where(pd.notnull(df_inscriptions), None)

    for _, row in df_inscriptions.iterrows():
        numIn = row["numIn"]
        numEp_ins = row["numEp"]
        if numIn in (None, "null") or numEp_ins in (None, "null"):
            continue

        try:
            numIn_int = int(numIn)
            numEp_int = int(numEp_ins)
        except ValueError:
            print("Inscription ignorée (numIn ou numEp non entier) :", row)
            continue

        # Récupérer la forme de l'épreuve pour router equipe vs couple
        cursor.execute("SELECT formeEp FROM LesEpreuves WHERE numEp = ?", (numEp_int,))
        res = cursor.fetchone()
        if not res:
            print(f"Inscription ignorée: epreuve {numEp_int} inexistante pour numIn {numIn_int}")
            continue

        formeEp = res[0]

        # Cas sportif
        if 1000 <= numIn_int <= 1500:
            try:
                cursor.execute(
                    """
                    INSERT OR IGNORE INTO ParticipationIndiv(numEp, numSp)
                    VALUES (?, ?)
                    """,
                    (numEp_int, numIn_int)
                )
            except IntegrityError as e:
                print("Erreur inscription individuelle :", e)
                
        elif numIn_int <= 100:
            try:
                if formeEp == "par equipe":
                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ParticipationEquipe(numEp, numEq)
                        VALUES (?, ?)
                        """,
                        (numEp_int, numIn_int)
                    )
                elif formeEp == "par couple":
                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ParticipationCouple(numEp, numEq)
                        VALUES (?, ?)
                        """,
                        (numEp_int, numIn_int)
                    )
                else:
                    print(f"Inscription equipe/couple ignoree: epreuve {numEp_int} de forme {formeEp}")
            except IntegrityError as e:
                print("Erreur inscription equipe/couple :", e)


    # 4 - Chargement des résultats (médailles)
    #     LesResultats : numEp, gold, silver, bronze
    #     - si formeEp = 'individuelle'  -> numSp dans ClassementIndiv
    #     - si formeEp = 'par equipe'    -> numEq dans ClassementEquipe
    #     - si formeEp = 'par couple'    -> numEq dans ClassementCouple

    df_resultats = pd.read_excel(file, sheet_name='LesResultats', dtype=str)
    df_resultats = df_resultats.where(pd.notnull(df_resultats), None)

    for _, row in df_resultats.iterrows():
        numEp_res = row["numEp"]
        gold = row["gold"]
        silver = row["silver"]
        bronze = row["bronze"]

        if numEp_res in (None, "null"):
            continue

        numEp = int(numEp_res)

        # Récupérer la forme de l'épreuve
        cursor.execute("SELECT formeEp FROM LesEpreuves WHERE numEp = ?", (numEp,))
        res = cursor.fetchone()
        if not res:
            print(f"Epreuve {numEp} inconnue dans LesResultats, ligne ignorée.")
            continue

        formeEp = res[0]

        if formeEp == "individuelle":
            if gold not in (None, "null"):
                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementIndiv(numEp, rang, numSp)
                        VALUES (?, 1, ?)
                        """,
                        (numEp, int(gold))
                    )

                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementIndiv(numEp, rang, numSp)
                        VALUES (?, 2, ?)
                        """,
                        (numEp, int(silver))
                    )

                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementIndiv(numEp, rang, numSp)
                        VALUES (?, 3, ?)
                        """,
                        (numEp, int(bronze))
                    )

        elif formeEp == "par equipe":
            if gold not in (None, "null"):
                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementEquipe(numEp, rang, numEq)
                        VALUES (?, 1, ?)
                        """,
                        (numEp, int(gold))
                    )

                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementEquipe(numEp, rang, numEq)
                        VALUES (?, 2, ?)
                        """,
                        (numEp, int(silver))
                    )

                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementEquipe(numEp, rang, numEq)
                        VALUES (?, 3, ?)
                        """,
                        (numEp, int(bronze))
                    )

        elif formeEp == "par couple":
            if gold not in (None, "null"):
                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementCouple(numEp, rang, numEq)
                        VALUES (?, 1, ?)
                        """,
                        (numEp, int(gold))
                    )
                    
                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementCouple(numEp, rang, numEq)
                        VALUES (?, 2, ?)
                        """,
                        (numEp, int(silver))
                    )

                    cursor.execute(
                        """
                        INSERT OR IGNORE INTO ClassementCouple(numEp, rang, numEq)
                        VALUES (?, 3, ?)
                        """,
                        (numEp, int(bronze))
                    )

    data.commit()
    print("Importation terminée avec succès.")
