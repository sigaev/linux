list=bash chrome firefox terminal vim xfce

bash=.bash_logout .bash_profile .bashrc
chrome=.config/google-chrome/Default/Preferences
firefox=.mozilla/firefox/{profiles.ini,whgzzlr0.default/prefs.js}
terminal=.gconf
vim=.vimrc
xfce=--exclude=.config/google-chrome .config .xinitrc .xscreensaver .xserverrc

all: $(foreach i,$(list),$(i).txz)

%.txz:
	tar cJf $@ -C ~ $($(@:.txz=))
