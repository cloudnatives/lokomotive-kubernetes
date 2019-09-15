module "bootkube" {
  source = "git::https://github.com/kinvolk/terraform-render-bootkube//?ref=7e237ffa21fd85f76ddf2a215073aa7cd6ef2476"

  cluster_name = "${var.cluster_name}"

  # Cannot use cyclic dependencies on controllers or their DNS records
  api_servers          = ["${data.template_file.controllernames.0.rendered}"]
  api_servers_external = "${libvirt_domain.controller-machine.*.network_interface.0.addresses.0}"
  api_servers_ips      = "${libvirt_domain.controller-machine.*.network_interface.0.addresses.0}"
  etcd_servers         = ["${data.template_file.controllernames.*.rendered}"]
  asset_dir            = "${var.asset_dir}"
  networking           = "${var.networking}"
  network_mtu          = "${var.network_mtu}"

  network_ip_autodetection_method = "${var.network_ip_autodetection_method}"

  pod_cidr              = "${var.pod_cidr}"
  service_cidr          = "${var.service_cidr}"
  cluster_domain_suffix = "${var.cluster_domain_suffix}"
  enable_reporting      = "${var.enable_reporting}"
  enable_aggregation    = "${var.enable_aggregation}"
}

data "template_file" "controllernames" {
  count    = "${var.controller_count}"
  template = "$${cluster_name}-controller-$${index}.$${machine_domain}"

  vars {
    index          = "${count.index}"
    cluster_name   = "${var.cluster_name}"
    machine_domain = "${var.machine_domain}"
  }
}