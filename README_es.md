# Construction Company for UTB

## Descripción del problema
Una empresa de construcción utiliza sistemas separados para equipos, inventario, programación, nóminas y contabilidad acumulados durante décadas. Los datos están aislados, lo que limita la visión operativa. Añadir nuevos análisis es difícil y lleva mucho tiempo. Cambiar cualquier sistema requiere una coordinación compleja. Los sistemas desconectados hacen casi imposible optimizar las decisiones a lo largo del ciclo de vida de la construcción. Por ejemplo, la asignación de equipos y materiales no es óptima porque los calendarios de trabajo carecen de visibilidad en tiempo real. Esto provoca retrasos, tiempos de inactividad imprevistos e inventarios abultados. La empresa necesita compartir datos unificados en todas las facetas de las operaciones de construcción para aumentar la productividad. La solución identificaría microservicios alineados con las capacidades de construcción, como la programación y la gestión de equipos. Estos microservicios expondrían los datos relevantes de las operaciones a través de un API gateway. Este enfoque descompone gradualmente los sistemas aislados en servicios específicos y desacoplados que proporcionan un acceso unificado a los datos. Hay algunos detalles específicos:
- Desarrollar microservicios para programación, equipos, gestión de proyectos.
- Exponer los datos operativos relevantes a través de API controladas por una pasarela.

## El MVP
Nuestro MVP para este proyecto es crear un microservicio CRUD para: Proyectos, clientes, horarios, ect... Estos estarán conectados a su propia base de datos donde el servidor podrá hacer las llamadas respectivas.


## Cómo ejecutar cada microservicio

### 1. Crear un entorno virtual de Python

#### En Windows:
`python -m venv <<nombre_entorno_virtual>>`
#### En Linux / Mac OS
`python3 -m virtualenv <<nombre_del_entorno_virtual>>`

### 2. Activar el entorno virtual
#### En Windows
`<nombre_del_entorno_virtual>>\Scripts\activate`
#### En Linux / Mac OS
`source <<nombre_del_entorno_virtual>>/bin/activate`

### 3. Instalar las dependencias
#### En Windows
`pip install -r requisitos.txt`
#### En Linux / Mac OS
`pip3 intall -r requirements.txt`

### 4. Ejecute el servidor FastAPI
`uvicorn main:app --reload`
> :warning: **--reload** ¡esta opción sólo debe usarse en entornos de desarrollo!

## Variables de entorno

Es necesario tener un archivo `.env` al mismo nivel que el archivo `main.py`. Con las siguientes variables:
### Para clients
```
DEVELOPMENT_DATABASE_URL
SERVICE_BUS_CONN_STR
SERVICE_BUS_QUEUE_NAME
```
### Para clients-notifications
```
SERVICE_BUS_CONN_STR
SERVICE_BUS_QUEUE_NAME
GMAIL_ADDRESS
GMAIL_API_KEY
```

### Para projects
```
DEVELOPMENT_DATABASE_URL
```
## Despliegue
### Arquitectura
![Arquitectura](/readme_assets/architecture.png)

### Sobre el API Managment...
Se ha decidido que con Terraform solo se cree el API Managment pero no las "sub-apis" con todos los endpoints, esto se crea manualmente desde el Portal de Azure. La razón de esto es que el portal nos permite crear una API basada en un contenedor de un ACR para microservicios, esto añadido con que FastAPI proporciona documentación swagger automática de cada microservicio, por lo que el API Managment es capaz de detectar automáticamente cada EndPoint y configurarlo automáticamente por nosotros añadiendo query parameters y los respectivos métodos.
### Repositorio GitHub
Por simplicidad, se ha hecho un "monorepositorio" en el que se encuentran todos los microservicios. Cada microservicio tiene su rama principal, por ejemplo `projects-main`, `clients-main` y `clients-notifications-main`, por lo que las GitHub Actions están configuradas en cada rama, cada vez que se haga un push en cada rama, sólo se actualizará el contenedor de la rama respectiva.
> :warning: Antes de desplegar es necesario tener Azure CLI en el sistema logueado con la cuenta donde se desplegará la infraestructura.
### Script para desplegar
Para desplegar toda la infraestructura se puede ejecutar el script [deploy_system.sh](/deploy_system.sh)  
El script ejecuta inicialmente el código Terraform y genera un archivo `output.json` que contiene las credenciales importantes de la infraestructura, como contraseñas, cadenas de conexión, políticas, etc...Cada una de estos outputs se almacenan en variables que se utilizarán para crear los archivos `.env` necesarios para que el código Python de cada microservicio obtenga las credenciales necesarias para funcionar.
Después, el script recorre las carpetas de cada microservicio construyendo las imágenes Docker utilizando el Dockerfile que se encuentra en los respectivos directorios.
Finalmente, con la ayuda del CLI de Azure se despliegan los contenedores en el entorno creado con Terraform.
### Variables de entorno para el despliegue
La mayoría de las variables se obtendrán de las salidas de terraform. Se debe tener un fichero de variables para terraform `terraform.tfvars` al mismo nivel que el fichero principal con las siguientes variables:
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
> :information_source: La variable `postgresql_server_password` tiene un valor por defecto, pero es generada y sobreescrita en el fichero [main.tf](/infrastructure/modules/postgresql/main.tf) del módulo PostgreSQL.

Las únicas 2 variables que hay que añadir manualmente son las necesarias para el microservicio de notificaciones vía Gmail, para ello hay que tener un fichero `.env_bash` al mismo nivel del script de despliegue con las siguientes variables:
```
GMAIL_ADDRESS
GMAIL_API_KEY
```
## CI/CD 
Los siguientes secrets son necesarios para las Github Actions
- ACR_USERNAME
- ACR_PASSWORD
- AZURE_CREDENTIALS
### Comandos para obtener las credenciales utilizando Azure CLI
<details>
<summary>Para ACR_USERNAME y ACR_PASSWORD</summary>

```
az acr credential show --name <<acrnamehere>>
```
</details>
<details>
<summary>Para AZURE_CREDENTIALS</summary>

```
az ad sp create-for-rbac --name "microservicesAccess" --role contributor --scopes /subscriptions/<<subscription-id-here>> --sdk-auth
```
Sólo son necesarias las 4 primeras
</details>  

### GitHub Actions
Como se mencionó anteriormente, cada microservicio contiene su propia GitHub Action para el despliegue, estas tienen la misma estructura, lo que cambia es la rama y el directorio al que apuntan.
Cada workflow hace lo siguiente:
1. Un checkout del repositorio.
2. Instala la extensión Azure containerapp en la máquina de GitHub.
3. Inicia sesión en el ACR creado con Terraform.
4. Obtiene el timestamp de la fecha actual para utilizarla como etiqueta en cada nuevo despliegue.
5. Construye, hace push y despliega la nueva imagen en el ACR.
## La aplicación
Ahora mismo la aplicación puede ser testeada utilizando cualquier herramienta para realizar peticiones HTTP con la URL: https://construction-company-apim.azure-api.net.  
Para clientes: https://construction-company-apim.azure-api.net/clients/clients/  
Para proyectos: https://construction-company-apim.azure-api.net/projects/  
Por ejemplo, acontinuación se muestra una prueba de una petición GET en el microservicio de clientes utilizando la aplicación de Insomnia:
![test](/readme_assets/test.png)