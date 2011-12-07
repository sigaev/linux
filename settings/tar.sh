[[ -e $1 ]] && mv $1{,~}
tar cJC ~ -f "$@"
[[ -e $1~ ]] || exit 0
d=${1%.txz}
mkdir $d{,~}
tar xJC $d -f $1
tar xJC $d~ -f $1~
diff -ru $d{~,} && mv $1{~,} && exec rm -fr $d{,~}
echo 'Accept diff (yes/no)?'
read q
[[ yes == $q ]] || mv $1{~,}
exec rm -fr $d{,~} $1~
