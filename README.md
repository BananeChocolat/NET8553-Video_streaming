# NET8553-Video_streaming

Projet ayant pour but de déployer un coeur et réseau 5G simulé dans k3s, diffuser de la vidéo à travers le réseau et monitorer l'utilisation des ressources par cette activité.

Groupe de projet:
 - Marceau Gillio
 - Aurélien Jacques-Yonyul
 - Nicolas Riedel

# Etat de l'art 




# Méthode de diffusion

Nous avons voulu mettre en place un flux vidéo tel que: 

**UE -> gNB -> UPF -> DN -> machine hôte**

Pour cela, il nous fallait modifier ou créer un nouvel UE qui puisse diffuser de la vidéo.

Nous avons choisi ffmpeg pour sa capacité à généré un flux vidéo de lui-même et sa robustesse largement démontrée par son utilisation dans la plupart des logiciels de traitement photo/vidéo.


# Implementation

Avant tout, nous n'avons pas réussi à faire fonctionner ce projet.

Mais voici l'implémentation et la marche suivie:

Nous avons commencé par la création d'un pod de zéro.
Cependant, nous avons eu des problèmes lors de la création de ce pod avec vlc que nous avions choisi avant de nous tourner vers ffmpeg.

Les fichiers de configuration créés pour le pod indépendant sont dans le dossier `/ue-video` du dépôt.

Ensuite nous avons tenté une approche plus simple et donc peut-être plus robuste: modifier un UE déjà existant et fonctionnel.

Nous avons alors modifié le ueransim-ue2 afin d'intégrer un conteneur ffmpeg.

ues-deployement.yaml :
```
- name: ffmpeg
          image: jrottenberg/ffmpeg:4.4-ubuntu
          imagePullPolicy: IfNotPresent
          command: ["/bin/sh","-c"]
          args:
            - |
              TARGET="{{ .Values.video.targetIP }}"
              PORT="{{ .Values.video.targetPort }}"
              LAVFI="{{ .Values.video.ffmpeg_lavfi }}"

              ffmpeg -re -f lavfi -i "${LAVFI}" -c:v libx264 -preset ultrafast -tune zerolatency \
                     -f mpegts "udp://${TARGET}:${PORT}?pkt_size=1316"
``` 
afin de transmettre un flux vidéo généré automatiquement par ffmpeg.

values.yaml :
```
video:
  enabled: true
  targetIP: "10.74.147.107"
  targetPort: 5004
  ffmpeg_lavfi: "testsrc=size=1280x720:rate=30"
```
afin de définir des valeurs utiles pour la diffusion de la vidéo.

# Démonstration

Comme dit précédemment, nous n'avons pas réussi à faire fonctionner ce projet. 

Néanmoins, nous avons à plusieurs reprises et en suivant des approches différentes, presque touché au but.

La plus notable fût avec l'implémentation finale. 
En effet, les logs du conteneur ffmpeg accusaient du bon fonctionnement de l'émission de vidéo depuis le CLI interne.

Malheuresement impossible de lire le flux dans VLC sur la machine hôte à cause d'un fichier SDP manquant.

Nous avons cherché une solution mais n'avons pas pu implémenter et déployer une correction par manque de temps. Il semblerait que le fichier SDP peut être créé par le ffmpeg dans le conteneur et qu'il faut ensuite le transmettre à la machine qui veut recevoir le flux vidéo.
