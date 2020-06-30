#### Ansible Playbook

```vagrant ssh -c "hostname -I" | cut -d' ' -f2```

paste IP in inventory file
```
[vagrant]
ip
```

```   ansible-playbook -i inventory config.yml ```