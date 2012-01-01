# Inspired by: http://blog.jerodsanto.net/2010/12/minimally-awesome-todos/

export TODO=$HOME/.todo

function vitodo()
{
   vim $TODO
}

function todo()
{
   if [[ $# == "0" ]]; then
      grep '^+ ' $TODO | sed 's/^+ /• /';
   else
      echo "+ $@" >> $TODO;
   fi
}

function todone()
{
   if [[ $# == "0" ]]; then
      echo argument required;
   else
      sed -i -e "s/^\+ \(.*$*.*\)/- \1/" $TODO
   fi
}
