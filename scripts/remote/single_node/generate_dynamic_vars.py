import yaml

def get_cluster_settings():
    with open('/vagrant/cluster/settings.yaml', 'r') as stream:
        try:
            data = yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"yaml error getting the cluster settings {e}")
            exit(123)
    
    return data

def get_ansible_user_vars():
    with open('/etc/ansible/vars/user/ansible-vars.yml', 'r') as stream:
        try:
            data = yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"yaml error getting the ansible user vars {e}")
            exit(123)

    return data

def is_kubevip_enabled(ansible_user_vars):
    if ansible_user_vars is not None:
        if 'kube_enable_kubevip' in ansible_user_vars.keys():
            if ansible_user_vars['kube_enable_kubevip']:
                return True

    return False

def get_tls_san_ips(cluster_settings, ansible_user_vars, enable_kubevip):
    
    tls_san_ips = []

    if enable_kubevip:
        kubevip_ip = ansible_user_vars['kube_kubevip_ip']
        node_ip = cluster_settings['machine_settings']['ip']

        tls_san_ips.append(kubevip_ip)
        tls_san_ips.append(node_ip)
    
    else:
        node_ip = cluster_settings['machine_settings']['ip']

        tls_san_ips.append(node_ip)

    return tls_san_ips


def write_out_dynamic_vars(dynamic_vars):
    with open('/etc/ansible/vars/dynamic/vars-dynamic.yml', 'w') as outfile:
        yaml.dump(dynamic_vars, outfile, default_flow_style=False)


if __name__=="__main__":

    ansible_dynamic_vars = {}

    print('getting user ansible vars and cluster settings')
    cluster_gettings = get_cluster_settings()
    ansible_users_vars = get_ansible_user_vars()

    print('ansible user vars:')
    print(ansible_users_vars)

    enable_kubevip = is_kubevip_enabled(ansible_users_vars)
    print(f"kubevip state {enable_kubevip}")

    tls_san_ips = get_tls_san_ips(cluster_gettings, ansible_users_vars, enable_kubevip)
    ansible_dynamic_vars['kube_tls_san_addresses'] = tls_san_ips


    print("ansible dynamic vars:")
    print(ansible_dynamic_vars)
    write_out_dynamic_vars(ansible_dynamic_vars)

exit(0)

