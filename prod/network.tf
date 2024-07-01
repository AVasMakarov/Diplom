resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-zones" {
  count          = 3
  name           = "subnet-${count.index}"
  zone           = "${var.subnet-zones[count.index]}"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = [ "${var.cidr.prod[count.index]}" ]
}