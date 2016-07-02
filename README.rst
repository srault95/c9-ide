Meteor.js - Cloud9 IDE - Docker
===============================

Environnement de développement Meteor.js

Peut aussi servir aux développements Python et Nodejs.

.. contents:: **Table des matières**
    :depth: 1
    :backlinks: none

Fonctionnalités
---------------

- Image Docker / Ubuntu xenian (16.04)
- Cloud9 3.1.2813 (master - commit 8fe2d24) - https://c9.io/
- Meteor 1.3.4.1 - https://www.meteor.com/
- Node.js v6.2.2
- Npm 3.9.5
- Python 2.7.11
- Python 3.5.1
- Serveur MongoDB 3.2.7 - http://mongodb.org/
- Serveur REDIS 3.0.6 
- Serveur Nginx comme proxy avec certificat SSL auto-généré (port 443 pour l'ide et port 8080 pour les projets meteor)

Installation
------------

- Remplacez MYPUBLIC_IP par une ip publique valide

- Remplacez le chemin du fichier de clé ssh si nécessaire (~/.ssh/authorized_keys2) 

::

    $ docker run -d --name meteor \
       -v /home/cloud9/workspace:/workspace \
       -v /home/cloud9/data:/data \
       -p MYPUBLIC_IP:443:443 -p MYPUBLIC_IP:8080:8080 \
       -e SSL_COMMON_NAME="MYPUBLIC_IP" \
       -e LOGIN_USER="admin" \
       -e LOGIN_PASSWORD="admin" \
       srault95/docker-meteor
       
   # -v /home/cloud9/workspace et /home/cloud9/data ne sont pas obligatoires
   # mais permettent de sauvegarder votre travail à l'extérieur de docker. 

Utilisation de cloud9
---------------------

- Ouvrez un navigateur à l'url https://MYPUBLIC_IP

- Login/password par défault: admin/admin

 
Création et lancement d'un projet meteor dans l'IDE
---------------------------------------------------

- Dans l'ide ouvrez une fenêtre de terminal

- Remplacez MYPUBLIC_IP par l'ip public utilisé

::

   $ cd /workspace
   
   $ git clone https://github.com/meteor/simple-todos 
   
   $ cd simple-todos   
   
   $ meteor npm install
   
   $ meteor update
   
   $ meteor -p $PORT
   
   # Ouvrez le projet meteor à l'adresse https://MYPUBLIC_IP:8080
   # Login/password par défault: admin/admin

Pour utiliser le serveur mongodb
--------------------------------

::

   $ ctl start mongodb
   
   $ ROOT_URL=https://MYPUBLIC_IP:8080 MONGO_URL=mongodb://localhost/myproject meteor -p $PORT
 
   # Ouvrez le projet meteor à l'adresse https://MYPUBLIC_IP:8080
   # Login/password par défault: admin/admin
 

Accès en mode commande
----------------------

Vous pouvez soit utiliser une fenêtre de terminal dans l'IDE, soit utiliser docker:

::

   $ docker exec -it meteor bash

 
Pour utiliser le serveur Redis
------------------------------

::

   $ ctl start redis
 
Changer le login / mot de passe http ou ajouter un utilisateur
--------------------------------------------------------------

Commandes à entrer dans une fenêtre de terminal à l'intérieur du docker.

::

   $ printf "myuser:$(openssl passwd -apr1 mypassword)\n" > /etc/nginx/.passwd
   OU
   $ htpasswd -c /etc/nginx/.passwd myuser
 
 
TODO
----

- Certificat SSL letsencrypt - https://letsencrypt.org/
- DOC: Utilisation d'un serveur MongoDB externe
- DOC: ssh
- Mise à jour 
 