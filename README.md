# DevOpsFetch 🚀

DevOpsFetch is a powerful tool for DevOps professionals to collect and display system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses. It also implements a systemd service for continuous monitoring and logging of these activities.

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Configuration](#️-configuration)
- [Usage](#-usage)
- [Logging](#-logging)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

- Display active ports and services
- List Docker images and containers
- Show Nginx domains and configurations
- View user login information
- Monitor system activities within specified time ranges
- Continuous monitoring with systemd service
- Automated log rotation

## 🛠 Installation

1. Clone the repository:
    ```bash
   git clone https://github.com/mroluwasesan/devopsfetch.git
   cd devopsfetch
2. Run the installation script:
    ```bash
   sudo bash initialize_main.sh

This script will:

- Install necessary dependencies (iproute2, docker.io, nginx)
- Create the devopsfetch script in /usr/local/bin/
- Set up a systemd service for continuous monitoring
- Configure log rotation

## ⚙️ Configuration
The devopsfetch tool is configured during installation. The systemd service is set to monitor activities from the current date. If you need to modify the date range or other settings, edit the systemd service file:

    
    sudo nano /etc/systemd/system/devopsfetch.service
   
After making changes, reload the systemd daemon and restart the service:

    
    sudo systemctl daemon-reload
    sudo systemctl restart devopsfetch.service

## 🖥 Usage

DevOpsFetch can be used with various command-line flags:

Usage: devopsfetch [-h] [-p [port_number]] [-d [container_name]] [-n [domain]] [-u [username]] [-t [date_range]]

Examples
1. Display help:

    ```bash
    devopsfetch -h

2. List all active ports:

    ```bash
    devopsfetch -p

3. Get information about a specific port:

    ```bash
    devopsfetch -p 80

4. List all Docker containers:

    ```bash
    devopsfetch -d


5. Get information about a specific Docker container:

    ```bash
    devopsfetch -d mycontainer

6. List all Nginx domains:

    ```bash
    devopsfetch -n

7. Get configuration for a specific Nginx domain:

    ```bash
    devopsfetch -n example.com

8. List all users and their last login times:

    ```bash
    devopsfetch -u

9. Get information about a specific user:

    ```bash
    devopsfetch -u johndoe

10. Display activities within a date range:

    ```bash
    devopsfetch -t "2024-07-22 2024-07-23"

## 📊 Logging
DevOpsFetch logs its activities to /var/log/devopsfetch.log. Log rotation is configured to manage the log file size and retention.
To view the logs:

    ```bash
    sudo tail -f /var/log/devopsfetch.log

Log rotation settings can be modified in /etc/logrotate.d/devopsfetch.
## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.