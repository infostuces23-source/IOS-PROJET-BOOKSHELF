# BookShelf : Ma Bibliothèque Personnelle 📚✨

Bienvenue sur **BookShelf**, une application web CRUD élégante et performante développée en Swift pour gérer une bibliothèque personnelle. Ce projet a été réalisé dans le cadre du cours de développement iOS (2026) à l'Université Paris 8.

## 🎯 Objectif du projet :

L'objectif de BookShelf est de fournir une interface simple, fluide et visuellement attrayante pour gérer sa collection de livres. L'application permet de garder une trace des ouvrages lus, en cours de lecture ou à lire, tout en les classant par catégories et en leur attribuant une note.

## ✨ Fonctionnalités principales :

BookShelf implémente toutes les opérations CRUD standard (Create, Read, Update, Delete) et va plus loin avec plusieurs fonctionnalités avancées :

- **Gestion complète des livres** : Ajout, modification et suppression d'ouvrages avec des informations détaillées (titre, auteur, année, note, statut, couverture).
- **Système de catégories** : Classification des livres par genres (Roman, Science-Fiction, Fantaisie, ...) avec une page dédiée pour explorer les livres d'une catégorie spécifique.
- **Recherche intelligente** : Barre de recherche flexible (insensible à la casse, recherche partielle) permettant de trouver rapidement un livre par son titre ou son auteur.
- **Tri dynamique** : Organisation de la bibliothèque par titre, auteur, année, note ou statut (croissant ou décroissant).
- **Fiche détaillée** : Une page dédiée pour chaque livre affichant toutes ses informations et notes personnelles de manière élégante.
- **Validation des données** : Vérification des formulaires côté serveur avec messages d'erreur clairs pour guider l'utilisateur.
- **Interface (UI/UX)** : Design moderne, mode sombre ou clair, animations fluides et design adaptatif et responsive.

## 🛠️ Technologies utilisées :

L'application est construite entièrement en Swift sans framework frontend lourd :

- **Langage** : Swift 6.2
- **Framework Web** : Hummingbird 2 
- **Base de données** : SQLite 
- **Frontend** : HTML5, CSS3, JavaScript vanilla 
- **Environnement** : GitHub Codespaces

## 📂 Structure du code :

Le projet respecte une architecture claire et modulaire :

- Models.swift : Définition des structures de données (Book, Category, ValidationError) conformes aux protocoles Codable et Sendable.
- Database.swift : Couche d'accès aux données gérant toutes les requêtes SQLite typées (CRUD pour les livres et les catégories).
- Views.swift : Génération dynamique du HTML côté serveur incluant les composants UI, les formulaires et le design global.
- main.swift : Point d'entrée de l'application, configuration du serveur Hummingbird et définition de toutes les routes HTTP.

## 🚀 Instructions d'installation et d'exécution :

Ce projet est conçu pour s'exécuter directement dans l'environnement GitHub Codespaces fourni avec le cours.

1. Ouvrir le projet dans GitHub Codespaces.
2. Dans le terminal, exécuter le script de compilation : ./build.sh
3. Lancez le serveur web : ./run.sh
4. Codespaces proposera d'ouvrir l'application dans le navigateur dans le port 8080) Cliquer sur le lien pour accéder à BookShelf !

## 🗺️ Architecture des routes (API) :

L'application expose les routes suivantes :

| Méthode | Route | Description |
|:---|:---|:---|
| `GET` | `/` | Page d'accueil (liste des livres, recherche, tri, statistiques) |
| `GET` | `/add` | Formulaire d'ajout d'un nouveau livre |
| `GET` | `/book/:id` | Fiche détaillée d'un livre (lecture seule) |
| `GET` | `/edit/:id` | Formulaire de modification d'un livre existant |
| `GET` | `/categories` | Liste de toutes les catégories |
| `GET` | `/categories/:id` | Liste des livres appartenant à une catégorie spécifique |
| `POST` | `/create` | Traitement de l'ajout d'un livre |
| `POST` | `/update/:id` | Traitement de la modification d'un livre |
| `POST` | `/delete/:id` | Suppression d'un livre |
| `POST` | `/toggle-status/:id` | Action rapide pour changer le statut (Lu/Non lu/En cours) |
| `POST` | `/categories/create` | Ajout d'une nouvelle catégorie |
| `POST` | `/categories/delete/:id` | Suppression d'une catégorie |

Et voilà !
Ce Projet est réalisé par Lila MILOUDI, étudiante à l'Université Vincennes Saint Denis à Paris 8 :)
