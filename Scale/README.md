# Prerequisite before running Terraform script:

Provide the required input in variables.tf with the instance id of python application server.

Provide the host address of server where you want to run the ansible playbook in the hosts file

Command to run the playbook:

[If using key based authentication]

ansible-playbook -i hosts scale.yml -u "username" --private-key="private_key_path"

[If using password password authentication]

ansible-playbook -i hosts scale.yml -u "username" -k
