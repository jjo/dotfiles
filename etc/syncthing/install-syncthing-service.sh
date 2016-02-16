#!/bin/bash -x
sudo install -m 755 -o root -g root etc_init.d_syncthing /etc/init.d/syncthing
test -f /etc/default/syncthing || sudo install -m 644 -o root -g root etc_default_syncthing /etc/default/syncthing
update-rc.d syncthing defaults
echo "Do: sudo vim /etc/default/syncthing , then do: sudo service syncthing start"
