Resource Loader

Description

Resource Loader est un script Lua pour FiveM qui scanne, lit et interprète les fichiers de ressources du serveur (fxmanifest.lua et _resource.lua). Il permet de gérer les dépendances entre ressources, de vérifier les fichiers, et d'enregistrer les informations dans une base de données via oxmysql. Un système de logs est également inclus pour faciliter le suivi et le débogage.

Fonctionnalités

🔍 Scan automatique des ressources au démarrage du serveur.

📂 Lecture des fichiers fxmanifest.lua et _resource.lua.

📑 Tri des fichiers en fonction de leur type (server_script, client_script, shared_script).

🔄 Vérification des dépendances entre ressources.

🚫 Détection et exclusion des scripts obfusqués ou malveillants.

🛠 Enregistrement des informations dans une base de données via oxmysql.

📝 Gestion des logs dans logs.txt et affichage en console.

♻ Purge automatique des entrées obsolètes de la base de données.

Prérequis

🛠 FiveM (FXServer) installé.

📦 oxmysql configuré et fonctionnel.

🗃 Base de données MySQL accessible.

📜 Ressources avec fxmanifest.lua ou _resource.lua.

Installation

Cloner ce dépôt dans votre serveur FiveM :

git clone https://github.com/votre-utilisateur/resource_loader.git

Déplacer le script dans le dossier resources/ :

mv resource_loader /chemin/vers/FXServer/resources/

Ajouter ensure resource_loader dans server.cfg.

Configurer la base de données en important la requête SQL fournie.

Configuration de la base de données

Exécutez cette requête SQL pour créer la table nécessaire :

-------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `resources` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `dependencies` TEXT NULL,
    `scripts` TEXT NULL,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
);

-------------------------------------------------------------------------------------

Logs

Les logs sont enregistrés dans logs.txt et affichés en console. Ils incluent :

📢 INFO : Informations générales.

✅ SUCCESS : Actions réussies.

⚠ WARNING : Problèmes détectés (dépendances manquantes, scripts obfusqués, etc.).

❌ ERROR : Erreurs critiques.

Prochaines étapes

📌 Amélioration des performances pour un scan plus rapide.

🔄 Ajout d'une interface de gestion des ressources.

🛡 Renforcement de la sécurité des scripts exécutés.

Contribution

Les contributions sont les bienvenues ! Forkez le projet, proposez des améliorations ou corrigez des bugs.

Licence

Ce projet est sous licence MIT. Utilisation libre et ouverte.

🚀 Développé pour faciliter la gestion des ressources sur FiveM !

