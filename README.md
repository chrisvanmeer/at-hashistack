# AT HashiStack

A complete stack of HashiCorp Consul, Vault and Nomad.  
Created for the AT Computing CloudLabs.

## Presentation

In the directory **slides** you will find the CLI slide-deck that accompanies the installation steps.
For this you will need the [slides](https://github.com/maaslalani/slides) software installed.  
In the CloudLabs, `slides` is installed on the management station.  
Also includes is a custom theme, based on certain HashiCorp product colors.  

### Usage

```bash
cd slides
slides presentation.md
```

## Installation steps

1. `ansible-playbook playbooks/01_common.yml`
2. `ansible-playbook playbooks/02_systemd-resolved.yml`
3. `ansible-playbook playbooks/03_consul.yml`
4. Open Firefox and navigate to <https://consul.service.inthepicture.photo:8501>  
   This is convenient to monitor the `vault` and `nomad` services during installation.
5. `ansible-playbook playbooks/04_vault.yml`
6. `ansible-playbook playbooks/04_vault.yml --tags unseal`
7. `ansible-playbook playbooks/05_nomad.yml`
8. Run the aperture script to make sure everything is up and running: `./aperture.sh`

Note that if you want to use any of the binary commands on the management station, be sure to `source ~/.bashrc` after each product installation, since this also sets the correct environment variables.

### Bonus

There is a playbook included as a bonus that configures the Consul and Nomad secrets engine on Vault and enables an `operator` role for both of the secrets engines. This allows for reading dynamic Consul/Nomad ACL tokens.

1. `ansible-playbook playbooks/10_bonus.yml`
2. `vault read consul/creds/operator`
3. `vault read nomad/creds/operator`

## URL's

- <https://consul.service.inthepicture.photo:8501>
- <https://vault.service.inthepicture.photo:8200>
- <https://nomad.service.inthepicture.photo:4646>

Note that Consul, Vault and Nomad are all mTLS secured and that the Consul domain has been set to `inthepicture.photo`. Make sure you take this into consideration when setting your environment variables.

