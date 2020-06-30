# Zerodha Ops Interview Task

## prerequisite
1. VirtualBox (https://www.virtualbox.org/)
2. Vagrant (https://vagrant.io)
3. jq (sudo apt-get install jq | brew install jq)
4. minikube (https://kubernetes.io/docs/tasks/tools/install-minikube/)
5. ansible (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Task
- [x] Create a `Dockerfile` for the app
- [x] Create a `docker-compose.yml` for the app 
- [x] Write a bash script that creates and boots [Vagrant box](https://vagrant.io) with Ubuntu.
- [x] Using Ansible provision the VM to
  * Setup hostname of VM as `demo-ops`
  * Create a user `demo`
  * Configure `sysctl` for sane defaults. For eg: increasing open files limit. Configure a variety of `sysctl` settings to make the VM a production grade one.
  * Set the system's timezone to "Asia/Kolkata"
  * Install Docker and Docker-Compose
  * Configure Docker Daemon to have sane defaults. For eg: to keep logs size in check.
  * Deploy the `docker-compose.yml` in `/etc/demo-ops` and start the services

Make sure you have ssh key located at ~/.ssh/ as vagrant will pick key from there to configure ubuntu machine.

#### Steps
1. ``` chmod +x main.sh ```
2. Deploy Vagrant ubuntu machine and configure it using ansbile.

    ``` ./main.sh start```

    When prompt select network interface to which internet is connected


3. Once deployment is done you can see logs printed on terminal perfoming health check.


   you can also verify manually by running following command

    ``` vagrant ssh -c "curl localhost:8000" ```

4. To destroy VM simply run follwoing command

    ``` ./main.sh stop ```


#### Bonus
1. To deploy over k8s run follwoing command

    ``` ./main.sh k8s  ```

    it will create deployment from mainifest file located in **k8s directory**. the script will first create Namespace then deploy redis app, **while loop** have been placed in script for pod **status check** it will run until pod status is RUNNING once condition is met loop will break and script will deploy go-app same will be done for **go-app pod**. once deployment is completed script will fetch minikube IP and run  ```curl IP:NodePort``` to check requests are served from pod.  

2. delete deployments

    ``` ./main.sh k8sremove ```

#### Help
``` ./main.sh ```


#### Refrences
https://docs.ansible.com/ansible
https://www.vagrantup.com/docs
https://kubernetes.io/docs/home/

