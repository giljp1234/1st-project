#!bin/bash
#namespace  생성
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

#로그전송할 클러스터 및 리전 설정 밑에 kubectl ~~ 실행시키면 됨 
#ClusterName=<iron-eks>
#RegionName=<ap-northeast-2>
#FluentBitHttpPort='2020'
#FluentBitReadFromHead='Off'
#[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
#[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'

kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=iron-eks \
--from-literal=http.server=off \
--from-literal=http.port=2020 \
--from-literal=read.head=on \
--from-literal=read.tail=off \
--from-literal=logs.region=ap-northeast-2 -n amazon-cloudwatch \

#Fluent Bit 구성 설치
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit-compatible.yaml

#배포검증
kubectl get pods -n amazon-cloudwatch





### log s3에 저장

kubectl annotate serviceaccounts fluent-bit -n amazon-cloudwatch "eks.amazonaws.com/role-arn=arn:aws:logs:ap-northeast-2:107972469409:log-group:/aws/eks/iron-eks/eks-nodes:*"



sudo amazon-linux-extras install -y epel
sudo yum install -y epel-release
curl -L https://toolbelt.treasuredata.com/sh/install-amazon2-td-agent3.sh | sh

#fluentbit 설치
sudo rpm --import https://packages.fluentbit.io/fluentbit.key
sudo yum install -y https://packages.fluentbit.io/amazon/1.7.7/fluentbit-1.7.7-1.x86_64.rpm

##### /etc/td-agent/td-agent.conf 파일을 열고,
##### cloudwatch logs 및 s3 출력 플러그인을 추가해야함 
##### conf 파일에 추가해야하는 내용 

sudo touch /etc/td-agent-bit/td-agent-bit.conf
sudo chmod 666 /etc/td-agent/td-agent.conf

echo '
[OUTPUT]
    Name cloudwatch_logs
    Match *
    region ap-northeast-2
    log_group_name eks_nodes
    log_stream_name eks_nodes
    auto_create_group true

[OUTPUT]
    Name s3
    Match *
    region ap-northeast-2
    bucket soldesk-s3-test
    path logs/container/
    s3_key_format %{path}%{time_slice}_%{index}.%{file_extension}
    time_slice_format %Y%m%d-%H%M%S
    role_arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess ' >> /etc/td-agent/td-agent.conf


echo '
apiVersion: v1 
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [OUTPUT]
        Name s3
        Match *
        region ap-northeast-2
        bucket soldesk-s3-test
        path logs/container/
        s3_key_format %{path}%{time_slice}_%{index}.%{file_extension}
        time_slice_format %Y%m%d-%H%M%S
        role_arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess\' > fluent-bit-config.yaml


kubectl apply -f fluent-bit-config.yaml

sleep 5s





# CloudWatch Logs 확인
aws logs describe-log-streams --log-group-name /aws/containerinsights/iron-eks/application --output table --region ap-northeast-2

# S3 확인
aws s3 ls s3://soldesk-s3-test/logs/container/ --recursive --region ap-northeast-2
