# Commandes utiles

Au préalable :

- identifier le tank utilisé (piston, pirate ou pistol) et son adresse IP (IP_Robot)
- brancher le tank au réseau à l'aide d'un câble Ethernet.

## Copier le fichier exécutable sur le tank :

``` shell
scp ./exec/mon_prog rasp@IP_Robot:/home/rasp/.
```
Mot de passe : framboise

## Se connecter sur le tank :

``` shell
ssh rasp@IP_Robot
```
Mot de passe : framboise

## Exécuter le programme sur le tank :

Après s'être connecté en ssh :

``` shell
./mon_prog &
```

**ATTENTION** : Déconnecter la session ssh (Ctrl-D) avant de débrancher le câble Ethernet.
