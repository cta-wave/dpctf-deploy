echo "Checking permissions ..."

if ! [ -w $1 ]; then
  echo
  echo -e "\e[1;31m"
  echo "=== ERROR ================================================="
  echo "= No write permissions for results directory.             ="
  echo "= Set ownership to 1000:1000 and make directory writable! ="
  echo "==========================================================="
  echo -e "\e[0m"
  echo
  exit 1
fi

if ! [ -r $1 ]; then
  echo
  echo -e "\e[1;31m"
  echo "=== ERROR ================================================="
  echo "= No read permissions for results directory.              ="
  echo "= Set ownership to 1000:1000 and make directory readable! ="
  echo "==========================================================="
  echo -e "\e[0m"
  echo
  exit 1
fi
