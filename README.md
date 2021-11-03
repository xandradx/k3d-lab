# k3d-lab

Clonar este repositorio

```bash
git clone https://github.com/xandradx/k3d-lab.git
```

Estructura

```
|
`-- k8s/ <----  Manifiestos Kubernetes
```

## Requerimientos 

* Ubuntu 20.04
* Docker
* kubectl 1.18+
* ~2GB RAM (puede ser una Maquina Virtual)

## k3s 
* Distribución de Kubernetes liviana (k3s vs k8s)
* 1 Binario ~200mb
* Consumo de memoria ~300MB
* Para ser utilizado prácticamente cualquier lugar
  * Desarrollo
  * CI/CD
  * Edge
  * IoT
  * Appliances
* Ideal para Edge Computing
* Certificado por CNCF y ha sido ya ofrecido para donación a la fundación. https://github.com/cncf/toc/pull/447
* Enfocado en la simplicidad

## Preparación de Requerimientos

### Linux

Actualizar el Sistema Operativo

```
sudo apt-get update
sudo apt-get dist-upgrade -y

```

Reiniciar si se ha instalado una versión más reciente del kernel.




### Docker

```
sudo apt-get install docker.io -y
MY_USER=$(whoami) 
sudo usermod -a -G docker ${MY_USER}
```

Validar que el usuario actual pertenezca al grupo docker.

```
id ${MY_USER}
```

Debe de volver a iniciar sesión para que el cambio tome efecto.

### kubectl

```
sudo curl -L -o /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" 
sudo chmod a+rx /usr/local/bin/kubectl
```

***Autocompletación kubectl***

Asegurese de tener instalado bash-completion o adapte las instrucciones para el shell que tenga en ejecución.

```
sudo  apt-get install -y bash-completion 

```

```
sudo sh -c "kubectl completion bash > /etc/bash_completion.d/kubectl"
source /etc/bash_completion.d/kubectl
```

### k3d

k3d es una utilidad diseñada para ejecutar fácilmente k3s en Docker, proporciona una utileria de linea de comando simple para crear, ejecutar y eliminar un clúster de Kubernetes utilizando k3s.

```
 sudo curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
 ```

 ***Autocompletación k3d***

```
sudo sh -c "k3d completion bash > /etc/bash_completion.d/k3d"
source /etc/bash_completion.d/k3d
```

# Creando mi primer cluster con k3d

Selecciones un puerto en su maquina para mapear el puerto del balanceador de carga al puerto 80 del balanceador de carga "loadbalancer"


```
PUBLISH_PORT=8080


k3d cluster create cluster-demo --agents 2 --servers 1 -p "${PUBLISH_PORT}:80@loadbalancer"
```

En nuestro ejemplo:


|     Opción   |              Descripción        |   Valor  |
|--------------|:-------------------------------:|---------:|
|agents        | Cantidad de workers             |  2       |  
|servers       | Cantidad de masters             |  1       |
|servers-memory| Memoria asignada a cada master  | OPCIONAL |
|agents-memory | Memoria asiganada a cada worler | OPCIONAL |


Se mostrará una salida similar a la siguiente:

```bash
INFO[0000] portmapping '8080:80' targets the loadbalancer: defaulting to [servers:*:proxy agents:*:proxy]
INFO[0000] Prep: Network
INFO[0000] Created network 'k3d-cluster-demo'
INFO[0000] Created volume 'k3d-cluster-demo-images'
INFO[0000] Starting new tools node...
INFO[0000] Starting Node 'k3d-cluster-demo-tools'
INFO[0001] Creating node 'k3d-cluster-demo-server-0'
INFO[0001] Creating node 'k3d-cluster-demo-agent-0'
INFO[0001] Creating node 'k3d-cluster-demo-agent-1'
INFO[0001] Creating LoadBalancer 'k3d-cluster-demo-serverlb'
INFO[0001] Using the k3d-tools node to gather environment information
INFO[0001] HostIP: using network gateway...
INFO[0001] Starting cluster 'cluster-demo'
INFO[0001] Starting servers...
INFO[0001] Starting Node 'k3d-cluster-demo-server-0'
INFO[0001] Deleted k3d-cluster-demo-tools
INFO[0007] Starting agents...
INFO[0007] Starting Node 'k3d-cluster-demo-agent-0'
INFO[0007] Starting Node 'k3d-cluster-demo-agent-1'
INFO[0020] Starting helpers...
INFO[0020] Starting Node 'k3d-cluster-demo-serverlb'
INFO[0027] Injecting '172.18.0.1 host.k3d.internal' into /etc/hosts of all nodes...
INFO[0027] Injecting records for host.k3d.internal and for 4 network members into CoreDNS configmap...
INFO[0028] Cluster 'cluster-demo' created successfully!
INFO[0028] You can now use it like this:
kubectl cluster-info
```

Validaar el nuevo cluster

```
kubectl cluster-info
```

Se mostrará una salida similar a la siguiente:

```bash
Kubernetes control plane is running at https://0.0.0.0:34451
CoreDNS is running at https://0.0.0.0:34451/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://0.0.0.0:34451/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

