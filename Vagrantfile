               Vagrant.configure("2") do |config|
                   config.vm.box = "hashicorp/bionic64"
                   config.vm.network "public_network"
                   config.ssh.insert_key = false # 1
                   config.ssh.private_key_path = ['~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa']
                   config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"


                   config.vm.provision "shell", inline: <<-EOC
                     sudo sed -i -e "\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
                     sudo systemctl restart sshd.service
                     echo "finished"
                   EOC

               end
