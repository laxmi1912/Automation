resource "null_resource" "configure_vm" {
  depends_on = [azurerm_linux_virtual_machine.vm]
  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.vm.public_ip_address
    user        = "${var.environment}-${var.location}-admin"
    private_key = "${file("~/.ssh/id_rsa")}"
    timeout     = "3m"
  }

  provisioner "file" {
    source      = "../../playbooks/configure_os.yaml"
    destination = "/tmp/configure_os.yaml"
  }

  provisioner "file" {
    source      = "../../playbooks/install_app.yaml"
    destination = "/tmp/install_app.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 15",
      "sudo yum update -y",
      "yum install -y python3 python3-virtualenv python3-pip",
      "python3 -m pip install --upgrade pip",
      "pip3 install -y ansible",
      "ansible-playbook /tmp/configure_os.yaml -e 'ansible_python_interpreter=/usr/bin/python'",
      "ansible-playbook /tmp/install_app.yaml -e 'ansible_python_interpreter=/usr/bin/python'"
    ]
  }
}
