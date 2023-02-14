# AT HashiStack

A work in progress

## Steps

1. `ansible-playbook playbooks/01_common.yml`
2. `source ~/.bashrc`
3. `ansible-playbook playbooks/02_pki.yml`
4. `ansible-playbook playbooks/03_systemd-resolved.yml`
5. `ansible-playbook playbooks/04_consul.yml`
6. `ansible-playbook playbooks/05_vault.yml`
7. `ansible-playbook playbooks/06_vault.yml --tags unseal`
8. `ansible-playbook playbooks/06_nomad`
