---
theme: hashitheme.json
author: Chris van Meer
date: AT Computing
paging: Innovation Day - HashiCorp
---

# HashiStack Components

Explained in a basic way

## Consul

Phone book / Yellow pages + connection hub

## Vault

Keeps your secrets secret

## Nomad

Runs and maintains the state of your apps

---

# playbooks/01_common.yml

- Creates a directory on `desktop` to store tokens (for demo only)
- Installs basic packages
  - `atop`, `curl`, `jq`, `tree`, `vim`
- Adds HashiCorp repository to package manager
  - Installs `consul`, `vault`, `nomad`, `boundary`
  - Adds `-autocomplete-install`
- Installs pip modules
  - `cryptography`, `docker`, `hvac`, `python-nomad`

---

# playbooks/02_systemd_resolved.yml

- Installs `systemd-resolved` package
- Creates a custom configuration file for the domain `inthepicture.photo`
- Points the `/etc/resolv.conf` file to the stub resolver

---

# playbooks/03_consul.yml

- Creates `data` `log` and `tls` directories
- Creates Consul CA (`consul ca tls create`)
  - Creates server and client certificates (`consul tls cert create`)
  - Distributes certificates
- Creates an encryption key (`consul keygen`)
- Creates config file and systemd unit
- Bootraps Consul (`consul acl bootstrap`)
  - Creates Consul policies for Consul agents and DNS requests
- Installs CNI plugin on Docker hosts
- Creates a scheduled backup job (`consul operator snapshot`)
- Disables Consul from unattended-upgrades (Debian only)

---

# playbooks/04_vault.yml

- Creates `data` `log` and `tls` directories
- Creates config file and systemd unit
- Creates a Root CA (`openssl`)
  - Distributes CA certificate to all machines (trust store)
- Creates an Intermediate CA (`vault pki`)
  - Distributes chain to all machines (trust store)
- Creates Consul policy for Vault
  - Creates token and fills `vault.hcl` config file
- Initializes and unseals Vault
- Creates a raft cluster
- Creates admin user
  - Revokes initial root token
- Creates custom logrotate for Vault log file
- Enables auditing to both syslog and file
- Creates a scheduled backup job (`vault operator raft snapshot`)
- Disables Vault from unattended-upgrades (Debian only)

---

# playbooks/05_nomad.yml

- Creates `data` `log` and `tls` directories
- Retrieves server and client certificates from Vault Intermediate (`http` + `rpc`)
- Encrypts gossip (`serf`) traffic (`nomad operator gossip keyring generate`)
- Creates config file and systemd unit
- Creates Consul policies for Nomad
  - Creates token and fills `nomad.hcl` config file
- Bootraps Nomad (`nomad acl bootstrap`)
  - Creates "ops" token
- Writes policy to Vault for Nomad servers
  - Creates token and fills `vault.hcl` config file (in `nomad.d`)
- Creates a scheduled backup job (`nomad operator snapshot`)
- Disables Nomad from unattended-upgrades (Debian only)

---

# ./aperture.sh

## Generic

- Reads Stack servers and clients from `ansible-inventory`
- Reads credentials from local stored tokens

## Consul

- Port test on tcp/8500 (`netcat`)
- Check registration for Consul clients (`consul members`)
- Checks the number of Vault and Nomad services registered (`curl`)

---

# ./aperture.sh (continued)

## Vault

- Port test on tcp/8200 (`netcat`)
- Checks for initialized and unsealed servers
- Creates a kv-v2 secrets engine and populates a secret (`curl`)
  - Reads the secret from Vault (`curl`)

## Nomad

- Port test on tcp/4646 (`netcat`)
- Checks number of Nomad servers and clients (`curl`)
- Starts a test job and retrieves the output (`curl`)

---

# Thank you
