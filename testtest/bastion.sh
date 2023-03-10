#!bin/bash
# Set AWS CLI credentials
aws configure set aws_access_key_id ""
aws configure set aws_secret_access_key ""
aws configure set region "ap-northeast-2"
aws configure set output "json"

curl -LO https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
aws eks update-kubeconfig --region ap-northeast-2 --name iron-eks


