nom : FAHA FOSSO CHRIST DIMITRI

Pre-requis : Configutrations Systeme 
  - Gradle : version >= 8.5 
  -  OpenJDK: version >= 17
  - Avoir l'IDE Android studio Installe sur votre systeme
  - Avoir installer flutter la version 3. et dart la version 

1) Installation de l'application 

  - recuperer les projet a partir d'un git clone :
    command : git clone  https://github.com/christ20351/tasky-FAHA_FOSSO.git 

  - allez dans le repertoire racine du projet clone
            /tasky-FAHA_FOSSO

  - Installer toutes les dependances requises :
    command  : flutter  pub get

  - Executer l'application avec  un emulateur (vous assurez que votre AndroiSDK    est   au moins a la version 34)
    command  : flutter run  


2)  Description des choix techniques 

    Architecture : j'ai utilise une architecture MVC (Models-Views-controllers)
    packages : 
      # Use with the CupertinoIcons class for iOS style icons.
      cupertino_icons: ^1.0.8
      
      # Local storage dependencies
      sqflite: ^2.3.0
      path: ^1.8.3
      
      # State management
      provider: ^6.1.1
      
      # UI and animations
      animated_text_kit: ^4.2.2
      lottie: ^3.0.0
      
      # Utilities
      shared_preferences: ^2.2.2
      intl: ^0.19.0
      crypto: ^3.0.3
    
3) Explication et Defis rencontre 

  - defi :
    J'ai en effet eu un problemme lors de l'implementation de l'application avec  
    firebase. Plus precisement au niveau de mon compte firebase ; a la derniere minute lorsque je faisais des tests de l'application  pour pouvoir enfin le push vers le depot distant j'ai malheureusement appris mon compte firebase a ete suspendu pour des raisons dont j'ignores. 
  
  - solution : 
    Faute de temps donc, j'ai du migrer vers une solution plus simple c'est a dire  une base local en utilisant Sqflite , et tout recommence le backend a zero. Et malheureusement je n'ai donc pas plus terminer les fonctionnalites de l'application notament avec le logout  , l'implementation des tests unitaires..etc
