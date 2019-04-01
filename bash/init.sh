#!/usr/bin/env bash
sudo apt-get update
sudo apt-get upgrade

sudo apt-get install software-properties-common -y
sudo apt install curl -y
sudo apt install -y build-essential libssl-dev tmux libssl-dev zlib1g-dev libbz2-dev libreadline-dev llvm libpq-dev libjpeg-dev
sudo apt install -y libxml2-dev libxslt1-dev zlib1g-dev libffi-dev libssl-dev
sudo apt-get clean
