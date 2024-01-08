#!/bin/bash
sudo hostnamectl set-hostname ${new_hostname} &&
sudo apt-get install -y apt-transport-https software-properties-common wget &&
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add - &&
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list &&
sudo apt-get -y update &&
sudo apt-get -y install grafana &&
sudo /bin/systemctl daemon-reload &&
sudo /bin/systemctl enable grafana-server &&
sudo /bin/systemctl start grafana-server && 
sudo systemctl enable grafana-server.service