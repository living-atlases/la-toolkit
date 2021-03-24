#!/bin/bash
colblk='\033[0;30m' # Black - Regular
colred='\033[0;31m' # Red
colgrn='\033[0;32m' # Green
colylw='\033[0;33m' # Yellow
colpur='\033[0;35m' # Purpl
colgre='\033[0;90m' # Grey
colblu='\033[0;34m' # Blue
colrst='\033[0m'    # Text Reset

echo -e ${colblu}"\$ "${colrst}${colgrn}"$@ "${colgre}"### This is the command we've executed"${colrst} ; "$@" ;

RESULT=$?
echo
if [[ $RESULT -eq 0 ]]; then
  echo -e "${colgrn}This command ended correctly${colrst}"
else
  echo -e "${colred}This command ended abnormally (exit code $RESULT)${colrst}"
fi
echo

exit $RESULT
