# AT HashiStack

A work in progress

## Steps

1. `ansible-playbook playbooks/01_common.yml`
2. `source ~/.bashrc`
3. `ansible-playbook playbooks/02_systemd-resolved.yml`
4. `ansible-playbook playbooks/03_consul.yml`
5. `ansible-playbook playbooks/04_vault.yml`
6. `ansible-playbook playbooks/04_vault.yml --tags unseal`
7. `ansible-playbook playbooks/05_nomad`
