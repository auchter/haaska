
# quick functions for radix conversion

function hex2bin {
   echo -n 0b
   echo 2o16i `echo $1 | tr 'a-f' 'A-F'` pq | dc
}

function bin2hex {
   echo -n 0x
   echo 16o2i `echo $1 | sed 's/^0b//'` pq | dc
}

function hex2dec {
   echo 16i `echo $1 | tr 'a-f' 'A-F'` pq | dc
}

function dec2hex {
   echo -n 0x
   echo 16o $1 pq | dc
}

function dec2bin {
   echo -n 0b
   echo 2o $1 pq | dc
}

function bin2dec {
   echo 2i `echo $1 | sed 's/^0b//'` pq | dc
}

function radix {
   case "$1" in
      0x*)
         hex2bin $1
         hex2dec $1
         ;;
      0b*)
         bin2hex $1
         bin2dec $1
         ;;
      *) 
         dec2hex $1
         dec2bin $1
         ;;
   esac
}
         
