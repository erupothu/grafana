

#### Install Grafana
sudo apt install -y gnupg2 curl software-properties-common 
curl -fsSL https://packages.grafana.com/gpg.key|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/grafana.gpg 

sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main" 

sudo apt -y install grafana 
sudo systemctl enable --now grafana-server 

http://localhost:3000


Grafana Package details: 
Installs binary to /usr/sbin/grafana-server 
Installs Init.d script to /etc/init.d/grafana-server 
Creates default file (environment vars) to /etc/default/grafana-server 
Installs configuration file to /etc/grafana/grafana.ini 
Installs systemd service (if systemd is available) name grafana-server.service 
The default configuration sets the log file at /var/log/grafana/grafana.log 
The default configuration specifies a sqlite3 db at /var/lib/grafana/grafana.db 
Installs HTML/JS/CSS and other Grafana files at /usr/share/grafana 

#### Install Prometheus

sudo groupadd --system prometheus 
sudo useradd -s /sbin/nologin --system -g prometheus prometheus 
sudo mkdir /var/lib/prometheus  
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i}; done 
mkdir -p /tmp/prometheus && cd /tmp/prometheus 
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi - 
tar xvf prometheus*.tar.gz 
cd prometheus*/ 
sudo mv prometheus promtool /usr/local/bin/ 
prometheus --version 
promtool --version

sudo mv prometheus.yml /etc/prometheus/prometheus.yml 
sudo mv consoles/ console_libraries/ /etc/prometheus/

```vim
sudo tee /etc/systemd/system/prometheus.service<<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

sudo systemctl daemon-reload 
sudo systemctl start prometheus 
sudo systemctl enable prometheus 

http://localhost:9090
