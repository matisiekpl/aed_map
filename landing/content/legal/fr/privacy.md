---
title: Politique de confidentialité
updatedAt: '2026-10-15'
---

# Politique de confidentialité

La présente politique s'applique à l'application mobile Carte des DAE pour iOS et Android ainsi qu'au site aedmapa.pl.

## Responsable du traitement

Le responsable du traitement des données est Mateusz Woźniak. Contact pour les questions relatives aux données personnelles : [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl).

## Données traitées par l'application

### Localisation

Après l'octroi de l'autorisation d'accès à la localisation, l'application l'utilise pour afficher les défibrillateurs les plus proches et la distance qui les sépare de l'utilisateur. Les coordonnées approximatives sont également enregistrées dans les événements analytiques Mixpanel (décrits ci-dessous).

Lors du calcul d'un itinéraire à pied, les coordonnées du point de départ et du DAE choisi sont envoyées au serveur de calcul d'itinéraires Valhalla (sa.tt.com.pl). Le serveur renvoie l'itinéraire et ne reçoit aucune autre donnée concernant l'utilisateur.

### Carte

Les zones de carte sont téléchargées depuis les serveurs de l'OpenStreetMap Foundation (tile.openstreetmap.org). À chaque téléchargement, le serveur reçoit l'adresse IP de l'appareil, conformément à la [politique de confidentialité de l'OSMF](https://osmfoundation.org/wiki/Privacy_Policy).

### Compte OpenStreetMap

L'ajout et la modification de défibrillateurs nécessitent une connexion avec un compte OpenStreetMap (OAuth 2.0). L'application conserve le jeton d'accès uniquement sur l'appareil et récupère depuis OpenStreetMap l'identifiant, le nom d'utilisateur et l'avatar.

Chaque modification enregistrée dans OpenStreetMap est publique et signée du nom d'utilisateur. L'historique des modifications dans OpenStreetMap est soumis aux règles de l'OpenStreetMap Foundation et ne peut pas être supprimé par l'application.

### Photos

Avant son envoi, la photo du défibrillateur est vérifiée sur l'appareil par un modèle de détection de contenus inappropriés. La photo est transmise au serveur du projet OpenAEDMap (back.openaedmap.org), publiée sous licence CC0 et visible par tous les utilisateurs d'OpenAEDMap. Le signalement d'une photo transmet son identifiant à OpenAEDMap.

### Analyse et diagnostic

L'application utilise les services suivants :

- **Mixpanel** (Mixpanel, Inc., serveurs dans l'UE) : événements d'utilisation de l'application, tels que la sélection d'un défibrillateur, le lancement de la navigation, un appel téléphonique ou l'enregistrement d'une modification, accompagnés du modèle de l'appareil, de la version du système et de l'application ainsi que des coordonnées de localisation. Après connexion avec un compte OpenStreetMap, les événements sont associés à l'identifiant, au nom et à l'avatar de l'utilisateur OpenStreetMap.
- **Sentry** (Functional Software, Inc.) : rapports d'erreurs et données de performance, avec le modèle de l'appareil et la version du système. Après connexion, le rapport contient l'identifiant et le nom de l'utilisateur OpenStreetMap. Un avis envoyé depuis l'écran des réglages est transmis à Sentry avec une capture d'écran et le texte saisi par l'utilisateur.
- **Firebase Analytics et Firebase Remote Config** (Google Ireland Ltd.) : statistiques d'utilisation de l'application associées à l'identifiant d'installation et téléchargement de la configuration de l'application.
- **Plausible** (instance hébergée par le responsable du traitement) : statistiques agrégées de consultation, sans cookies et sans identifiants d'utilisateur.

## Données traitées par le site

Le site aedmapa.pl utilise Plausible hébergé par le responsable du traitement. Plausible n'enregistre pas de cookies et ne conserve pas les adresses IP. Le site enregistre un cookie `i18n_redirected` contenant la langue choisie.

## Finalités et base juridique

- Fonctionnement des fonctionnalités de l'application (localisation, itinéraire, modification, photos) : exécution du service demandé par l'utilisateur (art. 6, paragraphe 1, point b), du RGPD) ainsi que consentement à l'accès à la localisation et aux photos accordé dans le système.
- Analyse et diagnostic des erreurs : intérêt légitime du responsable du traitement consistant à maintenir et développer l'application (art. 6, paragraphe 1, point f), du RGPD).

## Transferts de données hors de l'EEE

Sentry, Google et Mixpanel peuvent traiter des données aux États-Unis sur la base de clauses contractuelles types ou de l'EU-U.S. Data Privacy Framework.

## Durée de conservation

- Données dans Mixpanel : jusqu'à 5 ans.
- Rapports Sentry : 90 jours.
- Données Firebase Analytics : 14 mois.
- Données enregistrées sur l'appareil (base des défibrillateurs, jeton OpenStreetMap, réglages) : jusqu'à la déconnexion ou la désinstallation de l'application.

## Droits de l'utilisateur

L'utilisateur dispose d'un droit d'accès à ses données, de rectification, d'effacement, de limitation du traitement, de portabilité ainsi que d'un droit d'opposition au traitement fondé sur l'intérêt légitime. Les demandes sont reçues à l'adresse [mateusz@aedmapa.pl](mailto:mateusz@aedmapa.pl). L'utilisateur a également le droit d'introduire une réclamation auprès du Président de l'Office polonais de protection des données personnelles (UODO) ou de l'autorité de contrôle du pays de résidence (en France, la CNIL).

## Enfants

L'application ne s'adresse pas aux enfants de moins de 13 ans et ne collecte pas sciemment leurs données.

## Modifications

Toute nouvelle version de la politique est publiée sur cette page avec la date de dernière mise à jour.
