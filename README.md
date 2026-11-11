# Proyecto 1 - Mi web en AWS

## Introducción a la Nube Pública
### Primera Evaluación

**Proyecto:** Despliegue de Librería Tinta en AWS.  
**Profesora:** María Teresa Cibeles Mora Mora.  
**Alumno:** José Antonio Alguacil Ortiz.  

## B1. Infraestructura de red

### Creación de la VPC

Se ha creado una VPC en la región AWS us-east-1 (Norte de Virginia), utilizando la consola de administración de AWS.

| Parámetro | Valor |
|---|---|
| Nombre | libreria-vpc |
| ID | vpc-0db2e92608e93cf74 |
| CIDR IPv4 | 10.0.0.0/16 |
| IPv6 | Desactivado |
| Resolución DNS | Habilitada |
| Estado | Available |

La VPC proporciona una red virtual aislada donde se desplegarán los recursos del proyecto.

**Evidencia de creación:**

![VPC creada correctamente](img/b1-vpc.png)


### Creación de la subred pública

Se ha creado una subred pública dentro de la VPC `libreria-vpc`, en la región `us-east-1`.

| Parámetro | Valor |
|---|---|
| Nombre | libreria-publica |
| ID | subnet-03dd91e168f17043d |
| VPC | libreria-vpc |
| CIDR IPv4 | 10.0.1.0/24 |
| Zona de disponibilidad | us-east-1a |
| Asignación automática de IPv4 pública | Habilitada |
| Estado | Available |

La subred dispone de 251 direcciones IPv4 utilizables por los recursos de AWS.

Se ha habilitado la asignación automática de direcciones IPv4 públicas para las instancias EC2 que se desplieguen en ella.

**Nota:** Para disponer de conectividad con Internet será necesario configurar posteriormente una puerta de enlace de Internet y la tabla de enrutamiento.

**Evidencia:**

![Configuración de la subred pública](img/b1-subred-publica.png)



### Creación de la puerta de enlace de Internet

Se ha creado una puerta de enlace de Internet (Internet Gateway) y se ha asociado a la VPC `libreria-vpc` desde la consola de AWS.

| Parámetro | Valor |
|---|---|
| Nombre | libreria-igw |
| ID | igw-01add676a85924425 |
| VPC asociada | libreria-vpc |
| Región | us-east-1 |
| Estado | Attached |

La puerta de enlace permite conectar la VPC con Internet. Para que las instancias EC2 de la subred pública puedan utilizarla, será necesario configurar una ruta hacia esta puerta de enlace en la tabla de enrutamiento.

**Evidencia:**

![Internet Gateway asociada a la VPC](img/b1-internet-gateway.png)



### Creación de la tabla de enrutamiento pública

Se ha creado una tabla de enrutamiento específica para la subred pública de la librería, utilizando la consola de AWS.

| Parámetro | Valor |
|---|---|
| Nombre | libreria-rt-publica |
| ID | rtb-0ed6e0a920063c86e |
| VPC | libreria-vpc |
| Subred asociada | libreria-publica |
| Región | us-east-1 |

#### Configuración de rutas

| Destino | Objetivo | Estado |
|---|---|---|
| 10.0.0.0/16 | local | Activo |
| 0.0.0.0/0 | libreria-igw | Activo |

La ruta local permite la comunicación entre recursos de la VPC. La ruta 0.0.0.0/0 dirige el tráfico destinado a Internet hacia la puerta de enlace libreria-igw.

Se ha asociado explícitamente la subred libreria-publica a esta tabla de enrutamiento.

**Evidencia de las rutas configuradas:**

![Rutas de la tabla pública](img/b1-rutas.png)

**Evidencia de la asociación de subred:**

![Asociación de la subred pública](img/b1-tabla-rutas.png)

### Resultado del bloque B1

Se ha configurado la infraestructura de red del proyecto:

