import yaml

print("getting needed settings from yaml settings")

dynamic_ansible_vars = {}

with open('/vagrant/cluster/settings.yaml', 'r') as stream:
    try:
        data = yaml.safe_load(stream)
    except yaml.YAMLError as e:
        print(f"yaml error {e}")
        exit(123)

dynamic_ansible_vars['k3s_bind_address'] = data['machine_settings']['ip']

with open('/etc/ansible/vars/dynamic/vars-dynamic.yml', 'w') as outfile:
    yaml.dump(dynamic_ansible_vars, outfile, default_flow_style=False)

exit(0)

