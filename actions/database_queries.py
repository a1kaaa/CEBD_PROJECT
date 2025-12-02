# Fonction permettant lister les épreuves d'une discipline donnée
def liste_epreuves(data, discipline):
    print("\nListe des épreuves de " + discipline + " :")
    try:
        cursor = data.cursor()
        result = cursor.execute(
            """
                SELECT DISTINCT nomEp, formeEp, categorieEp
                FROM LesEpreuves
                WHERE nomDi = ?
                ORDER BY nomEp
            """,
            [discipline])
    except Exception as e:
        print("Impossible d'afficher les résultats : " + repr(e))
    else:
        for epreuve in result:
            print(epreuve[0] + " - " + epreuve[1]+ " - " + epreuve[2])


def membres_equipe(data, numero):
    print("\nListe des membres de l'équipe n°" +str(numero) + " :")
    try:
        cursor = data.cursor()
        result = cursor.execute(
            """
                SELECT s.numSp, s.nomSp, s.prenomSp, s.pays, s.categorieSp, s.dateNaisSp
                FROM LesSportifs s
                JOIN AppartenanceEquipe ae ON s.numSp = ae.numSp
                WHERE ae.numEq = ?;
            """,
            [numero])
    except Exception as e:
        print("Impossible d'afficher les résultats : " + repr(e))
    else:
        for equipe in result:
            print(str(equipe[0]) + " - " + equipe[1]+ " - " + equipe[2] + " - " + equipe[3]+ " - " + equipe[4] + " - " + equipe[5])


def inscription_indiv(data, numEp, numSp):
    print(f"\nInscription à l'épreuve {numEp} :")
    try:
        cursor = data.cursor()
    except Exception as e:
        return