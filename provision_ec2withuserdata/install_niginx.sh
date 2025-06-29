#!/bin/bash

sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

#enter some html inside the index.html

echo "<h1> hello this is ankit you automated this Love you brother</h1>" > /var/www/html/index.html
