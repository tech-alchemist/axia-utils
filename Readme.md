## AXIA Infra Utilities

## Prerequisites ##

 - Ubuntu 20 OS with Internet
 - Disk, Mem, CPU as per Node Type


## Install Required Utilities
To install utilities required on all machines. 
```
sudo mkdir /opt/opsdude ; sudo -H chown ${USER}.${USER} /opt/opsdude ; cd /opt/opsdude
git clone https://github.com/tech-alchemist/axia-utils.git ; cd /opt/opsdude/axia-utils
```

## Managing Nodes

To autostart/configure node accordingly

#### Starting Validator Node
```
cd /opt/opsdude/axia-utils && git pull origin master
bash operate/start.validator.sh < testnet | canarynet | mainnet >
```

#### Starting Full Node
```
cd /opt/opsdude/axia-utils && git pull origin master
bash operate/start.node.sh < testnet | canarynet | mainnet >
```

#### Starting Archive Node
```
cd /opt/opsdude/axia-utils && git pull origin master
bash operate/start.archive.sh < testnet | canarynet | mainnet >
```

#### Starting Apps
```
cd /opt/opsdude/axia-utils && git pull origin master
bash operate/start.apps.sh			# Optional Arguments : <BranchName> <true|false> 
```

#### Starting Telemetry
```
cd /opt/opsdude/axia-utils && git pull origin master
bash operate/start.telemetry.sh		# Optional Arguments : <BranchName> <true|false> 
```

#### Starting Wiki
```
cd /opt/opsdude/axia-utils && git pull origin master
bash operate/start.wiki.sh			# Optional Arguments : <BranchName> <true|false> 
```

#### Starting JS Wiki
```
cd /opt/opsdude/axia-utils && git pull origin master
bash operate/start.jswiki.sh		# Optional Arguments : <BranchName> <true|false> 
```


## Proxified Setup | Routing via Nginx

- Have utilities installed:
```
cd /opt/opsdude/axia-utils/ && git pull origin master
```

- Point DOMAIN_NAME to Nginx Server, via respective DNS manager.
- Install nginx by:
```
sudo apt install nginx-extras certbot
sudo systemctl enable nginx
```
- Install SSL cert for mapped DOMAIN_NAME
```
sudo service nginx stop
sudo certbot certonly --standalone -d DOMAIN_NAME
sudo service nginx start
```
- Map domain to backend Proxy IP:Port
```
bash /opt/opsdude/axia-utils/extras/nginx.sh <DOMAIN_NAME> <BACKEND_IP> <BACKEND_PORT>
sudo service nginx restart
```

Example:
```
bash /opt/opsdude/axia-utils/extras/nginx.sh wss.axiacoin.network 192.168.0.100 3002
```


## More Coming Soon..