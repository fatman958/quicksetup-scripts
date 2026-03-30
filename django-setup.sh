sudo apt update
sudo apt upgrade -y

sudo apt install python3-pip -y
sudo pip3 install django
sudo pip3 install djangorestframework
sudo pip3 install django-cors-headers
sudo pip3 install requests
sudo pip3 install channels

mkdir -p ~/django
cd ~/django

input "What is the project name? " -n 1 -r
django-admin startproject $REPLY

input "Do you want a app? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    django-admin startapp $REPLY
fi



input "Do you want to setup and install ssh? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dependencies..."
    sudo apt install openssh-server -y
    sudo systemctl enable ssh
    sudo systemctl start ssh
else
    echo "Skipping."
fi


