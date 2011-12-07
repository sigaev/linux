list=bash chrome firefox gitk ssh terminal vim xfce

bash=.bash_logout .bash_profile .bashrc
chrome=.config/google-chrome/Default/Preferences
firefox=.mozilla/firefox/{profiles.ini,whgzzlr0.default/prefs.js}
gitk=.gitk
ssh=--no-recursion .ssh{,/authorized_keys}
terminal=.gconf
vim=.vimrc
xfce=--exclude=.config/google-chrome .config .xinitrc .xscreensaver .xserverrc

all: $(foreach i,$(list),$(i).t)

%.t:
	bash tar.sh $@xz $($(@:.t=))
