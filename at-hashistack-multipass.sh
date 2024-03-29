#!/bin/bash

echo "Creating multipass instances for AT-Hashistack"
multipass launch --name consul1
multipass launch --name consul2
multipass launch --name consul3
multipass launch --name vault1
multipass launch --name vault2
multipass launch --name vault3
multipass launch --name nomad1
multipass launch --name nomad2
multipass launch --name nomad3
multipass launch --name docker1
multipass launch --name docker2
multipass launch --name docker3
multipass launch --name traefik1
multipass launch --name traefik2
multipass launch --name traefik3
multipass launch --name traefik4
multipass launch --name desktop
multipass list

