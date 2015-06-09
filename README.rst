Meteor.js - Cloud9 IDE - Docker
===============================

Environnement de développement Cloud9/MeteorJS

Peut aussi servir aux développements python, nodejs.

Fonctionnalités
---------------

- Image Docker / Ubuntu trusty (14.04) + mise à jour distribution
- Cloud9 master (au 09/06/2015) - https://c9.io/
- Meteor 1.1.0.2 - https://www.meteor.com/
- Node.js 0.12.4
- NPM 2.11.1
- Serveur MongoDB 2.6.10 - http://mongodb.org/
- Serveur SSH avec authentification par clé privé (bind docker sur port 2223)
- Serveur REDIS 3.0.2 
- Serveur Nginx comme proxy avec certificat SSL auto-généré (port 443 pour l'ide et port 444 pour les projets meteor)

Installation
------------

- Remplacez MYPUBLIC_IP par une ip publique valide

- Remplacez le chemin du fichier de clé ssh si nécessaire (~/.ssh/authorized_keys2) 

::

    $ git clone https://github.com/srault95/docker-meteor.git
    
    $ cd docker-meteor
    
    $ docker build -t cloud9
    
    # Facultatif mais permet de rendre vos données permanentes
    $ mkdir -vp /home/cloud9/workspace /home/cloud9/data
    
    $ docker run -d --name meteor \
       -v /home/cloud9/workspace:/workspace \
       -v /home/cloud9/data:/data \
       -v ~/.ssh/authorized_keys2:/root/.ssh/authorized_keys \
       -p 2223:22 \
       -p MYPUBLIC_IP:443:443 -p MYPUBLIC_IP:444:444 \
       -e SSL_COMMON_NAME="MYPUBLIC_IP" \
       -e LOGIN_USER="admin" \
       -e LOGIN_PASSWORD="admin" \
       cloud9

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
    
    $ meteor create myproject
    
    $ cd myproject    

    ROOT_URL=https://MYPUBLIC_IP:444 MONGO_URL=mongodb://localhost/myproject meteor -p $IP:$PORT
 
- Ouvrez le projet meteor à l'adresse https://MYPUBLIC_IP:444

- Login/password par défault: admin/admin
 
Outils Intégrés
---------------

- Phantomjs
- node-gyp
- fibers
- yo
- forever
- bower
- coffee
- grunt-cli
- gulp
- less
- saas
- typescript
- stylus
- iron-meteor
- demeteorizer
- node-inspector
     
- Python Setuptools
- Pip installer 