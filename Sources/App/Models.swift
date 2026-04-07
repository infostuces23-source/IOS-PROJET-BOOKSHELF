import Foundation

//modèle principal représentant un livre
//contient toutes les informations liées à un livre dans l'application
struct Book: Codable, Sendable {

    //identifiant unique (nil si le livre n'est pas encore enregistré en base)
    let id: Int64?

    ///titre du livre
    var title: String

    //auteur du livre
    var author: String

    //ID de la catégorie associée
    var categoryId: Int64

    //année de publication
    var publicationYear: Int64

    //note du livre (généralement entre 1 et 5)
    var rating: Int64

    //statut de lecture 
    var status: String

    //notes personnelles de l'utilisateur
    var notes: String

    //URL de l'image de couverture du livre
    var imageUrl: String
}

//modèle représentant une catégorie de livres
struct Category: Codable, Sendable {

    //identifiant unique de la catégorie
    let id: Int64?

    //nom de la catégorie
    var name: String

    //description optionnelle de la catégorie
    var description: String
}

//extensions utilitaires :

extension String {

    //liste des statuts de lecture autorisés
    //utilisée pour valider le champ status dans Book
    static var readingStatuses: [String] {
        return ["Non lu", "En cours", "Lu"]
    }
}

//représenter une erreur de validation sur un champ
struct ValidationError: Sendable {

    //nom du champ concerné
    let field: String

    //message d'erreur associé
    let message: String
}

//Validation du modèle Book :

extension Book {

    //valider les champs du livre
    //retourner une liste d'erreurs (vide si tout est valide)
    func validate() -> [ValidationError] {

        var errors: [ValidationError] = []

        //vérifier que le titre n'est pas vide
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(
                ValidationError(
                    field: "title",
                    message: "Le titre est obligatoire."
                )
            )
        }

        //vérifier que l'auteur n'est pas vide
        if author.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append(
                ValidationError(
                    field: "author",
                    message: "L'auteur est obligatoire."
                )
            )
        }

        //vérifier que l'année est dans une plage valide
        if publicationYear < 0 || publicationYear > 2026 {
            errors.append(
                ValidationError(
                    field: "publicationYear",
                    message: "L'année doit être entre 0 et 2026."
                )
            )
        }

        //vérifier que la note est entre 1 et 5
        if rating < 1 || rating > 5 {
            errors.append(
                ValidationError(
                    field: "rating",
                    message: "La note doit être entre 1 et 5."
                )
            )
        }

        //vérifier que le statut est valide 
        if !String.readingStatuses.contains(status) {
            errors.append(
                ValidationError(
                    field: "status",
                    message: "Statut invalide."
                )
            )
        }

        //retourner toutes les erreurs détectées
        return errors
    }
}
