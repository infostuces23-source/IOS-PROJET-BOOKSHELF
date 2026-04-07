import Foundation
import Hummingbird

//initialisation de la base de données au démarrage de l'application
//si ça échoue on arrête tout directement
let database: DatabaseManager
do {
    database = try DatabaseManager()
    print("Base de données initialisée avec succès.")
} catch {
    print("Erreur lors de l'initialisation de la base de données: \(error)")
    exit(1)
}

//le routeur contient toutes les routes (GET et POST)
let router = Router()

//ROUTES GET (AFFICHAGE) :

//page d'accueil
router.get("/") { request, _ -> HTML in

    //récupération des paramètres de recherche depuis l'URL
    let rawSearch = request.uri.queryParameters.get("search") ?? ""

    //nettoyage de la chaîne 
    let search = rawSearch
        .replacingOccurrences(of: "+", with: " ")
        .removingPercentEncoding ?? rawSearch

    let sortBy = request.uri.queryParameters.get("sortBy") ?? ""
    let sortOrder = request.uri.queryParameters.get("sortOrder") ?? "asc"

    //récupération des données depuis la base
    let books = try database.getAllBooks(
        search: search.isEmpty ? nil : search,
        sortBy: sortBy.isEmpty ? nil : sortBy,
        sortOrder: sortOrder
    )

    let categories = try database.getAllCategories()
    let stats = try database.getStats()

    //on envoie les données à la vue
    return HTML(html: Views.renderIndex(
        books: books,
        categories: categories,
        stats: stats,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder
    ))
}


//page formulaire d'ajout
router.get("/add") { _, _ -> HTML in
    let categories = try database.getAllCategories()
    return HTML(html: Views.renderAddForm(categories: categories))
}


//page détail d’un livre
router.get("/book/:id") { request, context -> HTML in

    //vérification de l'id
    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {

        //si erreur donc on envoie un message simple
        return HTML(html: Views.layout(
            title: "Erreur",
            content: "<h2>Erreur</h2><p>Identifiant de livre invalide.</p><a href=\"/\">Retour</a>"
        ))
    }

    //vérifie que le livre existe
    guard let book = try database.getBook(byId: id) else {
        return HTML(html: Views.layout(
            title: "Non trouvé",
            content: "<h2>Livre non trouvé</h2><p>Aucun livre avec cet identifiant.</p><a href=\"/\">Retour</a>"
        ))
    }

    let categoryName = try database.categoryName(forId: book.categoryId)

    //paramètre utilisé pour afficher le message de succès
    let success = request.uri.queryParameters.get("success")

    //très important : savoir d'ou on vient (catégorie ou accueil)
    let from = request.uri.queryParameters.get("from") ?? ""

    //logique du bouton RETOUR 
    let backUrl: String
    if from.hasPrefix("cat"), let catId = Int64(from.dropFirst(3)) {
        // Si on vient d'une catégorie → on y retourne
        backUrl = "/categories/\(catId)"
    } else {
        // Sinon → accueil
        backUrl = "/"
    }

    return HTML(html: Views.renderDetail(
        book: book,
        categoryName: categoryName,
        success: success,
        backUrl: backUrl,
        from: from
    ))
}


//page modification
router.get("/edit/:id") { request, context -> HTML in

    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {
        return HTML(html: Views.layout(
            title: "Erreur",
            content: "<h2>Erreur</h2><p>Identifiant invalide.</p><a href=\"/\">Retour</a>"
        ))
    }

    guard let book = try database.getBook(byId: id) else {
        return HTML(html: Views.layout(
            title: "Non trouvé",
            content: "<h2>Livre non trouvé</h2>"
        ))
    }

    let categories = try database.getAllCategories()
    let categoryName = try database.categoryName(forId: book.categoryId)

    //on garde le fromulaire pour ne pas casser la navigation retour
    let from = request.uri.queryParameters.get("from") ?? ""

    return HTML(html: Views.renderEditForm(
        book: book,
        categories: categories,
        categoryName: categoryName,
        from: from
    ))
}


//page catégories
router.get("/categories") { request, _ -> HTML in
    let categories = try database.getAllCategories()
    let success = request.uri.queryParameters.get("success")

    return HTML(html: Views.renderCategories(
        categories: categories,
        success: success
    ))
}


//page livres d'une catégorie
router.get("/categories/:id") { _, context -> HTML in

    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {

        return HTML(html: Views.layout(
            title: "Erreur",
            content: "<h2>Erreur</h2><p>Identifiant invalide.</p><a href=\"/categories\">Retour</a>"
        ))
    }

    guard let category = try database.getCategory(byId: id) else {
        return HTML(html: Views.layout(
            title: "Non trouvée",
            content: "<h2>Catégorie non trouvée</h2>"
        ))
    }

    let books = try database.getBooksByCategory(id: id)

    return HTML(html: Views.renderCategoryBooks(category: category, books: books))
}

