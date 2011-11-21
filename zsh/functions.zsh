
function weather {
   # incredibly fragile, but why not?
   hget 'http://thefuckingweather.com/?zipcode='$1 | htmlfmt | sed -e '2d' -e '/^$/q'
}
