import yaml
import sys

def get_cluster_settings():
    with open('/vagrant/cluster/settings.yaml', 'r') as stream:
        try:
            data = yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"yaml error {e}")
            exit(123)
    
    return data

def get_global_settings():
    with open('/vagrant/global/global_settings.yaml', 'r') as stream:
        try:
            data = yaml.safe_load(stream)
        except yaml.YAMLError as e:
            print(f"yaml error {e}")
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

def gen_control_dynamic_vars(cluster_settings, global_settings):
    
    dynamic_ansible_vars = {}
    control_plane_dict = get_control_plane_list(cluster_settings)
    join_url = get_join_url(cluster_settings)

    dynamic_ansible_vars['k3s_join_url'] = join_url
    dynamic_ansible_vars['k3_control_plane_list'] = control_plane_dict

    write_vars_to_file(dynamic_ansible_vars, "control")


def gen_worker_dynamic_vars(cluster_settings, global_settings):

    dynamic_ansible_vars = {}
    control_plane_dict = get_control_plane_list(cluster_settings)
    join_url = get_join_url(cluster_settings)

    dynamic_ansible_vars['k3s_join_url'] = join_url
    dynamic_ansible_vars['k3s_control_plane_list'] = control_plane_dict

    write_vars_to_file(dynamic_ansible_vars, "worker")

if __name__=="__main__":

    node_type = sys.argv[1]

    cluster_settings = get_cluster_settings()
    global_settings = get_global_settings()

    if node_type == "control":
        gen_control_dynamic_vars(cluster_settings, global_settings)

    else:
        gen_worker_dynamic_vars(cluster_settings, global_settings)

    exit(0)
