ACMD1WRKSHP_REPO="https://github.com/nikhilgoenkatech/ACMD1Workshops.git"
ACMD1WRKSHP_DIR="~/ACMD1Workshop"

dockerInstall() {
  if [ "$docker_install" = true ]; then
    printInfoSection "Installing Docker and J Query"
    printInfo "Install J Query"
    apt install jq -y
    printInfo "Install Docker"
    apt install docker.io -y
    service docker start
    usermod -a -G docker $USER
  fi
}

setBashas() {
  # Wrapper for runnig commands for the real owner and not as root
  alias bashas="sudo -H -u ${USER} bash -c"
  # Expand aliases for non-interactive shell
  shopt -s expand_aliases
}
timestamp() {
  date +"[%Y-%m-%d %H:%M:%S]"
}
printInfo() {
  echo "[install-prerequisites|INFO] $(timestamp) |>->-> $1 <-<-<|"
}

printInfoSection() {
  echo "[install-prerequisites|INFO] $(timestamp) |$thickline"
  echo "[install-prerequisites|INFO] $(timestamp) |$halfline $1 $halfline"
  echo "[install-prerequisites|INFO] $(timestamp) |$thinline"
}

printError() {
  echo "[install-prerequisites|ERROR] $(timestamp) |x-x-> $1 <-x-x|"
}

# ======================================================================
#          ----- Installation Functions -------                        #
# The functions for installing the different modules and capabilities. #
# Some functions depend on each other, for understanding the order of  #
# execution see the function doInstallation() defined at the bottom    #
# ======================================================================
updateUbuntu() {
  if [ "$update_ubuntu" = true ]; then
    printInfoSection "Updating Ubuntu apt registry"
    apt update
  fi
}

setupProAliases() {
  if [ "$setup_proaliases" = true ]; then
    printInfoSection "Adding Bash and Kubectl Pro CLI aliases to .bash_aliases for user ubuntu and root "
    echo "
      # Alias for ease of use of the CLI
      alias las='ls -las'
      alias hg='history | grep'
      alias h='history'
      alias vaml='vi -c \"set syntax:yaml\" -'
      alias vson='vi -c \"set syntax:json\" -'
      alias pg='ps -aux | grep' " >/root/.bash_aliases
    homedir=$(eval echo ~$USER)
    cp /root/.bash_aliases $homedir/.bash_aliases
  fi
}

dynatraceActiveGateInstall() {
  if [ "$dynatrace_activegate_install" = true ]; then
    printInfoSection "Installation of Active Gate"
    wget -nv -O activegate.sh "https://$DT_TENANT/api/v1/deployment/installer/gateway/unix/latest?Api-Token=$DT_PAAS_TOKEN&arch=x86&flavor=default"
    sh activegate.sh
    printInfo "removing ActiveGate installer."
    rm activegate.sh
  fi
}

downloadApacheJmeter() {
  if [ "$download_Jmeter" = true ]; then
    printInfoSection "Installation of Apache JMeter"
    bashas "sudo apt-get install openjdk-8-jre-headless -y"
    wget -nv -q -O /home/ubuntu/apache-jmeter.zip "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.2.1.zip"
    bashas "cd /home/ubuntu/"
    bashas "sudo apt-get install unzip -y"
    bashas "sudo unzip /home/ubuntu/apache-jmeter.zip" 
    printInfo "Apache Jmeter has been downloaded at /home/ubuntu/apache-jmeter-5.2.1 directory."
  fi
}

downloadApacheJmeterScripts() {
  if [ "$download_JmeterScripts" = true ]; then
    printInfoSection "Cloning the ACMD1Workshop repository"
    bashas "cd /home/ubuntu/"
    bashas "sudo git clone https://github.com/nikhilgoenkatech/ACMD1Workshops.git"
    printInfo "Cloned the ACMD1Workshop repository in /home/ubuntu/ directory."
  fi
}

downloadBankSampleApplication(){
  if [ "$install_start_bank_docker" = true ]; then
    printInfoSection "Downloading docker-image for sample bank application"
    bashas "docker pull nikhilgoenka/sample-bank-app"
    bashas "docker run -d --name SampleBankApp -p 4000:3000 nikhilgoenka/sample-bank-app"
    printInfo "Docker SampleBankApp is running on port 4000"
  fi
}
downloadJenkinsDocker(){
  if [ "$download_jenkins_image" = true ]; then
    printInfoSection "Downloading docker-image for Jenkins Workshop" 
    bashas "docker network create -d bridge mynetwork"
    bashas "docker pull nikhilgoenka/jenkins-dynatrace-workshop"
    bashas "sudo mkdir /var/jenkins/" 
    printInfo "Docker Jenkins is now downloaded and available to be executed."
  fi
}

downloadStartAnsibleTower(){
  if [ "$install_start_ansible_tower_docker" = true ]; then
    printInfoSection "Downloading docker-image for ansible tower"
    bashas "docker pull ybalt/ansible-tower"
    bashas "docker run -d --name ansible-tower -p 8090:443 ybalt/ansible-tower"
    printInfo "Docker Ansible-tower is now running on port 8090"
  fi
}
resources_clone(){
  if ["$clone_the_repo" = true]; then
    printInfoSection "Clone ACMD1Workshop Resources in $ACMD1WRKSHP_DIR"
    bashas "sudo git clone $ACMD1WRKSHP_REPO $ACMD1WRKSHP_DIR"
  fi
}

# ======================================================================
#       -------- Function boolean flags ----------                     #
#  Each function flag representas a function and will be evaluated     #
#  before execution.                                                   #
# ======================================================================
# If you add varibles here, dont forget the function definition and the priting in printFlags function.
verbose_mode=false
update_ubuntu=false
docker_install=false
setup_proaliases=false
download_Jmeter=false
download_JmeterScripts=false
install_start_bank_docker=false
download_jenkins_image=false
install_start_ansible_tower_docker=false

installBankCustomerAIOpsWorkshop() {
  update_ubuntu=true
  setup_proaliases=true 
  clone_the_repo=true

  docker_install=true
  dynatrace_install_oneagent=true

  download_Jmeter=true
  download_JmeterScripts=true

  install_start_bank_docker=true
  download_jenkins_image=true

  install_start_ansible_tower_docker=true
}

# ======================================================================
#            ---- The Installation function -----                      #
#  The order of the subfunctions are defined in a sequencial order     #
#  since ones depend on another.                                       #
# ======================================================================
installSetup() {
  echo ""
  printInfoSection "Installing ... "
  echo ""

  echo ""
  setBashas

  updateUbuntu
  setupProAliases

  resources_clone
  dockerInstall
  dynatraceActiveGateInstall

  downloadApacheJmeter
  downloadApacheJmeterScripts 

  downloadBankSampleApplication
  downloadJenkinsDocker
  
  downloadStartAnsibleTower
}

