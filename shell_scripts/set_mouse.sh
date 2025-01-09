# grep all matching mouse pointer ids
mouse_one=$(xinput list | grep "G Pro.*pointer" | cut -f2 -d"=" | tr -s ' ' | cut -f1 -d '[' | grep -Eo '[0-9]{1,4}')
mouse_two=$(xinput list | grep "MX Master 3.*pointer" | cut -f2 -d"=" | tr -s ' ' | cut -f1 -d '[' | grep -Eo '[0-9]{1,4}')
mouse_three=$(xinput list | grep "Logitech USB Receiver Mouse.*pointer" | cut -f2 -d"=" | tr -s ' ' | cut -f1 -d '[' | grep -Eo '[0-9]{1,4}')

# set ifs to find new lines
IFS=$'
'

if [[ -z "$mouse_one" ]]; then
  echo "--> G Pro not found..."
else
  echo "--> G Pro found..."
  for mouse in $mouse_one; do echo -e "\t--> G Pro with id: $mouse"; xinput set-prop $mouse "libinput Accel Speed" -1; done
fi
if [[ -z "$mouse_two" ]]; then
  echo "--> MX Master 3 not found..."
else
  echo "--> MX Master 3 found..."
  for mouse in $mouse_two; do echo -e "\t--> MX Master 3 with id: $mouse"; xinput set-prop $mouse "libinput Accel Speed" -0.9; done
fi
if [[ -z "$mouse_three" ]]; then
  echo "--> MX Master 3 not found..."
else
  echo "--> MX Master 3s found..."
  for mouse in $mouse_three; do echo -e "\t--> MX Master 3s with id: $mouse"; xinput set-prop $mouse "libinput Accel Speed" -0.8; done
fi
# loop pointers and set speed to each one of them
# since we don't know which of them is active

# don't forget to unset ifs
# since we don't want it to be set to new lines for ever
unset IFS

echo "--> mouse speed lowered..."
