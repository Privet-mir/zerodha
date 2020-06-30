#!/bin/bash


print_help () {
           echo "Please provide arguments"
           echo "./main.sh start"
           echo "provision vagrant with ubuntu 18.04"
           echo "./main.sh stop"
           echo "destroy vagrant"
           echo "./main.sh k8s"
           echo "run example on k8s"
           echo "./main.sh k8sremove"
           echo "to delete k8s deployment"

}

vagrant_start () {
        ## Here Doc
        echo "Creatin Vagrantfile"
        cat <<EOF >Vagrantfile
               Vagrant.configure("2") do |config|
                   config.vm.box = "hashicorp/bionic64"
                   config.vm.network "public_network"
                   config.ssh.insert_key = false # 1
                   config.ssh.private_key_path = ['~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa']
                   config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"


                   config.vm.provision "shell", inline: <<-EOC
                     sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
                     sudo systemctl restart sshd.service
                     echo "finished"
                   EOC

               end
EOF
       echo "Vagrantfile creation done"
       echo "Bringing up Ubuntu VM"
       echo "Note when prompt to select Network Interface Select the interface to which internet is connected"
       vagrant up
       ip=$(vagrant ssh -c "hostname -I" | cut -d' ' -f2)
       echo "Vagrant machine IP $ip"
       cat <<EOF >./ansible-playbook/inventory
       [vagrant]
       $ip ansible_python_interpreter=/usr/bin/python3   ansible_user=vagrant
EOF
       echo "created inventory file"
       echo "Run ansible playbook to configure ubuntu and install docker"
       ansible-playbook -i ./ansible-playbook/inventory ./ansible-playbook/config.yml
}

vagrant_stop () {
           vagrant destroy
           rm Vagrantfile

}


status_check () {
     echo "Pod status Check $POD"
     POD1=$(kubectl get pods --namespace demo-ops -l "app=$POD" -o jsonpath="{.items[0].metadata.name}")
     STATUS=$(kubectl get pods -n demo-ops $POD1  -o  jsonpath="{.status.phase}")
     echo $STATUS
     while [ "$STATUS" != "Running" ]
         do
                  REDIS=$(kubectl get pods --namespace demo-ops -l "app=$POD" -o jsonpath="{.items[0].metadata.name}")
                  STATUS=$(kubectl get pods -n demo-ops $POD1  -o  jsonpath="{.status.phase}")
                  echo $STATUS
         done

}

k8s_app () {
    echo "Creating namespace demo-ops"
    kubectl apply -f k8s/ns.yml
    echo "Deploying redis pod"
    kubectl apply -f k8s/redis.yml
    echo "Sleeping for 10s"
    sleep 10
    echo "Checking Redis POD status"
    POD=redis
    status_check $POD
    echo "Deploying go-app"
    kubectl apply -f k8s/go-app.yml
    POD=go-app
    status_check $POD
    if [ -x "$(minikube version)" ]; then
         echo "minikube is not install"
         echo "Use kubectl port-forward service/go-app-service 8000:8000 "
         echo "curl localhost:8000"

    else
        k8s_ip=$(minikube ip)
        NP=$(kubectl get service go-app-service -n demo-ops -o json | jq .spec.ports[].nodePort)
        sleep 10
        for i in i $(seq 1 5)
             do
                 echo "$i"
                 curl $k8s_ip:$NP
         done
    fi
}

k8s_remove () {
       kubectl delete -f k8s/go-app.yml
       kubectl delete -f k8s/redis.yml
       kubectl delete -f k8s/ns.yml
}


if [ -x "$(vagrant --version)" ]; then

        echo "Please install vagrant to run this script"
        exit 0
    else
        echo $(vagrant --version)
        print_help
fi



if [ "start" == "$1" ];then
    vagrant_start
elif [ "stop" == "$1" ];then
    vagrant_stop
elif [ "k8s" == "$1" ];then
    k8s_app
elif [ "k8sremove" == "$1" ]; then
    k8s_remove
elif [ "$#" -eq 0 ];then
    print_help
fi

