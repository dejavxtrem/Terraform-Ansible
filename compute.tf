#instance data from aws
data "aws_ami" "ec2_server_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Random Id resource generator
resource "random_id" "terraforminsance_node_id" {
  byte_length = 2
  count       = var.main_instance_count
}


#generat key pair for ec2
resource "aws_key_pair" "demo_key_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}


#server instance 
resource "aws_instance" "terraformansible_main" {
  count                  = var.main_instance_count
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.ec2_server_ami.id
  key_name               = aws_key_pair.demo_key_auth.id
  vpc_security_group_ids = [aws_security_group.terraforansible_securitygroup.id]
  subnet_id              = aws_subnet.terraformansible_pub_subnet[count.index].id
  #   user_data              = templatefile("./userdata.tpl", { new_hostname = "terraform_ansible_main-${random_id.terraforminsance_node_id[count.index].dec}" })
  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name = "terraform_ansible_main-${random_id.terraforminsance_node_id[count.index].dec}"
  }

  provisioner "local-exec" {
    command = "printf '\n${self.public_ip}' >> aws_hosts && aws ec2 wait instance-status-ok --instance-ids ${self.id} --region us-east-2"
  }

  #remove ip address from aws_host when destroyed
  #   provisioner "local-exec" {
  #     when    = destroy
  #     command = "sed -i '/^[0-9]/d' aws_hosts"
  #   }
}

# the null resource will wait untill all ec2 instance are created 
resource "null_resource" "grafana_install" {
  depends_on = [aws_instance.terraformansible_main]
  provisioner "local-exec" {
    command = "ansible-playbook -i  aws_hosts --key-file ${var.private_key_path} --user ubuntu playbooks/grafana.yml --ssh-common-args '-o StrictHostKeyChecking=no' "
  }


}


output "instance_ips" {
  value = { for i in aws_instance.terraformansible_main[*] : i.tags.Name => "${i.public_ip}:3000" }
}


# resource "null_resource" "grafana_update" {
#   count = var.main_instance_count
#   provisioner "remote-exec" {
#     inline = ["sudo apt upgrade -y grafana && touch upgrade.log && echo 'I updated Grafana' >> upgrade.log"]
#   }

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = file(var.private_key_path)
#     host        = aws_instance.terraformansible_main[count.index].public_ip
#   }
# }

