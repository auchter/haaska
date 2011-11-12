[[ -d /opt/plan9 ]] && export PLAN9=/opt/plan9
[[ -d /usr/lib/plan9 ]] && export PLAN9=/usr/lib/plan9

if [[ -d $PLAN9 ]]; then
   export NAMESPACE=/tmp/ns.$USER.$DISPLAY
   export PATH=$PATH:$PLAN9/bin
fi
