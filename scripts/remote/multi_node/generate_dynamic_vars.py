import yaml
import sys

def get_cluster_settings():
    with open('/vagrant/cluster/settings.yaml', 'r') as stream:
        try:
            data = yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"yaml error getting cluster settings {e}")
            exit(123)
    
    return data

def get_global_settings():
    with open('/vagrant/global/global_settings.yaml', 'r') as stream:
        try:
            data = yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"yaml error getting global settings {e}")
            exit(123)

    return data

def get_ansible_user_vars():
    with open('/etc/ansible/vars/user/ansible-vars.yml') as stream:
        try:
            data = yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"yaml error getting ansible user vars {e}")
            exit(123)

    return data


def write_vars_to_file(variable_dict, var_type):
    with open(f"/etc/ansible/vars/dynamic/vars-dynamic-{var_type}.yml", 'w') as outfile:
        yaml.dump(variable_dict, outfile, default_flow_style=False)

def get_control_plane_list(settings):

    control_plane_list = {}

    for node in settings['lead-control-node']:
        node_dict = {
            'primary': 'true',
            'ip': node['ip']
        }

        control_plane_list[node['name']] = node_dict

    for node in settings['control-nodes']:
        node_dict = {
            'primary': 'false',
            'ip': node['ip']
        }

        control_plane_list[node['name']] = node_dict

    return control_plane_list

def get_join_url(settings):

    join_ip = settings['lead-control-node'][0]['ip']
    join_url = f"https://{join_ip}:6443"

    return join_url

def is_kubevip_enabled(ansible_user_vars):
    if ansible_user_vars is not None:
        if 'k3s_enable_kubevip' in ansible_user_vars.keys():
            if ansible_user_vars['k3s_enable_kubevip']:
                return True

    return False

def get_control_nodes_ips(cluster_settings):

    control_node_ips = []

    control_node_ips.append(cluster_settings['lead-control-node'][0]['ip'])

    for node in cluster_settings['control-nodes']:
        control_node_ips.append(node['ip'])

    return control_node_ips

def get_tls_san_ips(cluster_settings, ansible_user_vars, enable_kubevip):
    
    tls_san_ips = []

    control_node_ips = get_control_nodes_ips(cluster_settings)

    if enable_kubevip:
        kubevip_ip = ansible_user_vars['k3s_kubevip_ip']
        tls_san_ips.append(kubevip_ip)

    tls_san_ips.extend(control_node_ips)

    return tls_san_ips

def gen_control_dynamic_vars(cluster_settings, global_settings, ansible_user_vars, enable_kubevip):
    
    dynamic_ansible_vars = {}
    control_plane_dict = get_control_plane_list(cluster_settings)
    join_url = get_join_url(cluster_settings)
    tls_san_ips = get_tls_san_ips(cluster_settings, ansible_user_vars, enable_kubevip)

    dynamic_ansible_vars['k3s_join_url'] = join_url
    dynamic_ansible_vars['k3_control_plane_list'] = control_plane_dict
    dynamic_ansible_vars['k3s_tls_san_addresses'] = tls_san_ips

    print('control node dynamic ansible vars:')
    print(dynamic_ansible_vars)

    write_vars_to_file(dynamic_ansible_vars, "control")


def gen_worker_dynamic_vars(cluster_settings, global_settings):

    dynamic_ansible_vars = {}
    control_plane_dict = get_control_plane_list(cluster_settings)
    join_url = get_join_url(cluster_settings)

    dynamic_ansible_vars['k3s_join_url'] = join_url
    dynamic_ansible_vars['k3s_control_plane_list'] = control_plane_dict

    print('worker node dynamic ansible vars:')
    print(dynamic_ansible_vars)

    write_vars_to_file(dynamic_ansible_vars, "worker")

if __name__=="__main__":

    node_type = sys.argv[1]

    print('getting global and cluster settings and ansible user variables')
    cluster_settings = get_cluster_settings()
    global_settings = get_global_settings()
    ansible_user_vars = get_ansible_user_vars()

    print('')
    print('ansible user vars:')
    print(ansible_user_vars)
    print('')

    enable_kubevip = is_kubevip_enabled(ansible_user_vars)
    print(f"kubevip state {enable_kubevip}")

    if node_type == "control":
        gen_control_dynamic_vars(cluster_settings, global_settings, ansible_user_vars, enable_kubevip)

    else:
        gen_worker_dynamic_vars(cluster_settings, global_settings)

    exit(0)
