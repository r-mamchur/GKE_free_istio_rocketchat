apiVersion: v1
clusters:
- cluster:
#    insecure-skip-tls-verify: true
    certificate-authority-data: ${certificate-authority}
    server: https://${server_ip}
  name: ${cluster_name}
contexts:
- context:
    cluster: ${cluster_name}
    user: ${cluster_user_name}
  name: ${cluster_user_name}
current-context: ${cluster_user_name}
kind: Config
preferences: {}
users:
- name: ${cluster_user_name} 
  user: 
    password: ${cluster_user_password}
    username: ${cluster_user_name}
    client-certificate-data: ${client_certificate}
    client-key-data: ${client_key}
