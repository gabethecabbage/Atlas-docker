#!/usr/bin/env bash
echo "###########################################################################"
echo "# Atlas Server - " `date`
echo "# UID $UID - GID $GID"
echo "###########################################################################"
[ -p /tmp/FIFO ] && rm /tmp/FIFO
mkfifo /tmp/FIFO

export TERM=linux

function stop {
	if [ ${BACKUPONSTOP} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedAtlas)" ]; then
		echo "[Backup on stop]"
		atlasmanager backup
	fi
	if [ ${WARNONSTOP} -eq 1 ];then 
	    atlasmanager stop --warn
	else
	    atlasmanager stop
	fi
	exit
}



# Change working directory to /atlas to allow relative path
cd /atlas

# Add a template directory to store the last version of config file
[ ! -d /atlas/template ] && mkdir /atlas/template
# We overwrite the template file each time
cp /home/steam/atlasmanager.cfg /atlas/template/atlasmanager.cfg
cp /home/steam/crontab /atlas/template/crontab
# Creating directory tree && symbolic link
[ ! -f /atlas/atlasmanager.cfg ] && cp /home/steam/atlasmanager.cfg /atlas/atlasmanager.cfg
[ ! -d /atlas/log ] && mkdir /atlas/log
[ ! -d /atlas/backup ] && mkdir /atlas/backup
[ ! -d /atlas/staging ] && mkdir /atlas/staging
[ ! -L /atlas/Game.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/Game.ini Game.ini
[ ! -L /atlas/GameUserSettings.ini ] && ln -s server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini GameUserSettings.ini
[ ! -f /atlas/crontab ] && cp /atlas/template/crontab /atlas/crontab



if [ ! -d /atlas/server  ] || [ ! -f /atlas/server/atlasversion ];then 
	echo "No game files found. Installing..."
	mkdir -p /atlas/server/ShooterGame/Saved/SavedArks
	mkdir -p /atlas/server/ShooterGame/Content/Mods
	mkdir -p /atlas/server/ShooterGame/Binaries/Linux/
	touch /atlas/server/ShooterGame/Binaries/Linux/ShooterGameServer
	atlasmanager install
	# Create mod dir
else

	if [ ${BACKUPONSTART} -eq 1 ] && [ "$(ls -A server/ShooterGame/Saved/SavedArks/)" ]; then 
		echo "[Backup]"
		atlasmanager backup
	fi
fi


# If there is uncommented line in the file
CRONNUMBER=`grep -v "^#" /atlas/crontab | wc -l`
if [ $CRONNUMBER -gt 0 ]; then
	echo "Loading crontab..."
	# We load the crontab file if it exist.
	crontab /atlas/crontab
	# Cron is attached to this process
	sudo cron -f &
else
	echo "No crontab set."
fi

# Launching atlas server
if [ $UPDATEONSTART -eq 0 ]; then
	atlasmanager start --noautoupdate
else
	atlasmanager start
fi


# Stop server in case of signal INT or TERM
echo "Waiting..."
trap stop INT
trap stop TERM

read < /tmp/FIFO &
wait
