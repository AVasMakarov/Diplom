data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    ssh_public_key = file("~/.ssh/yc.pub")
  }
}

resource "yandex_compute_instance" "cluster-k8s" {
  count   = 3
  name                      = "node${count.index}"
  zone                      = var.subnet-zones[count.index]
  hostname                  = "node${count.index}"
  allow_stopping_for_update = true
  labels = {
    index = count.index
  }

  scheduling_policy {
    preemptible = true  // Прерываемая ВМ
  }

  resources {
    cores  = 8
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = var.ubuntu-2004-lts
      type        = "network-ssd"
      size        = "10"
    }
  }

  network_interface {

    subnet_id  = yandex_vpc_subnet.subnet-zones[count.index].id
    nat        = true
  }

  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = 1
  }
}