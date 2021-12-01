

resource "null_resource" "segment-setup" {
  provisioner "local-exec" {
    command = "python ${path.module}/set_cluster.py -u ${var.url} -d ${var.cluster_id} -p ${var.token} -e ${var.environment}"
  }
}