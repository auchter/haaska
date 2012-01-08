[[ -d /opt/plan9 ]] && export PLAN9=/opt/plan9
[[ -d /usr/lib/plan9 ]] && export PLAN9=/usr/lib/plan9

if [[ -d $PLAN9 ]]; then
   export NAMESPACE=/tmp/ns.$USER.`hostname`
   export PATH=$PATH:$PLAN9/bin

   [[ ! -d $NAMESPACE ]] && mkdir $NAMESPACE

   9p read plumb/rules >/dev/null 2>/dev/null
   [[ $? -ne 0 ]] && plumber 2>/dev/null

   # first rule wins, so make sure files are named in proper order
   cat $ZSH/plan9/*.plumbing $PLAN9/plumb/initial.plumbing | 9p write plumb/rules >/dev/null

fi