//ROUTES POST (ACTIONS) :

//création d’un livre
router.post("/create") { request, _ -> Response in

    //on récupère les données du formulaire
    let formData = try await parseFormBody(request)

    //création de l'objet Book
    let book = Book(
        id: nil,
        title: formData["title"] ?? "",
        author: formData["author"] ?? "",
        categoryId: Int64(formData["categoryId"] ?? "0") ?? 0,
        publicationYear: Int64(formData["publicationYear"] ?? "2024") ?? 2024,
        rating: Int64(formData["rating"] ?? "3") ?? 3,
        status: formData["status"] ?? "Non lu",
        notes: formData["notes"] ?? "",
        imageUrl: formData["imageUrl"] ?? ""
    )

    //validation des données 
    let errors = book.validate()
    if !errors.isEmpty {
        let categories = try database.getAllCategories()

        //on renvoie le formulaire avec erreurs
        let html = Views.renderAddForm(categories: categories, errors: errors, book: book)

        return Response(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: .init(byteBuffer: ByteBuffer(string: html))
        )
    }

    //sauvegarde en base
    try database.createBook(book)

    //redirection vers l'accueil
    return Response(status: .seeOther, headers: [.location: "/"])
}


//modification d’un livre
router.post("/update/:id") { request, context -> Response in

    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {
        return Response(status: .seeOther, headers: [.location: "/"])
    }

    let formData = try await parseFormBody(request)

    //on récupère d'où on vient 
    let from = formData["_from"] ?? ""

    let book = Book(
        id: id,
        title: formData["title"] ?? "",
        author: formData["author"] ?? "",
        categoryId: Int64(formData["categoryId"] ?? "0") ?? 0,
        publicationYear: Int64(formData["publicationYear"] ?? "2024") ?? 2024,
        rating: Int64(formData["rating"] ?? "3") ?? 3,
        status: formData["status"] ?? "Non lu",
        notes: formData["notes"] ?? "",
        imageUrl: formData["imageUrl"] ?? ""
    )

    let errors = book.validate()
    if !errors.isEmpty {
        let categories = try database.getAllCategories()
        let categoryName = try database.categoryName(forId: book.categoryId)

        //on renvoie le formulaire avec erreurs
        let html = Views.renderEditForm(
            book: book,
            categories: categories,
            categoryName: categoryName,
            errors: errors,
            from: from
        )

        return Response(
            status: .ok,
            headers: [.contentType: "text/html"],
            body: .init(byteBuffer: ByteBuffer(string: html))
        )
    }

    try database.updateBook(book)

    //redirection intelligente (garde le contexte)
    let redirectUrl = from.isEmpty
        ? "/book/\(id)?success=ok"
        : "/book/\(id)?success=ok&from=\(from)"

    return Response(status: .seeOther, headers: [.location: redirectUrl])
}


//suppression d’un livre
router.post("/delete/:id") { _, context -> Response in
    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {
        return Response(status: .seeOther, headers: [.location: "/"])
    }

    try database.deleteBook(byId: id)

    return Response(status: .seeOther, headers: [.location: "/"])
}


//changer le statut d’un livre (cycle : à lire , En cours , Lu)
router.post("/toggle-status/:id") { _, context -> Response in

    guard let idString = context.parameters.get("id"),
          let id = Int64(idString) else {
        return Response(status: .seeOther, headers: [.location: "/"])
    }

    if var book = try database.getBook(byId: id) {

        //fonction pour passer au statut suivant
        let nextStatus: (String) -> String = { current in
            switch current {
            case "Non lu": return "En cours"
            case "En cours": return "Lu"
            case "Lu": return "Non lu"
            default: return "Non lu"
            }
        }

        book.status = nextStatus(book.status)
        try database.updateBook(book)
    }

    return Response(status: .seeOther, headers: [.location: "/"])
}

// UTILITAIRE :

//fonction pour parser les données d’un formulaire HTML car Hummingbird ne le fait pas automatiquement ici
func parseFormBody(_ request: Request) async throws -> [String: String] {

    let buffer = try await request.body.collect(upTo: 1_048_576)
    let bodyString = String(buffer: buffer)

    var result: [String: String] = [:]

    //on découpe les champs (clé = valeur)
    let pairs = bodyString.split(separator: "&")

    for pair in pairs {
        let keyValue = pair.split(separator: "=", maxSplits: 1)

        let key = String(keyValue[0])
            .removingPercentEncoding ?? String(keyValue[0])

        let rawValue = keyValue.count > 1 ? String(keyValue[1]) : ""

        let value = rawValue
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding ?? rawValue

        result[key] = value
    }

    return result
}

//LANCEMENT DU SERVEUR : 

let app = Application(
    router: router,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

print("BookShelf demarre sur http://localhost:8080")

//Lancer le serveur (bloquant) :
try await app.runService()
