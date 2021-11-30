output "external_ip_address" {
  value = yandex_compute_instance.yc-default-vm.network_interface.0.nat_ip_address
}
