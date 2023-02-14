# AT HashiStack

A work in progress

## Steps

1. `ansible-playbook playbooks/01_common.yml`
2. `source ~/.bashrc`
3. `ansible-playbook playbooks/02_systemd-resolved.yml`
4. `ansible-playbook playbooks/03_consul.yml`
5. Open Firefox and navigate to <http://consul.service.inthepicture.photo:8500>  
   This is handy to monitor the vault and nomad services while deploying.
6. `ansible-playbook playbooks/04_vault.yml`
7. `ansible-playbook playbooks/04_vault.yml --tags unseal`
8. `ansible-playbook playbooks/05_nomad`
9. Run the aperture script to make sure everything is up and running: `./aperture.sh`

## URL's

- <http://consul.service.inthepicture.photo:8500>
- <http://active.vault.service.inthepicture.photo:8200>
- <http://nomad.service.inthepicture.photo:4646>