```

Se han deplegos los componentes de:

* Ingress Controller (traefik)
* Metric server
* Local Path provisioner
* Core DNS

Listando los nodos del cluster


```
 kubectl get nodes
```

```bash
NAME                        STATUS   ROLES                  AGE     VERSION
k3d-cluster-demo-server-0   Ready    control-plane,master   5m25s   v1.21.5+k3s2
k3d-cluster-demo-agent-1    Ready    <none>                 5m15s   v1.21.5+k3s2
k3d-cluster-demo-agent-0    Ready    <none>                 5m15s   v1.21.5+k3s2
```

Se puede observar que existe la cantidad de nodos de acuerdo a la ejecución del comando.

Listando los pods en ejecución en todo cl cluster

```
kubectl get pods --all-namespaces
```

```bash
NAMESPACE     NAME                                      READY   STATUS      RESTARTS   AGE
kube-system   metrics-server-86cbb8457f-trx98           1/1     Running     0          6m29s
kube-system   helm-install-traefik-crd-7jzmt            0/1     Completed   0          6m29s
kube-system   local-path-provisioner-5ff76fc89d-jf6z5   1/1     Running     0          6m29s
kube-system   helm-install-traefik-ltx64                0/1     Completed   1          6m29s
kube-system   coredns-7448499f4d-vzv47                  1/1     Running     0          6m29s
kube-system   svclb-traefik-4x98s                       2/2     Running     0          5m56s
kube-system   svclb-traefik-gwp69                       2/2     Running     0          5m56s
kube-system   svclb-traefik-slhlh                       2/2     Running     0          5m56s
kube-system   traefik-97b44b794-k9hks                   1/1     Running     0          5m56s
```

# Operaciones con k3d

## Lister clusters

```
k3d cluster list
```

```
NAME           SERVERS   AGENTS   LOADBALANCER
cluster-demo   1/1       2/2      true
helloworld     3/3       3/2      true
```

En nueestro ejemplo hay 2 clusters (helloworl y cluster-demo)

## Detener clusters

```
k3d cluster stop cluster-demo
```

```bash
INFO[0000] Stopping cluster 'cluster-demo'
INFO[0011] Stopped cluster 'cluster-demo'
```

Al listar los cluster de nuevo podremos observar que ha sido detenido, indicado que hay 0/n nodos en ejecución por cada rol.

```
k3d cluster list
```

```
NAME           SERVERS   AGENTS   LOADBALANCER
cluster-demo   0/1       0/2      true
helloworld     3/3       2/2      true
```

## Iniciar clusters

```
k3d cluster start cluster-demo
```

```bash
INFO[0000] Using the k3d-tools node to gather environment information
INFO[0000] Starting new tools node...
INFO[0000] Starting Node 'k3d-cluster-demo-tools'
INFO[0000] HostIP: using network gateway...
INFO[0000] Starting cluster 'cluster-demo'
INFO[0000] Starting servers...
...
```


## Eliminar clusters

```
k3d cluster delete cluster-demo
```

```bash
INFO[0000] Deleting cluster 'cluster-demo'
INFO[0000] Deleted k3d-cluster-demo-serverlb
INFO[0000] Deleted k3d-cluster-demo-agent-1
INFO[0000] Deleted k3d-cluster-demo-agent-0
INFO[0000] Deleted k3d-cluster-demo-server-0
INFO[0000] Deleting cluster network 'k3d-cluster-demo'
INFO[0000] Deleting image volume 'k3d-cluster-demo-images'
INFO[0000] Removing cluster details from default kubeconfig...
INFO[0000] Removing standalone kubeconfig file (if there is one)...
INFO[0000] Successfully deleted cluster cluster-demo!
```

No elimine este cluster si quiere seguir ![la siguiente sección](LAB01.md) para publicar nuestra primera app en Kuberetes.





