tar cJC ~ -f "$@"
[[ -e `basename $1` ]] || exec mv $1 .
d=${1%.txz}
mkdir $d{,~}
tar xJC $d -f $1
tar xJC $d~ -f `basename $1`
diff -ru $d{~,} && exec rm -fr $d{,~} $1
echo 'Accept diff (yes/no)?'
read q
[[ yes == $q ]] && mv $1 .
exec rm -fr $d{,~} $1
