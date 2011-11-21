
function weather {
   loc=$1
   [[ -z $loc ]] && loc=78756
   # incredibly fragile, but why not?
   hget 'http://thefuckingweather.com/?zipcode='$loc | htmlfmt | sed -e '2d' -e '/^$/q'
}
