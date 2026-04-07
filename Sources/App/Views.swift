import Hummingbird
import Foundation

//cette structure permet de renvoyer du HTML directement comme réponse HTTP
//en gros on transforme une string HTML en vraie réponse pour le navigateur
struct HTML: ResponseGenerator {
    let html: String

    func response(from request: Request, context: some RequestContext) throws -> Response {
        // On convertit le HTML en buffer (format utilisable par Hummingbird)
        let buffer = ByteBuffer(string: html)

        // On retourne une réponse HTTP classique avec le bon type (text/html)
        return Response(
            status: .ok,
            headers: [.contentType: "text/html; charset=utf-8"],
            body: .init(byteBuffer: buffer)
        )
    }
}


//cette structure contient toutes les vues HTML de mon application
//j’ai centralisé ici pour garder le code organisé
struct Views {

    //layout principal utilisé par toutes les pages
    //c’est ici que je définis le design global (navbar, footer, ...)
    static func layout(title: String, content: String, showToast: String? = nil) -> String {

        // Petit message temporaire (toast) affiché après certaines actions (ex: succès)
        let toastJS = showToast != nil ? """
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                var t = document.getElementById('toast-msg');
                if (t) { 
                    t.classList.add('show'); 
                    setTimeout(function(){ t.classList.remove('show'); }, 3000); 
                }
            });
        </script>
        <div id="toast-msg" class="toast">
            <i data-lucide="sparkles"></i>
            \(escapeHTML(showToast!))
        </div>
        """ : ""

        //structure HTML complète de la page
        //toutes les autres vues viennent s’insérer dans \(content)
        return """
        <!DOCTYPE html>
        <html lang="fr" data-theme="dark">
        <head>
            <meta charset="UTF-8">
            <title>\(title) - BookShelf</title>
        </head>

        <body>

            <!-- Navbar principale -->
            <!-- Permet de naviguer entre Accueil, Ajouter et Catégories -->
            <nav class="navbar">
                ...
            </nav>

            <!-- Contenu spécifique de chaque page -->
            <main class="container">
                \(content)
            </main>

            <!-- Footer du site -->
            <footer class="site-footer">
                ...
            </footer>

            <!-- Toast affiché si nécessaire -->
            \(toastJS)

        </body>
        </html>
        """
    }


    //fonction pour afficher les étoiles en fonction de la note du livre
    //exemple : 3/5 : 3 étoiles pleines + 2 vides
    static func starsHTML(rating: Int64) -> String {
        return (1...5).map { i in
            let color = i <= Int(rating) ? "var(--gold)" : "rgba(128,128,128,0.2)"
            return "<i data-lucide=\"star\" style=\"color:\(color);\"></i>"
        }.joined()
    }


    //badge pour afficher le statut du livre (Lu , en cours , a lire)
    static func statusBadge(for status: String) -> String {
        switch status {
        case "Lu":
            return "<span class=\"badge badge-lu\">Lu</span>"
        case "En cours":
            return "<span class=\"badge badge-encours\">En cours</span>"
        default:
            return "<span class=\"badge badge-nonlu\">À lire</span>"
        }
    }


    //page d’accueil (liste des livres)
    static func renderIndex(
        books: [Book],
        categories: [Category],
        stats: (total: Int, read: Int, reading: Int, unread: Int),
        search: String = "",
        sortBy: String = "",
        sortOrder: String = "asc"
    ) -> String {

        //ici je crée un dictionnaire pour associer chaque livre à sa catégorie
        let categoryMap: [Int64: String] = {
            var m: [Int64: String] = [:]
            categories.forEach { c in
                if let id = c.id { m[id] = c.name }
            }
            return m
        }()

        //barre de recherche + tri
        let searchHTML = """
        <form method="get" action="/">
            ...
        </form>
        """

        //si aucun livre donc message vide
        let booksHTML: String
        if books.isEmpty {
            booksHTML = "<p>Aucun livre trouvé</p>"
        } else {

            //sinon on affiche tous les livres
            booksHTML = books.map { book in

                let catName = categoryMap[book.categoryId] ?? "Général"

                return """
                <div onclick="window.location.href='/book/\(book.id ?? 0)'">
                    <h3>\(escapeHTML(book.title))</h3>
                    <p>\(escapeHTML(book.author))</p>
                    <p>\(catName)</p>
                    \(statusBadge(for: book.status))
                    \(starsHTML(rating: book.rating))
                </div>
                """
            }.joined()
        }

        let content = """
        <h2>Ma Bibliothèque</h2>
        \(searchHTML)
        \(booksHTML)
        """

        return layout(title: "Accueil", content: content)
    }


