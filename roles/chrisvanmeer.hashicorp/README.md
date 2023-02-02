# ansible-role-hashicorp

An ansible role to install the following HashiCorp products:

- Boundary
- Consul
- Nomad
- Packer
- Terraform
- Vagrant
- Vault
- Waypoint

No configuration on the products is done.  
This is just a vanilla install through the distribution's package manager.

## Requirements

No special requirements.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml)`:

```yaml
hashicorp_product_selection:
  - boundary
  - consul
  - nomad
  - packer
  - terraform
  - vagrant
  - vault
  - waypoint
```

Allows for a selection of products to be installed. Defaults to the whole suite.

## Dependencies

No dependencies.

## Installation

Install this role with the following command:

```bash
ansible-galaxy install chrisvanmeer.hashicorp
```

## Example Playbook

```yaml
- hosts: servers
  become: true

  vars:
    hashicorp_product_selection:
      - boundary
      - consul
      - nomad
      - packer
      - terraform
      - vagrant
      - vault
      - waypoint

  roles:
    - role: chrisvanmeer.hashicorp
```

## License

MIT
