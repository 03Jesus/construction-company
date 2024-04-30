#!/bin/bash

cd ./infrastructure

#Deploy Terraform infrastructure
terraform init

echo "\n***[1/3]Terraform has already initialized"

terraform plan -var-file=terraform.tfvars -out=plan.out

echo "\n***[2/3]Terraform has already planned"

terraform apply "plan.out"

echo "\n***[3/3]Terraform has already applied the resources"

echo -e "\n*** Gathering required outputs"

terraform output -json | jq "[. | to_entries | .[] | {key:.key, value: .value.value}] | from_entries" > "output.json"

echo -e "\n*** The outputs have been saved in output.json"

RESOURCE_GROUP=$(jq -r '.resource_group_name' output.json)
SERVER_NAME=$(jq -r '.postgresql_server_name' output.json)
PROJECTS_DB_NAME=$(jq -r '.postgresql_database_projects' output.json)
CLIENTS_DB_NAME=$(jq -r '.postgresql_database_clients' output.json)
SERVER_USERNAME=$(jq -r '.postgresql_username' output.json)
SERVER_PASSWORD=$(jq -r '.postgresql_password' output.json)
SERVICE_BUS_LISTENING_CONNECTION_STRING=$(jq -r '.listen_policy' output.json)
SERVICE_BUS_SENDING_CONNECTION_STRING=$(jq -r '.send_policy' output.json)
ACR_NAME=$(jq -r '.acr_name' output.json)
PROJECTS_DB_CONNECTION_STRING='postgresql://'$SERVER_USERNAME':'$SERVER_PASSWORD'@'$SERVER_NAME':5432/'$PROJECTS_DB_NAME
CLIENTS_DB_CONNECTION_STRING='postgresql://'$SERVER_USERNAME':'$SERVER_PASSWORD'@'$SERVER_NAME':5432/'$CLIENTS_DB_NAME

echo -e "\n*** The resource group name is: $RESOURCE_GROUP"

#Create env files with required values
cd ..
ls -l
echo -e "\n*** Creating appsettings and env files with required values"

cat << EOF > "./clients/.env"
DEVELOPMENT_DATABASE_URL='$CLIENTS_DB_CONNECTION_STRING'
SERVICE_BUS_CONN_STR='$SERVICE_BUS_SENDING_CONNECTION_STRING'
SERVICE_BUS_QUEUE_NAME='client-registered'
EOF
echo -e "\n*** The .env file for clients has been created"

cat << EOF > "./projects/.env"
DEVELOPMENT_DATABASE_URL='$PROJECTS_DB_CONNECTION_STRING'
EOF
echo -e "\n*** The .env file for projects has been created"

source .env_bash

cat << EOF > "./clients-notifications/.env"
SERVICE_BUS_CONN_STR='$SERVICE_BUS_LISTENING_CONNECTION_STRING'
SERVICE_BUS_QUEUE_NAME='client-registered'
GMAIL_ADDRESS='$GMAIL_ADDRESS'
GMAIL_API_KEY='$GMAIL_API_KEY'
EOF
echo -e "\n*** The .env file for clients-notifications has been created"

echo -e "\n*** The env files have been created"

#Build and publish projects
echo -e "\n*** Get access to container registry"
az acr login --name $ACR_NAME

IMAGE_BASE_NAME="${ACR_NAME}.azurecr.io"
TODAY_DATE_TAG=$(date +"%Y-%m-%dT%H-%M-%S")

SERVICE_LIST=("projects" "clients" "clients-notifications")
for service in "${SERVICE_LIST[@]}"
do
    echo
    echo "----------------------------------------"
    echo -e "\n*** Building and publishing $service\n**"
    echo "----------------------------------------"
    cd $service
    service_lowercase=${service,,}
    docker build --progress plain -t ${IMAGE_BASE_NAME}/${service_lowercase}:${TODAY_DATE_TAG} .
    docker push ${IMAGE_BASE_NAME}/${service_lowercase}:${TODAY_DATE_TAG}
    cd ..
done

az acr repository list --name ${ACR_NAME}

#Deploy images to Azure Container Apps
echo -e "\n*** Deploying images to Azure Container Apps"

az containerapp env create -n "microservices-env" -g $RESOURCE_GROUP --location "eastus"

az containerapp up --name "projects" --resource-group $RESOURCE_GROUP --environment microservices-env --image $IMAGE_BASE_NAME/projects:${TODAY_DATE_TAG} --ingress external --target-port 80

az containerapp up --name "clients" --resource-group $RESOURCE_GROUP --environment microservices-env --image $IMAGE_BASE_NAME/clients:${TODAY_DATE_TAG} --ingress external --target-port 80

az containerapp up --name "clients-notifications" --resource-group $RESOURCE_GROUP --environment microservices-env --image $IMAGE_BASE_NAME/clients-notifications:${TODAY_DATE_TAG}

echo -e "\n*** Images deployed to Azure Container Apps"