import Foundation
import SQLite

//ça permet d'utiliser Connection dans un contexte concurrent 
extension Connection: @retroactive @unchecked Sendable {}

//gestionnaire principal de la base de données
struct DatabaseManager: Sendable {

    //connexion SQLite
    let db: Connection

    //table contenant les livres
    static let books = Table("books")

    //colonnes de la table books
    static let bookId = SQLite.Expression<Int64>("id")
    static let bookTitle = SQLite.Expression<String>("title")
    static let bookAuthor = SQLite.Expression<String>("author")
    static let bookCategoryId = SQLite.Expression<Int64>("category_id")
    static let bookYear = SQLite.Expression<Int64>("publication_year")
    static let bookRating = SQLite.Expression<Int64>("rating")
    static let bookStatus = SQLite.Expression<String>("status")
    static let bookNotes = SQLite.Expression<String>("notes")
    static let bookImageUrl = SQLite.Expression<String>("image_url")

    //table contenant les catégories
    static let categories = Table("categories")

    //colonnes de la table categories
    static let categoryId = SQLite.Expression<Int64>("id")
    static let categoryName = SQLite.Expression<String>("name")
    static let categoryDescription = SQLite.Expression<String>("description")

    //initialisation de la base de données et création des tables si besoin
    init() throws {
        db = try Connection("db.sqlite3")

        //création de la table categories si elle n'existe pas
        try db.run(Self.categories.create(ifNotExists: true) { t in
            t.column(Self.categoryId, primaryKey: .autoincrement)
            t.column(Self.categoryName, unique: true) // nom unique
            t.column(Self.categoryDescription, defaultValue: "")
        })

        //création de la table books si elle n'existe pas
        try db.run(Self.books.create(ifNotExists: true) { t in
            t.column(Self.bookId, primaryKey: .autoincrement)
            t.column(Self.bookTitle)
            t.column(Self.bookAuthor)
            t.column(Self.bookCategoryId, defaultValue: 0)
            t.column(Self.bookYear, defaultValue: 2024)
            t.column(Self.bookRating, defaultValue: 3)
            t.column(Self.bookStatus, defaultValue: "Non lu")
            t.column(Self.bookNotes, defaultValue: "")
            t.column(Self.bookImageUrl, defaultValue: "")
        })

        //remplissage initial des catégories si la table est vide
        try seedCategories()
    }

    //ajout des catégories par défaut si aucune n'existe
    private func seedCategories() throws {
        let count = try db.scalar(Self.categories.count)

        //si aucune catégorie donc insertion des catégories par défaut
        if count == 0 {
            let defaultCategories: [(String, String)] = [
                ("Roman", "Romans et fiction littéraire"),
                ("Science-Fiction", "SF, anticipation et dystopie"),
                ("Fantasy", "Mondes imaginaires et magie"),
                ("Policier", "Enquêtes, thrillers et suspense"),
                ("Non-fiction", "Essais, biographies et documentaires"),
                ("Comédie", "Humour et comédies légères"),
                ("Action", "Aventures et récits d'action"),
                ("Histoire", "Ouvrages historiques"),
                ("Informatique", "Programmation, IA et technologies"),
                ("Philosophie", "Réflexions et pensée critique"),
                ("Poésie", "Recueils de poèmes et vers"),
                ("Théâtre", "Pièces de théâtre et dramaturgie"),
                ("Manga", "Bandes dessinées japonaises"),
                ("Bande dessinée", "BD franco-belge et comics"),
                ("Biographie", "Récits de vie et autobiographies"),
                ("Voyage", "Récits de voyage et guides"),
                ("Cuisine", "Livres de recettes et gastronomie"),
                ("Développement personnel", "Bien-être, productivité et motivation"),
                ("Sciences", "Physique, chimie, biologie et mathématiques"),
                ("Autre", "Catégories non classifiées")
            ]

            //insertion de chaque catégorie
            for (name, desc) in defaultCategories {
                try db.run(Self.categories.insert(
                    Self.categoryName <- name,
                    Self.categoryDescription <- desc
                ))
            }
        }
    }

    //crée un nouveau livre en base
    func createBook(_ book: Book) throws {
        try db.run(Self.books.insert(
            Self.bookTitle <- book.title,
            Self.bookAuthor <- book.author,
            Self.bookCategoryId <- book.categoryId,
            Self.bookYear <- book.publicationYear,
            Self.bookRating <- book.rating,
            Self.bookStatus <- book.status,
            Self.bookNotes <- book.notes,
            Self.bookImageUrl <- book.imageUrl
        ))
    }

