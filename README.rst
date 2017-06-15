Cloud9 IDE - Docker
===================

Environnement de développement Javascript & Python

.. contents:: **Table des matières**
    :depth: 1
    :backlinks: none

Fonctionnalités
---------------

- Image Docker / Ubuntu xenial (16.04)
- Cloud9 3.1.3634 (master - commit c5d3f33) - https://c9.io/
- Python 3.5.2
- Node.js 6.11.0
- Npm 3.10.10
- Nvm 0.33.2
- Yarn 0.24.5
- Phantomjs 2.1.1
- Serveur Nginx comme proxy avec certificat SSL auto-généré (port 443 pour l'ide et port 8080)
- Ngrok (tunnel) - https://ngrok.com

Changements
-----------

- Supression de Meteor qu'il est facile d'installer à la demande
- Supression de MongoDB et Redis qu'il vaut mieux utiliser dans un docker externe
- Supression de Python2

Installation
------------

- Remplacez MYPUBLIC_IP par une ip publique valide

- Remplacez le chemin du fichier de clé ssh si nécessaire (~/.ssh/authorized_keys2) 

::

    $ docker run -d --name my-ide \
       -v /home/cloud9/workspace:/workspace \
       -v /home/cloud9/data:/data \
       -p MYPUBLIC_IP:443:443 -p MYPUBLIC_IP:8080:8080 \
       -e SSL_COMMON_NAME="MYPUBLIC_IP" \
       -e LOGIN_USER="admin" \
       -e LOGIN_PASSWORD="admin" \
       srault95/c9-ide
       
   # -v /home/cloud9/workspace et /home/cloud9/data ne sont pas obligatoires
   # mais permettent de sauvegarder votre travail à l'extérieur de docker. 

Utilisation de cloud9
---------------------

- Ouvrez un navigateur à l'url https://MYPUBLIC_IP

- Login/password par défault: admin/admin

Accès en mode commande
----------------------

Vous pouvez soit utiliser une fenêtre de terminal dans l'IDE, soit utiliser docker:

::

   $ docker exec -it my-ide bash

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
 