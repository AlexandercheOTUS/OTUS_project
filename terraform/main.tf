provider "yandex" {
  version = 0.35
  token   = var.token
  # service_account_key_file = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_compute_instance" "yc-default-vm" {
  name = var.vm_name

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      # yc compute image list --folder-id standard-images | grep ubuntu-1804-lts
      image_id = var.image_id
      size     = 15
    }
  }

  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }

  connection {
    type  = "ssh"
    host  = yandex_compute_instance.yc-default-vm.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "local-exec" {
    command = "docker-machine create --driver generic --generic-ip-address=${yandex_compute_instance.yc-default-vm.network_interface.0.nat_ip_address} --generic-ssh-user ubuntu --generic-ssh-key ${var.private_key_path} ${var.vm_name} && docker-machine ls"
    # после этого eval $(docker-machine env vm_name)
  }

}