    //récupère tous les livres avec options de recherche et tri
    func getAllBooks(search: String? = nil, sortBy: String? = nil, sortOrder: String? = nil) throws -> [Book] {
        var query = Self.books

        //filtrage par recherche (titre ou auteur)
        if let search = search, !search.isEmpty {
            let term = search.lowercased()
            let pattern = "%\(term)%"

            query = query.filter(
                Self.bookTitle.lowercaseString.like(pattern)
                || Self.bookAuthor.lowercaseString.like(pattern)
            )
        }

        //détermination de l'ordre de tri
        let ascending = (sortOrder ?? "asc") == "asc"

        //application du tri selon le champ demandé
        switch sortBy {
        case "title":
            query = ascending
                ? query.order(Self.bookTitle.collate(.nocase).asc)
                : query.order(Self.bookTitle.collate(.nocase).desc)

        case "author":
            query = ascending
                ? query.order(Self.bookAuthor.collate(.nocase).asc)
                : query.order(Self.bookAuthor.collate(.nocase).desc)

        case "year":
            query = ascending
                ? query.order(Self.bookYear.asc)
                : query.order(Self.bookYear.desc)

        case "rating":
            query = ascending
                ? query.order(Self.bookRating.desc) // meilleur rating en premier
                : query.order(Self.bookRating.asc)

        case "status":
            query = ascending
                ? query.order(Self.bookStatus.asc)
                : query.order(Self.bookStatus.desc)

        default:
            // Tri par défaut : derniers ajoutés en premier
            query = query.order(Self.bookId.desc)
        }

        //transformation des lignes SQL en objets Book
        return try db.prepare(query).map { row in
            Book(
                id: row[Self.bookId],
                title: row[Self.bookTitle],
                author: row[Self.bookAuthor],
                categoryId: row[Self.bookCategoryId],
                publicationYear: row[Self.bookYear],
                rating: row[Self.bookRating],
                status: row[Self.bookStatus],
                notes: row[Self.bookNotes],
                imageUrl: row[Self.bookImageUrl]
            )
        }
    }

    //récupère les livres d'une catégorie donnée
    func getBooksByCategory(id categoryId: Int64) throws -> [Book] {
        let query = Self.books
            .filter(Self.bookCategoryId == categoryId)
            .order(Self.bookTitle.collate(.nocase).asc)

        return try db.prepare(query).map { row in
            Book(
                id: row[Self.bookId],
                title: row[Self.bookTitle],
                author: row[Self.bookAuthor],
                categoryId: row[Self.bookCategoryId],
                publicationYear: row[Self.bookYear],
                rating: row[Self.bookRating],
                status: row[Self.bookStatus],
                notes: row[Self.bookNotes],
                imageUrl: row[Self.bookImageUrl]
            )
        }
    }

    //récupère un livre par son ID
    func getBook(byId id: Int64) throws -> Book? {
        let query = Self.books.filter(Self.bookId == id)

        return try db.pluck(query).map { row in
            Book(
                id: row[Self.bookId],
                title: row[Self.bookTitle],
                author: row[Self.bookAuthor],
                categoryId: row[Self.bookCategoryId],
                publicationYear: row[Self.bookYear],
                rating: row[Self.bookRating],
                status: row[Self.bookStatus],
                notes: row[Self.bookNotes],
                imageUrl: row[Self.bookImageUrl]
            )
        }
    }

    //met à jour un livre existant
    func updateBook(_ book: Book) throws {
        guard let id = book.id else { return }

        let target = Self.books.filter(Self.bookId == id)

        try db.run(target.update(
            Self.bookTitle <- book.title,
            Self.bookAuthor <- book.author,
            Self.bookCategoryId <- book.categoryId,
            Self.bookYear <- book.publicationYear,
            Self.bookRating <- book.rating,
            Self.bookStatus <- book.status,
            Self.bookNotes <- book.notes,
            Self.bookImageUrl <- book.imageUrl
        ))
    }

    //supprime un livre
    func deleteBook(byId id: Int64) throws {
        let target = Self.books.filter(Self.bookId == id)
        try db.run(target.delete())
    }

    //crée une nouvelle catégorie
    func createCategory(_ category: Category) throws {
        try db.run(Self.categories.insert(
            Self.categoryName <- category.name,
            Self.categoryDescription <- category.description
        ))
    }

    //récupère toutes les catégories
    func getAllCategories() throws -> [Category] {
        return try db.prepare(
            Self.categories.order(Self.categoryName.collate(.nocase).asc)
        ).map { row in
            Category(
                id: row[Self.categoryId],
                name: row[Self.categoryName],
                description: row[Self.categoryDescription]
            )
        }
    }

    //récupère une catégorie par ID
    func getCategory(byId id: Int64) throws -> Category? {
        let query = Self.categories.filter(Self.categoryId == id)

        return try db.pluck(query).map { row in
            Category(
                id: row[Self.categoryId],
                name: row[Self.categoryName],
                description: row[Self.categoryDescription]
            )
        }
    }

    //met à jour une catégorie
    func updateCategory(_ category: Category) throws {
        guard let id = category.id else { return }

        let target = Self.categories.filter(Self.categoryId == id)

        try db.run(target.update(
            Self.categoryName <- category.name,
            Self.categoryDescription <- category.description
        ))
    }

    //supprime une catégorie
    func deleteCategory(byId id: Int64) throws {
        let target = Self.categories.filter(Self.categoryId == id)
        try db.run(target.delete())
    }

    //récupère le nom d'une catégorie à partir de son ID
    func categoryName(forId id: Int64) throws -> String {
        let query = Self.categories
            .filter(Self.categoryId == id)
            .select(Self.categoryName)

        return try db.pluck(query).map { row in
            row[Self.categoryName]
        } ?? "Inconnue"
    }

    //statistiques globales des livres
    func getStats() throws -> (total: Int, read: Int, reading: Int, unread: Int) {
        let total = try db.scalar(Self.books.count)
        let read = try db.scalar(Self.books.filter(Self.bookStatus == "Lu").count)
        let reading = try db.scalar(Self.books.filter(Self.bookStatus == "En cours").count)
        let unread = try db.scalar(Self.books.filter(Self.bookStatus == "Non lu").count)

        return (total, read, reading, unread)
    }
}
