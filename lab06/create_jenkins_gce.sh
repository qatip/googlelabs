#!/bin/bash

# Variables
PROJECT_ID="<Your lab project id>"
REGION="us-west1"
ZONE="us-west1-a"
NETWORK_NAME="jenkins-network"
SUBNET_NAME="jenkins-subnet"
FIREWALL_RULE_NAME="jenkins-firewall"
INSTANCE_NAME="jenkins-instance"
MACHINE_TYPE="e2-small"
IMAGE_PROJECT="ubuntu-os-cloud"
IMAGE_FAMILY="ubuntu-2204-lts"
TAGS="http-server,https-server"
SERVICE_ACCOUNT="<Your lab project id>@<Your lab project id>.iam.gserviceaccount.com"

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable compute.googleapis.com --project $PROJECT_ID

# Step 1: Create VPC
echo "Creating VPC..."
gcloud compute networks create $NETWORK_NAME \
    --subnet-mode=custom \
    --project=$PROJECT_ID

# Step 2: Create Subnet
echo "Creating Subnet..."
gcloud compute networks subnets create $SUBNET_NAME \
    --network=$NETWORK_NAME \
    --region=$REGION \
    --range=10.0.1.0/24 \
    --project=$PROJECT_ID

# Step 3: Create Firewall Rules
echo "Creating Firewall Rules..."
gcloud compute firewall-rules create $FIREWALL_RULE_NAME \
    --network=$NETWORK_NAME \
    --allow tcp:22,tcp:80,tcp:8080 \
    --target-tags=$TAGS \
    --description="Allow SSH, HTTP, and Jenkins access" \
    --project=$PROJECT_ID

# Step 4: Create VM Instance
echo "Creating Compute Engine instance..."
gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --subnet=$SUBNET_NAME \
    --network-tier=PREMIUM \
    --tags=$TAGS \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --service-account=$SERVICE_ACCOUNT \
    --metadata-from-file startup-script=startup-script.sh \
    --project=$PROJECT_ID

# Wait for the instance to initialize
echo "Waiting for the instance to initialize..."
sleep 300

# Retrieve External IP Address
INSTANCE_IP=$(gcloud compute instances describe $INSTANCE_NAME \
    --zone=$ZONE \
    --format="get(networkInterfaces[0].accessConfigs[0].natIP)" \
    --project=$PROJECT_ID)

echo "Instance is accessible at IP: http://$INSTANCE_IP:8080"

# Display Jenkins admin password
echo "Retrieving Jenkins admin password..."
gcloud compute ssh ubuntu@$INSTANCE_NAME --zone=$ZONE --command="cat /home/ubuntu/jenkins_admin_password.txt" --project=$PROJECT_ID