- VPC con direccionamiento 10.0.0.0/16.
- Subred pública 10.0.1.0/24 en us-east-1a.
- Asignación automática de IPv4 pública habilitada.
- Internet Gateway asociada a la VPC.
- Tabla de enrutamiento pública con salida a Internet.
- Asociación explícita de la subred pública a la tabla.

La configuración de red está preparada para desplegar las instancias EC2 del proyecto.



## B2. Configuración de seguridad

### Creación del grupo de seguridad

Se ha creado un grupo de seguridad en AWS para controlar el tráfico de entrada y salida del servidor web de Librería Tinta.

| Parámetro | Valor |
|---|---|
| Nombre | libreria-web-sg |
| ID | sg-0a1b5c2a23679489e |
| VPC | libreria-vpc |
| Descripción | Seguridad del servidor web Librería Tinta |
| Región | us-east-1 |

### Reglas de entrada

| Tipo | Protocolo | Puerto | Origen |
|---|---|---|---|
| HTTP | TCP | 80 | 0.0.0.0/0 |
| SSH | TCP | 22 | 78.30.6.87/32 |

**Justificación de las reglas:**

- **HTTP (80):** permite que cualquier usuario de Internet acceda a la página web de Librería Tinta.
- **SSH (22):** restringe el acceso administrativo al servidor a mi dirección IP pública, evitando conexiones SSH desde otras direcciones.

### Reglas de salida

Se ha mantenido la regla de salida predeterminada de AWS, que permite todo el tráfico saliente.

Esto permitirá que la instancia EC2 descargue los paquetes necesarios para instalar y actualizar el servidor web nginx.

### Resultado del bloque B2

El grupo de seguridad `libreria-web-sg` se ha creado correctamente y dispone de las dos reglas de entrada exigidas por el proyecto.

La configuración está preparada para asociarse a la instancia EC2 que se desplegará en el apartado B3.

**Evidencia de configuración:**

![Grupo de seguridad y reglas de entrada](img/b2-grupo-seguridad.png)



## B3. Despliegue del servidor web

### Creación de la instancia EC2

Se ha desplegado una instancia Amazon EC2 para alojar la página web de **Librería Tinta**, utilizando la infraestructura de red y seguridad configurada en los apartados anteriores.

La instancia se ha creado con los siguientes parámetros:

| Parámetro | Configuración |
|---|---|
| Nombre | libreria-web |
| AMI | Amazon Linux 2023 |
| Tipo de instancia | t3.micro |
| Par de claves | vockey |
| Región | us-east-1 (Norte de Virginia) |
| VPC | libreria-vpc |
| Subred | libreria-publica |
| Dirección IPv4 pública automática | Habilitada |
| Grupo de seguridad | libreria-web-sg |
| Almacenamiento | Configuración predeterminada |

Se han añadido las etiquetas solicitadas:

| Clave | Valor |
|---|---|
| Proyecto | P1 |
| Alumno | José Antonio Alguacil |

### Evidencias del despliegue

**1. Listado de instancias EC2**

La siguiente captura muestra la instancia `libreria-web` en ejecución desde la consola de Amazon EC2.

![Listado de instancias EC2](img/b3-listado-instancias.png)

**2. Detalles de configuración de la instancia**

La siguiente captura permite comprobar la configuración de la instancia y su asociación con la infraestructura creada previamente.

![Detalles de la instancia EC2](img/b3-detalle-instancia.png)

### Automatización del servidor web

Durante el lanzamiento se ha introducido un script de inicialización mediante **User data**, basado en el archivo `user-data1.sh` del enunciado.

El script realiza automáticamente las siguientes operaciones:

1. Instala el servidor web nginx mediante `dnf`.
2. Habilita e inicia el servicio nginx.
3. Genera el archivo `/usr/share/nginx/html/index.html`.
4. Personaliza la página de Librería Tinta con su horario, dirección ficticia, libro recomendado y datos del despliegue.

La comprobación del funcionamiento de nginx y del acceso HTTP se documentará a continuación.


