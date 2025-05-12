locals {
  ingress_ports = ["22", "80", "443", "3000", "9090"]
}

resource "aws_security_group" "monitoring-sg" {
  name   = var.sg-name
  vpc_id = var.vpc_id

  tags = {
    Name = var.sg-name
  }
}

resource "aws_vpc_security_group_ingress_rule" "monitoring-sg-ingress" {
  for_each          = toset(local.ingress_ports)
  security_group_id = aws_security_group.monitoring-sg.id
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "monitoring-sg-egress" {
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.monitoring-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  # -1 means all protocols
}

resource "aws_instance" "monitoring-ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.monitoring-sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Create prometheus user
    sudo useradd --system --no-create-home --shell /bin/false prometheus

    # Install Prometheus
    wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz
    tar -xvf prometheus-2.47.1.linux-amd64.tar.gz
    cd prometheus-2.47.1.linux-amd64
    sudo mkdir -p /data /etc/prometheus
    sudo mv prometheus promtool /usr/local/bin/
    sudo mv consoles/ console_libraries/ /etc/prometheus/
    sudo mv prometheus.yml /etc/prometheus/prometheus.yml

    # Create Prometheus systemd service
    cat <<EOP | sudo tee /etc/systemd/system/prometheus.service
    [Unit]
    Description=Prometheus
    Wants=network-online.target
    After=network-online.target

    StartLimitIntervalSec=500
    StartLimitBurst=5

    [Service]
    User=prometheus
    Group=prometheus
    Type=simple
    Restart=on-failure
    RestartSec=5s
    ExecStart=/usr/local/bin/prometheus \\
      --config.file=/etc/prometheus/prometheus.yml \\
      --storage.tsdb.path=/data \\
      --web.console.templates=/etc/prometheus/consoles \\
      --web.console.libraries=/etc/prometheus/console_libraries \\
      --web.listen-address=0.0.0.0:9090 \\
      --web.enable-lifecycle

    [Install]
    WantedBy=multi-user.target
    EOP

    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable prometheus
    sudo systemctl start prometheus

    # Create node_exporter user
    sudo useradd --system --no-create-home --shell /bin/false node_exporter

    # Install node_exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
    tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
    sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
    rm -rf node_exporter*

    # Create Node Exporter systemd service
    cat <<EON | sudo tee /etc/systemd/system/node_exporter.service
    [Unit]
    Description=Node Exporter
    Wants=network-online.target
    After=network-online.target

    StartLimitIntervalSec=500
    StartLimitBurst=5

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    Restart=on-failure
    RestartSec=5s
    ExecStart=/usr/local/bin/node_exporter --collector.logind

    [Install]
    WantedBy=multi-user.target
    EON

    sudo systemctl daemon-reload
    sudo systemctl enable node_exporter
    sudo systemctl start node_exporter

    # Install Grafana
    sudo apt-get update
    sudo apt-get install -y apt-transport-https software-properties-common wget gnupg2

    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

    sudo apt-get update
    sudo apt-get -y install grafana
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server

  EOF

  tags = {
    Name = var.ec2_name
  }
}
