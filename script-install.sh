#!/bin/bash
# SETUP MANAGER
# ================================
# AUTEUR : HUGO GUTEKUNST
# DESCRIPTION : Script d'installation et configuration post OS setup
# LISENCE : GPL
# VERSION : 2.0
# CREATION : 17/10/2013
# MAJ : 19/10/2013
# PREREQUIS : Avoir les droits root, systeme Debiam et derive.
# ================================

# /!\ Ce script requiert les droits root
if [ "$USER" != 'root' ]; then 
	echo '[ERREUR] Vous devez etre root pour executer ce script.' && exit;
fi

# ================================
# PARAMETRES
# ================================
# Choisissez les fonctions que le script doit executer. Exemple : fonction=[yes|no]
upgrade_system='no' # Mise a jour du systeme
installation_paquet_liste='no' # installation des paquets definis plus bas
configuration_ssh='no' # configuration du serveur ssh
configuration_vim='no' # configuration du logiciel vim
history_format='no' # Personnalisation de l'affichage de l'historique des commandes
change_umask='no' # changer la variable umask, par defaut umask vaut '066'
color_console='no' # colorisation syntaxique du listing de fichier selon le type. visualisez avec `ls -l`
custom_prompt='no' # personnaliser le prompt du shell, ajout des couleurs au bashrc
add_logo='no' # ajouter un logo en ASCII ART a l'ouverture de session bash
info_session='no' # ajouter des informations systeme a l'ouverture de session bash
firewall_iptable='no' # configurer l'ordinateur de maniere securisee

# Ajouter ici les depots PPA (commenter pour desactiver les depots prives)
	#add-apt-repository ppa:freetuxtv/freetuxtv # freetuxtv

# Listing des paquets a installer :
# Precisez les paquets que le script doit installer.
# Exemple : monpaquet		yes|no
paquage="\
openssh-server			no
vim				yes
apticron			no
lynis				no
qshutdown			no
xchat				no
nmap				no
lftp				no
filezilla			no
youtube-dl			no
wakeonlan			no
wallch				no
chromium			no
chromium-l10n			no
freetuxtv			no
soundconverter			no
git				no
remmina				no
beep				no
moc				no
cmatrix				no
autoscan			no
keepassx			no
skype				no
linuxlogo			no
gnome-tweak-tool		no
audio-recorder			no
vrms				no
truecrypt			no
conky				no
conky-all			no
openshot			no
skype				no"

# Ajouter votre motif ASCII ART ici (entre les doubles quotes)
motif="echo '
  ___  ___ _____              _                      _    
  /___\/ __\___ /   _ __   ___| |___      _____  _ __| | __
 //  // /    |_ \  | '_ \ / _ \ __\ \ /\ / / _ \| '__| |/ /
/ \_// /___ ___) | | | | |  __/ |_ \ V  V / (_) | |  |   < 
\___/\____/|____/  |_| |_|\___|\__| \_/\_/ \___/|_|  |_|\_\'"



# ================================
# CORP DU PROGRAMME - Le code suivant ne devrait pas etre modifiez
# ================================

apt-get update

custom_prompt()
{ # personnalisation du prompteur 
	if [ "$1" = 'yes' ]; then

		echo "
# CODE COULEUR
# =======================
noir='\033[00m'
rouge='\033[31m'
vert='\033[32m'
orange='\033[33m'
bleu='\033[34m'
magenta='\033[35m'
cyan='\033[36m'
blanc='\033[37m'

fond_noir='\033[40m'
fond_rouge='\033[41m'
fond_vert='\033[42m'
fond_orange='\033[43m'
fond_bleu='\033[44m'
fond_magenta='\033[45m'
fond_cyan='\033[46m'
fond_blanc='\033[47m'

effet_gras='\033[01m'
effet_sousligne='\033[04m'
effet_clignotant='\033[05m'
effet_surligne='\033[07m'

# PROMPTEUR PERSONALLISATION
# ==========================
# \w = \$PWD ; \h = \$HOSTNAME ; \u = \$USER
export PS1=\"\
\$bleu\\u\$noir\
\$orange@\$noir\
\\h\
:\
\$rouge\\w\$noir\
\\$ \"" >> ~/.bashrc
	
	source ~/.bashrc
	fi
}


upgrade_system()
{ # mise a jour du systeme
	if [ "$1" = 'yes' ]; then
		apt-get upgrade -y
	fi
}

installation_paquet_liste()
{ # installation des paquets 
	if [ "$1" = 'yes' ]; then
		paquet_liste=''
		while read paquet_name paquet_install
		do
			if [ "$paquet_install" = 'yes'  ]; then
				paquet_liste="$paquet_liste $paquet_name"
			fi
		done <<<"$paquage"
		echo -e "/!\ INSTALLATION\n\r--------------------------"
		echo -e "Les paquets suivants vont etre installes (dans 5sec):\n\r$paquet_liste"
		echo -e "--------------------------"
		sleep 5
		apt-get install -s -y $paquet_liste
	fi    
}

configuration_ssh()
{ # configuration SSH	
	if [ "$1" = 'yes' ]; then
		ssh_config_path='/etc/ssh/sshd_config'
		sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $ssh_config_path
		sed -i 's/#AuthorizedKeysFile.*/AuthorizedKeysFile %h\/\.ssh\/authorized_keys/' $ssh_config_path
		/etc/init.d/ssh restart
	fi
}

configuration_vim()
{ # configuration VIM
	if [ "$1" = 'yes' ]; then
		vim_conf='/etc/vim/vimrc.local'
		echo -e "syntax on\nset nu" >>$vim_conf
		echo 'set showcmd' >>$vim_conf
		echo 'set ignorecase' >>$vim_conf
	fi
}

change_umask()
{ # changer le umask par defaut
	if [ "$1" = 'yes' ]; then
		echo 'umask 077' >> ~/.profile
	fi
}

history_format()
{ # Modifier le format de la commande history
	if [ "$1" = 'yes' ]; then
		echo 'HISTTIMEFORMAT="%d/%m/%Y - %H:%M:%S "' >> ~/.bash_profile
		echo 'HISTSIZE=1000' >> ~/.bash_profile
		source ~/.bash_profile
	fi
}

color_console()
{ # colorisation syntaxique du 'ls' sur le terminal
	if [ "$1" = 'yes' ]; then
		echo "export LS_OPTIONS='--color=auto'" >> ~/.bashrc
		echo "eval \"\`dircolors\`\"" >> ~/.bashrc
		echo "alias ls='ls \$LS_OPTIONS'" >> ~/.bashrc
		echo 'umask 077' >> ~/.bashrc
		source ~/.bashrc
	fi
}

add_logo()
{ # commentaire
	if [ "$1" = 'yes' ]; then
		echo "
		echo -e \"\$rouge\"
		`echo \"$motif\"`
		echo -e \"\$noir\"" >> ~/.bashrc
		source ~/.bashrc	
	fi
}

#ma_fonction_exemple()
#{ # commentaire
#	if [ "$1" = 'yes' ]; then
#		# instructions ;
#	fi
#}


# Execution des fonctions
upgrade_system $upgrade_system
installation_paquet_liste $installation_paquet_liste
configuration_ssh $configuration_ssh
configuration_vim $configuration_vim
history_format $history_format
change_umask $change_umask
color_console $color_console
custom_prompt $custom_prompt
add_logo $add_logo
# info_session $info_session
# firewall_iptable $firewall_iptable
