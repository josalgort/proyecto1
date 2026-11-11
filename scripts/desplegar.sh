#!/bin/bash
# Proyecto 1 · Despliegue del servidor web de Librería Tinta
set -euo pipefail
export AWS_PAGER=""

REGION="us-east-1"
SUBNET_ID="subnet-03dd91e168f17043d"
VPC_ID="vpc-0db2e92608e93cf74"
MI_IP="78.30.6.87/32"
ALUMNO="José Antonio Alguacil"

# 1. AMI más reciente de Amazon Linux 2023
AMI_ID=$(aws ssm get-parameters --region "$REGION" \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query "Parameters[0].Value" --output text)

# 2. Grupo de seguridad
SG_ID=$(aws ec2 create-security-group --region "$REGION" \
  --group-name libreria-web-cli-sg \
  --description "Web Libreria Tinta (CLI)" \
  --vpc-id "$VPC_ID" \
  --query "GroupId" --output text)

# Permitir HTTP (80) desde cualquier origen
aws ec2 authorize-security-group-ingress --region "$REGION" \
  --group-id "$SG_ID" \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

# Permitir SSH (22) únicamente desde nuestra IP
aws ec2 authorize-security-group-ingress --region "$REGION" \
  --group-id "$SG_ID" \
  --protocol tcp --port 22 --cidr "$MI_IP"

# 3. Instancia
INSTANCE_ID=$(aws ec2 run-instances --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type t3.micro \
  --key-name vockey \
  --subnet-id "$SUBNET_ID" \
  --associate-public-ip-address \
  --security-group-ids "$SG_ID" \
  --user-data file://user-data1.sh \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=libreria-web-cli},{Key=Proyecto,Value=P1},{Key=Alumno,Value=$ALUMNO}]" \
  --query "Instances[0].InstanceId" --output text)

echo "Instancia creada: $INSTANCE_ID"

# Esperar a que la instancia esté en ejecución
aws ec2 wait instance-running --region "$REGION" \
  --instance-ids "$INSTANCE_ID"

# Obtener la dirección IPv4 pública
IP=$(aws ec2 describe-instances --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "Abre en el navegador: http://$IP"
