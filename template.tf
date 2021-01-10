resource "local_file" "kube-conf" {
    content     = templatefile("${path.module}/kube-conf.tpl", 
       { certificate-authority = google_container_cluster.primary.master_auth.0.cluster_ca_certificate,
         server_ip             = google_container_cluster.primary.endpoint,
         cluster_name          = google_container_cluster.primary.name,
         cluster_user_name     = var.cluster_user_name,
         cluster_user_password = var.cluster_user_password,
         client_certificate    = google_container_cluster.primary.master_auth.0.client_certificate,
         client_key            = google_container_cluster.primary.master_auth.0.client_key
      })
    filename = "${path.module}/kube-conf"
}
