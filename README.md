# Atlas: Survival Evolved - Docker

Docker build for managing an ARK: Survival Evolved server.

Forked from [TuRz4m's Ark-docker project](https://github.com/TuRz4m/Ark-docker) project.

This image uses [Atlas Server Tools](https://github.com/BoiseComputer/atlas-server-tools/) to manage an atlas server.


## Features (same as TuRz4m's Ark-docker)
 - Easy install (no steamcmd / lib32... to install)
 - Use Atlas Server Tools : update/install/start/backup/rcon/mods
 - Easy crontab configuration
 - Easy access to atlas config file
 - Mods handling (via Atlas Server Tools)
 - `Docker stop` is a clean stop 

## Usage
Fast & Easy server setup :   
`docker run -d -p 5750:5750 -p 5750:5750/udp -p 57550:57550 -p 57550:57550/udp -e ADMINPASSWORD="mypasswordadmin" --name atlas gabethecabbage/atlas`

You can map the atlas volume to access config files :  
`docker run -d -p 5750:5750 -p 5750:5750/udp -p 57550:57550 -p 57550:57550/udp -e SESSIONNAME=myserver -v /my/path/to/atlas:/atlas --name gabethecabbage/atlas`  
Then you can edit */my/path/to/atlas/atlasmanager.cfg* (the values override GameUserSetting.ini) and */my/path/to/atlas/[GameUserSetting.ini/Game.ini]*

You can manager your server with rcon if you map the rcon port (you can rebind the rcon port with docker):  
`docker run -d -p 5750:5750 -p 5750:5750/udp -p 57550:57550 -p 57550:57550/udp -p 32330:32330  -e SESSIONNAME=myserver --name atlas gabethecabbage/atlas`  

You can change server and steam port to allow multiple servers on same host:  
*(You can't just rebind the port with docker. It won't work, you need to change STEAMPORT & SERVERPORT variable)*
`docker run -d -p 5751:5751 -p 5751:5751/udp -p 57551:57551 -p 57551:57551/udp -p 32331:32330  -e SESSIONNAME=myserver2 -e SERVERPORT=57551 -e STEAMPORT=5751 --name atlas2 gabethecabbage/atlas`  

You can check your server with :  
`docker exec atlas atlasmanager status` 

You can manually update your mods:  
`docker exec atlas atlasmanager update --update-mods` 

You can manually update your server:  
`docker exec atlas atlasmanager update --force` 

You can force save your server :  
`docker exec atlas atlasmanager saveworld` 

You can backup your server :  
`docker exec atlas atlasmanager backup` 

You can upgrade Ark Server Tools :  
`docker exec atlas atlasmanager upgrade-tools` 

You can use rcon command via docker :  
`docker exec atlas atlasmanager rconcmd ListPlayers`  
*Full list of available command [here](http://steamcommunity.com/sharedfiles/filedetails/?id=454529617&searchtext=admin)*

__You can check all available command for atlasmanager__ [here](https://github.com/FezVrasta/atlas-server-tools/blob/master/README.md)

You can easily configure automatic update and backup.  
If you edit the file `/my/path/to/atlas/crontab` you can add your crontab job.  
For example :  
`# Update the server every hours`  
`0 * * * * atlasmanager update --warn --update-mods >> /atlas/log/crontab.log 2>&1`    
`# Backup the server each day at 00:00  `  
`0 0 * * * atlasmanager backup >> /atlas/log/crontab.log 2>&1`  
*You can check [this website](http://www.unix.com/man-page/linux/5/crontab/) for more information on cron.*

To add mods, you only need to change the variable atlas_GameModIds in *atlasmanager.cfg* with a list of your modIds (like this  `atlas_GameModIds="987654321,1234568"`). If UPDATEONSTART is enable, just restart your docker or use `docker exec atlas atlasmanager update --update-mods`.

---

## Recommended Usage
- First run  
 `docker run -it -p 5750:5750 -p 5750:5750/udp -p 57550:57550 -p 57550:57550/udp -p 32330:32330 -e SESSIONNAME=myserver -e ADMINPASSWORD="mypasswordadmin" -e AUTOUPDATE=120 -e AUTOBACKUP=60 -e WARNMINUTE=30 -v /my/path/to/atlas:/atlas --name atlas gabethecabbage/atlas`  
- Wait for atlas to be downloaded installed and launched, then Ctrl+C to stop the server.
- Edit */my/path/to/atlas/GameUserSetting.ini and Game.ini*
- Edit */my/path/to/atlas/atlasserver.cfg* to add mods and configure warning time.
- Add auto update every day and autobackup by editing */my/path/to/atlas/crontab* with this lines :  
`0 0 * * * atlasmanager update --warn --update-mods >> /atlas/log/crontab.log 2>&1`  
`0 0 * * * atlasmanager backup >> /atlas/log/crontab.log 2>&1`  
- `docker start atlas`
- Check your server with :  
 `docker exec atlas atlasmanager status` 

--- 

## Variables
+ __SERVERMAP__
Map of your atlas server (default : "Ocean")
+ __SERVERPASSWORD__
Password of your atlas server (default : "")
+ __ADMINPASSWORD__
Admin password of your atlas server (default : "adminpassword")
+ __SERVERPORT__
Ark server port (can't rebind with docker, it doesn't work) (default : 57550)
+ __STEAMPORT__
Steam server port (can't rebind with docker, it doesn't work) (default : 5750)
+ __BACKUPONSTART__
1 : Backup the server when the container is started. 0: no backup (default : 1)
+ __UPDATEPONSTART__
1 : Update the server when the container is started. 0: no update (default : 1)  
+ __BACKUPONSTOP__
1 : Backup the server when the container is stopped. 0: no backup (default : 0)
+ __WARNONSTOP__
1 : Warn the players before the container is stopped. 0: no warning (default : 0)  
+ __TZ__
Time Zone : Set the container timezone (for crontab). (You can get your timezone posix format with the command `tzselect`. For example, France is "Europe/Paris").
+ __UID__
UID of the user used. Owner of the volume /atlas
+ __GID__
GID of the user used. Owner of the volume /atlas


--- 

## Volumes
+ __/atlas__ : Working directory :
    + /atlas/server : Server files and data.
    + /atlas/log : logs
    + /atlas/backup : backups
    + /atlas/atlasmanager.cfg : config file for Ark Server Tools
    + /atlas/crontab : crontab config file
    + /atlas/Game.ini : atlas game.ini config file
    + /atlas/GameUserSetting.ini : atlas gameusersetting.ini config file
    + /atlas/template : Default config files
    + /atlas/template/atlasmanager.cfg : default config file for Ark Server Tools
    + /atlas/template/crontab : default config file for crontab
    + /atlas/staging : default directory if you use the --downloadonly option when updating.

--- 

## Expose
+ Port : __STEAMPORT__ : Steam port (default: 5750)
+ Port : __SERVERPORT__ : server port (default: 57550)
+ Port : __32330__ : rcon port

---

## Known issues

---

## Changelog
+ 1.0 : 
  - Initial fork from Ark-docker 1.3
  - Tested with atlas-server-tools v1.8.5.5

