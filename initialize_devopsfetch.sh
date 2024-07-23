#!/bin/bash

# Install dependencies
sudo apt update
sudo apt install -y iproute2 docker.io nginx

# Create the devopsfetch script
cat << 'EOF' > /usr/local/bin/devopsfetch
#!/bin/bash

show_help() {
    cat << HELP
Usage: ${0##*/} [-h] [-p [port_number]] [-d [container_name]] [-n [domain]] [-u [username]] [-t [date_range]]
Retrieve and display system information.

    -h, --help              Display this help and exit.
    -p, --port [port_number]Display all active ports and services, or detailed information about a specific port.
    -d, --docker [name]     List all Docker images and containers, or detailed information about a specific container.
    -n, --nginx [domain]    Display all Nginx domains and their ports, or detailed configuration information for a specific domain.
    -u, --users [username]  List all users and their last login times, or detailed information about a specific user.
    -t, --time [date_range] Display activities within a specified date range (YYYY-MM-DD or YYYY-MM-DD YYYY-MM-DD).
HELP
}

list_ports() {
    echo -e "Netid\tState\tRecv-Q\tSend-Q\tLocal Address:Port\tPeer Address:Port\tProcess"
    ss -tulnp | awk 'NR>1 {print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}'
}

port_info() {
    local port=$1
    echo -e "Information for Port $port:"
    ss -tulnp | grep ":$port " | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7}'
}

list_docker() {
    echo "Docker Images:"
    docker images
    echo "Docker Containers:"
    docker ps -a
}

docker_info() {
    echo "Information for Docker Container $1:"
    docker inspect $1
}

list_nginx() {
    echo "Nginx Domains and Ports:"
    nginx -T | grep 'server_name\|listen'
}

nginx_info() {
    echo "Configuration for Nginx Domain $1:"
    nginx -T | grep -A 20 "server_name $1"
}

list_users() {
    echo "Users and Last Login Times:"
    lastlog
}

user_info() {
    echo "Information for User $1:"
    lastlog -u $1
}

time_range_activities() {
    local start_date="$1"
    local end_date="$2"
    echo "Activities from $start_date to $end_date:"
    journalctl --since="$start_date" --until="$end_date"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--port)
            if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
                port_info $2
                shift
            else
                list_ports
            fi
            ;;
        -d|--docker)
            if [[ -n "$2" ]]; then
                docker_info $2
                shift
            else
                list_docker
            fi
            ;;
        -n|--nginx)
            if [[ -n "$2" ]]; then
                nginx_info $2
                shift
            else
                list_nginx
            fi
            ;;
        -u|--users)
            if [[ -n "$2" ]]; then
                user_info $2
                shift
            else
                list_users
            fi
            ;;
        -t|--time)
            if [[ -n "$2" ]]; then
                if [[ "$2" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && -z "$3" ]]; then
                    echo "Activities on $2:"
                    time_range_activities "$2" "$2"
                    shift 2
                elif [[ "$2" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && "$3" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                    echo "Activities from $2 to $3:"
                    time_range_activities "$2" "$3"
                    shift 3
                else
                    echo "Invalid date range format. Use YYYY-MM-DD or YYYY-MM-DD YYYY-MM-DD."
                    exit 1
                fi
            else
                echo "Please provide a valid date or date range."
                exit 1
            fi
            ;;
        *)
            echo "Unknown parameter passed: $1"
            show_help
            exit 1
            ;;
    esac
    shift
done
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/devopsfetch

# Create systemd service file
cat << 'EOF' | sudo tee /etc/systemd/system/devopsfetch.service > /dev/null
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch -t "2024-07-22 2024-07-23"
StandardOutput=append:/var/log/devopsfetch.log
StandardError=append:/var/log/devopsfetch.log
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service

# Setup log rotation
cat << 'EOF' | sudo tee /etc/logrotate.d/devopsfetch > /dev/null
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root utmp
    sharedscripts
    postrotate
        systemctl reload devopsfetch.service > /dev/null 2>&1 || true
    endscript
}
EOF

echo "Installation complete. The devopsfetch service is now running and logging to /var/log/devopsfetch.log."
