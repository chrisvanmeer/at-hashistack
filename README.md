# AT HashiStack

A work in progress

## Steps

1. `ansible-playbook playbooks/01_common.yml`
2. `ansible-playbook playbooks/02_systemd-resolved.yml`
3. `ansible-playbook playbooks/03_consul.yml`
4. Open Firefox and navigate to <http://consul.service.inthepicture.photo:8500>  
   This is handy to monitor the vault and nomad services while deploying.
5. `ansible-playbook playbooks/04_vault.yml`
6. `ansible-playbook playbooks/04_vault.yml --tags unseal`
7. `source ~/.bashrc`
8. `ansible-playbook playbooks/05_nomad`
9. Run the aperture script to make sure everything is up and running: `./aperture.sh`

## URL's

- <http://consul.service.inthepicture.photo:8500>
- <http://active.vault.service.inthepicture.photo:8200>
- <http://nomad.service.inthepicture.photo:4646>