    //formulaire utilisé pour ajouter et modifier un livre
    //j’ai factorisé pour éviter de dupliquer du code
    static func renderFormContent(
        book: Book,
        categories: [Category],
        errors: [ValidationError],
        isEdit: Bool,
        actionUrl: String,
        cancelUrl: String = "/",
        fromContext: String = ""
    ) -> String {

        //liste des catégories dans le select
        let catOpts = categories.map { c in
            "<option value=\"\(c.id ?? 0)\">\(escapeHTML(c.name))</option>"
        }.joined()

        return """
        <!-- Formulaire principal -->
        <form method="post" action="\(actionUrl)">

            <!-- Champ caché pour savoir d’où on vient (important pour le bouton retour) -->
            <input type="hidden" name="_from" value="\(fromContext)">

            <input type="text" name="title" value="\(escapeHTML(book.title))" required>
            <input type="text" name="author" value="\(escapeHTML(book.author))" required>

            <select name="categoryId">
                \(catOpts)
            </select>

            <button type="submit">
                \(isEdit ? "Modifier" : "Ajouter")
            </button>

            <!-- Bouton annuler → redirige vers la bonne page -->
            <a href="\(cancelUrl)">Annuler</a>

        </form>
        """
    }


    //page détail d’un livre
    static func renderDetail(
        book: Book,
        categoryName: String,
        success: String? = nil,
        backUrl: String = "/",
        from: String = ""
    ) -> String {

        let content = """
        <h2>Détails</h2>

        <p>\(escapeHTML(book.title))</p>
        <p>\(escapeHTML(book.author))</p>

        <!-- Bouton retour dynamique -->
        <!-- IMPORTANT : il utilise backUrl pour revenir au bon endroit -->
        <a href="\(backUrl)">Retour</a>
        """

        return layout(title: book.title, content: content)
    }


    //page modification d’un livre
    static func renderEditForm(
        book: Book,
        categories: [Category],
        categoryName: String,
        errors: [ValidationError] = [],
        success: String? = nil,
        from: String = ""
    ) -> String {

        //l'URL pour revenir aux détails
        let detailUrl = "/book/\(book.id ?? 0)"

        let content = """
        <h2>Modifier</h2>

        <!-- On réutilise le formulaire -->
        \(renderFormContent(
            book: book,
            categories: categories,
            errors: errors,
            isEdit: true,
            actionUrl: "/update/\(book.id ?? 0)",
            cancelUrl: detailUrl,
            fromContext: from
        ))
        """

        return layout(title: "Modifier", content: content)
    }


    //page catégories
    static func renderCategories(categories: [Category]) -> String {

        let listHTML = categories.map { c in
            """
            <!-- Chaque catégorie est cliquable -->
            <a href="/categories/\(c.id ?? 0)">
                \(escapeHTML(c.name))
            </a>
            """
        }.joined()

        let content = """
        <h2>Catégories</h2>
        \(listHTML)
        """

        return layout(title: "Catégories", content: content)
    }


    //page liste des livres d’une catégorie
    static func renderCategoryBooks(category: Category, books: [Book]) -> String {

        let rows = books.map { book in
            """
            <tr>
                <td>\(escapeHTML(book.title))</td>

                <!-- IMPORTANT : on passe ?from=catID -->
                <!-- Ça sert à gérer le bouton retour correctement -->
                <td>
                    <a href="/book/\(book.id ?? 0)?from=cat\(category.id ?? 0)">
                        Détails
                    </a>
                </td>
            </tr>
            """
        }.joined()

        let content = """
        <h2>\(escapeHTML(category.name))</h2>

        <!-- Bouton retour vers les catégories -->
        <a href="/categories">Retour</a>

        <table>
            \(rows)
        </table>
        """

        return layout(title: category.name, content: content)
    }


    //affichage des erreurs de validation dans les formulaires
    static func renderErrors(_ errors: [ValidationError]) -> String {
        if errors.isEmpty { return "" }

        let items = errors.map {
            "<li>\(escapeHTML($0.message))</li>"
        }.joined()

        return """
        <div>
            <strong>Erreur :</strong>
            <ul>\(items)</ul>
        </div>
        """
    }


    //sécurité : on évite les injections HTML
    //on transforme les caractères spéciaux
    static func escapeHTML(_ str: String) -> String {
        return str
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
