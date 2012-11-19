list=bash chrome compiz firefox git ssh terminal vim virtualbox xfce

bash=.bash_logout .bash_profile .bashrc
chrome=.config/google-chrome/Default/Preferences
compiz=--exclude=\*.png .config/compiz .emerald .start-compiz.sh
firefox=.mozilla/firefox/{profiles.ini,whgzzlr0.default/prefs.js}
git=.gitconfig .gitk
ssh=--no-recursion .ssh{,/authorized_keys}
terminal=.gconf
vim=.vimrc
virtualbox=--exclude={\*.log\*,Snapshots} .VirtualBox
xfce=--exclude=.config/google-chrome .config .xinitrc .xscreensaver .xserverrc

d:=$(shell mktemp -d)

all: $(foreach i,$(list),$(i).t)
	aws get sigaev/linux/settings/Makefile | diff -u - Makefile || aws put 'x-amz-acl: public-read' sigaev/linux/settings/Makefile Makefile
	rm -fr $(d)

%.t:
	./archive $(d)/$@xz $($(@:.t=))
