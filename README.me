AutoTU
======

Installation
------------

Utilisez le Ant Migration Tool de Sf, Eclipse...
Le présent package est un unmanagedPackage, avec le fichier package.xml qui va bien.

Est disponible aussi les liens d'installations suivants :
V1 : Sans coverage, Sans appel à la toolingAPI, sans négociation Oauth:

- [Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb00000009w7i)
- [Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb00000009w7i)

V2 : Version actuelle, nécessite l'ouverture d'une App connectée Salesforce, et l'ouverture d'un second remote site:

- [Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tb00000009wKs)
- [Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tb00000009wKs)

La version github est potentiellement plus à jour.

Configuration
-------------

### Configuration des Remotes Sites Settings ###

- 2 remotes sites à configurer:
	- *OauthInternal*: l'adresse de login SF : login.salesforce.com pour un env de prod, ou un env de dev, test.salesforce.com pour une sandbox.
	- *ToolingAPI*: l'endpoint actuel de l'environnement, eu1.salesforce.com par exemple, ou cs17.salesforce.com pour une sandbox.

### Configuration de l'app connecté Salesforce ###

- A créer manuellement
- Doit autoriser les connections Oauth, avec les paramètres suivants :
	- Enable OAuth Settings : cochée
	- callbackUrl : par exemple, https://eu2.salesforce.com/oauth/_callback
	- Scope : "Access an manage your data (api)"

### Configuration des Customs Settings ###

2 CustomSettings :

- *Automated Testing Parameters* (AutoTUParams__c)
	- Attends une configuration par défaut (Organization Level), contenant les divers paramètres du système.
		- login Url : L'url de login à l'org (correspond à la valeur donnée dans le remote site Security *OauthInternal*)
		- Oauth Client ID: La valeur **Consumer Key** de l'app précédemment créé
		- Oauth Client Secret : La valeur **Consumer Secret** de l'app précédemment créé
		- username: le login de l'utilisateur utilisé pour accéder à la tooling API
		- password: Son password.
		- Cron Queuer Job : la configuration Cron pour le lancement des TestU (par exemple, "0 0 4 * * ?" pour lancer la tache tout les jours à 4h AM)
		- Cron Sender Job:  la configuration Cron pour l'envoi du rapport par mail, doit être effectuer apres le lancement des TU. (par exemple, "0 0 6 * * ?" pour lancer la tache tout les jours à 6h AM)

- *Automated Testing Destinataires*:
	- Liste des destinataires du rapport mail:
		- Attend un nom (unique)
		- Attend l'id de l'user correspondant (permet de ne pas compter dans les limites d'envoi de mail).

Utilisation
-----------

### Schedule

Exécuter en Anonymous Apex le code suivant :

```java
AutomatedTestJobQueuer.scheduleIt();
AutomatedTestingJob.scheduleIt();
```

Réutilise les paramètres CRON configuré précédemment.


### Via WebService

Est disponible 2 ressources exposées en WS (REST / SOAP):

- AutomatedTestingJobQueuer.enqueueUnitTests();
	- Lance le run All test

- AutomatedTestingJob.getMailResults();
	- Lance l'envoi du rapport Mail en utilisant les données précédemment récupéré par AutomatedTestingJobQueuer.enqueueUnitTests()
