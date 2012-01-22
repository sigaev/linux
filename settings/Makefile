list=bash chrome firefox gitk ssh terminal vim virtualbox xfce

bash=.bash_logout .bash_profile .bashrc
chrome=.config/google-chrome/Default/Preferences
firefox=.mozilla/firefox/{profiles.ini,whgzzlr0.default/prefs.js}
gitk=.gitk
ssh=--no-recursion .ssh{,/authorized_keys}
terminal=.gconf
vim=.vimrc
virtualbox=--exclude={\*.log\*,Snapshots} .VirtualBox
xfce=--exclude=.config/google-chrome .config .xinitrc .xscreensaver .xserverrc

d:=$(shell mktemp -d)

all: $(foreach i,$(list),$(i).t)
	rm -fr $(d)

%.t:
	./archive $(d)/$@xz $($(@:.t=))
