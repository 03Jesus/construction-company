# Construction Company for UTB

## Problem's description
A construction company uses separate systems for equipment, inventory, scheduling, payroll and accounting accumulated over decades. Data is siloed, limiting operational insight. Adding new analytics is difficult and time-consuming. Changing any system requires complex coordination. Disconnected systems make it nearly impossible to optimize decisions throughout the construction lifecycle. For example, equipment and material allocation is not optimal because work schedules lack real-time visibility. This leads to delays, unplanned downtime and bloated inventories. The company needs to share unified data across all facets of construction operations to increase productivity. The solution would identify microservices aligned with construction capabilities, such as scheduling and equipment management. These microservices would expose relevant operations data through APIs managed by a gateway. This approach gradually decomposes isolated systems into specific, decoupled services that provide unified access to data. There are some specifics:
- Develop microservices for scheduling, teams, project management.
- Expose relevant operational data through APIs controlled by a gateway.

## The MVP
Our MVP for this project is create a CRUD microservices for: Projects, clients, schedules, ect... These will be connected to it's own database where the server will be able to make the respective calls.

## How to run each microservice

### 1. Create a Python virtual environment

#### On Windows:
`python -m venv <<virtual_enviornment_name>>`
#### On Linux / Mac OS
`python3 -m virtualenv <<virtual_enviornment_name>>`

### 2. Activate the virtual environment
#### On Windows
`<<virtual_enviornment_name>>\Scripts\activate`
#### On Linux / Mac OS
`source  <<virtual_enviornment_name>>/bin/activate`

### 3. Install the dependencies
#### On Windows
`pip install -r requirements.txt`
#### On Linux / Mac OS
`pip3 intall -r requirements.txt`

### 4. Run the FastAPI Server
`uvicorn main:app --reload`
> :warning: **--reload** flag must be used only in development environments!

## Environment variables

It's necessary to have an `.env` file at the same level of the `main.py` file. With the next variables:
### For clients
```
DEVELOPMENT_DATABASE_URL
SERVICE_BUS_CONN_STR
SERVICE_BUS_QUEUE_NAME
```
### For clients-notifications
```
SERVICE_BUS_CONN_STR
SERVICE_BUS_QUEUE_NAME
GMAIL_ADDRESS
GMAIL_API_KEY
```

### For projects
```
DEVELOPMENT_DATABASE_URL
```

## Deployment
### Architecture
![Architecture](/readme_assets/architecture.png)
### About the API Managment...
It has been decided that with Terraform only the API Managment will be created but not the “sub-apis” with all the endpoints, this is created manually from the Azure Portal. The reason for this is that the portal allows us to create an API based on a container of an ACR for microservices, this added with FastAPI provides automatic swagger documentation of each microservice, so the API Managment is able to automatically detect each EndPoint and configure it automatically for us.
### GitHub Repository
For simplicity, a “monorepository” has been made in which all microservices are located. Each microservice has its main branch, for example “projects-main”, “clients-main” and “clients-notifications-main”, so the GitHub Actions are configured in each branch, every time a push is made in each branch, only the container of the respective branch will be updated.
> :warning: Before deploying it is necessary to have Azure CLI in the system logged in with the account where the infrastructure will be deployed.
### Script to deploy
To deploy the entire infrastructure you can run the [deploy_system.sh](/deploy_system.sh) script  
The script initially executes the Terraform code and generates an “output.json” file containing the important infrastructure credentials, such as passwords, connection strings, policies, etc...
Each of these outputs are stored in variables that will be used to create the “.env” files which are necessary for the Python code of each microservice to obtain the necessary credentials to function.
After that, the script goes through the folders of each microservice building the Docker images using the Dockerfile found in the respective directories.
Finally, with the help of the Azure CLI the containers are deployed in the environment created with Terraform.
### Environment variables for deployment
Most of the variables will be obtained from the terraform outputs. You should have a variables file for terraform `terraform.tfvars` at the same level as the main main file with the following variables:
```
resource_group_name
resource_group_location
postgresql_server_name
postgresql_server_username
service_bus_namespace_name
acr_name
postgresql_server_password
api_managment_email 
```
> :information_source: The `postgresql_server_password` variable is set for a default value, but it's generated and overwritten in the [main.tf](/infrastructure/modules/postgresql/main.tf) of the PostgreSQL module.

The only 2 variables that must be added manually are those necessary for the microservice of notifications via Gmail, for this you must have a `.env_bash` file at the same level of the deployment script with the following variables:
```
GMAIL_ADDRESS
GMAIL_API_KEY
```

## CI/CD
The following secrets are required for GitHub actions:
- ACR_USERNAME
- ACR_PASSWORD
- AZURE_CREDENTIALS
### Commands to get the credentials using Azure CLI
<details>
<summary>For ACR_USERNAME and ACR_PASSWORD</summary>

```
az acr credential show --name <<acrnamehere>>
```
</details>
<details>
<summary>For AZURE_CREDENTIALS</summary>

```
az ad sp create-for-rbac --name "microservicesAccess" --role contributor --scopes /subscriptions/<<subscription-id-here>> --sdk-auth
```
Only the first 4 are required
</details>  

### GitHub Actions
As mentioned above, each microservice contains its own GitHub Action for deployment, these have the same structure, what changes is the branch and the directory they point to.
Each workflow does:
1. A checkout of the repository.
2. Install the Azure containerapp extension on the GitHub machine.
3. Logs into the ACR created with Terraform.
4. Gets the timestamp of the current date to be used as a tag in each new deployment.
5. Builds, pushes, and deploys the new image to the ACR.
## The application
Right now the application can be tested using any tool to make HTTP requests with the URL: https://construction-company-apim.azure-api.net.  
For clients: https://construction-company-apim.azure-api.net/clients/clients/  
For projects: https://construction-company-apim.azure-api.net/projects/  
For example, below is a test of a GET request in the client microservice using the Insomnia application:
![test](/readme_assets/test.png)