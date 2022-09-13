#!/bin/bash
sudo apt update -y && sudo apt install -y docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu
docker run -p 8080:80 nginx