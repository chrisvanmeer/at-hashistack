# AT HashiStack

A work in progress

## Steps

1. `ansible-playbook playbooks/01_common.yml`
2. `ansible-playbook playbooks/02_systemd-resolved.yml`
3. `ansible-playbook playbooks/03_consul.yml`
4. Open Firefox and navigate to <https://consul.service.inthepicture.photo:8501>  
   This is handy to monitor the vault and nomad services while deploying.
5. `ansible-playbook playbooks/04_vault.yml`
6. `ansible-playbook playbooks/04_vault.yml --tags unseal`
7. `source ~/.bashrc`
8. `ansible-playbook playbooks/05_nomad`
9. Run the aperture script to make sure everything is up and running: `./aperture.sh`

## URL's

- <https://consul.service.inthepicture.photo:8501>
- <https://vault.service.inthepicture.photo:8200>
- <https://nomad.service.inthepicture.photo:4646>

Note that both Vault and Nomad are mTLS secured
