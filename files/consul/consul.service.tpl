### BEGIN INIT INFO
# Provides:          consul
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Consul agent
# Description:       Consul service discovery framework
### END INIT INFO

[Unit]
Description=Consul server agent
Requires=network-online.target
After=network-online.target

[Service]
User=consul
Group=consul
PIDFile=/etc/consul.d/consul.pid
PermissionsStartOnly=true
ExecStart=/usr/local/bin/consul agent \
    -config-dir=/etc/consul.d/ \
    -data-dir=/etc/consul.d/ \
    -pid-file=/etc/consul.d/consul.pid
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
