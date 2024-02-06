# grep all matching mouse pointer ids
str=$(xinput list | grep "G Pro.*pointer" | cut -f2 -d"=" | tr -s ' ' | cut -f1 -d '[' | grep -Eo '[0-9]{1,4}')
if [[ -z "$str" ]]; then
  echo "--> G Pro not found looking for MX Master 3..."
  str=$(xinput list | grep "MX Master 3.*pointer" | cut -f2 -d"=" | tr -s ' ' | cut -f1 -d '[' | grep -Eo '[0-9]{1,4}')
fi

# set ifs to find new lines
IFS=$'
'

# loop pointers and set speed to each one of them
# since we don't know which of them is active
for mouse in $str; do echo "setting mouse with id: $mouse"; xinput set-prop $mouse "libinput Accel Speed" -0.9; done

# don't forget to unset ifs
# since we don't want it to be set to new lines for ever
unset IFS

echo "mouse speed set to 0.4..."
