# Habilitando Readiness Probe y Liveness Probe


## Tipos básicos de Pruebas

- `readinessProbe`: indica si el contenedor ya está listo para recibir tráfico.
- `livenessProbe`: indica si el contenedor sigue sano o si Kubernetes debe reiniciarlo.


## Deployment actualizado con probes

Modificar el archivo:

```bash
k8s/02-deployment.yaml
```

Con el siguiente contenido:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: app01
  name: app01
  namespace: demoapp01
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app01
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: app01
    spec:
      containers:
      - image: quay.io/jandrade/democontainerapp:v1.0
        name: democontainerapp
        ports:
          - name: web
            containerPort: 8080
            protocol: TCP
        resources:
          requests:
            cpu: 10m
            memory: 10Mi
          limits:
            cpu: 100m
            memory: 128Mi
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 2
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 2
          successThreshold: 1
          failureThreshold: 3
```



## Aplicar el cambio

```bash
kubectl apply -f k8s/02-deployment.yaml
```


## Validar el deployment

```bash
kubectl get deployment app01 -n demoapp01
kubectl describe deployment app01 -n demoapp01
```



## Validar los pods

```bash
kubectl get pods -n demoapp01
```

Salida esperada:

```bash
NAME                     READY   STATUS    RESTARTS   AGE
app01-xxxxxxxxxx-aaaaa   1/1     Running   0          20s
app01-xxxxxxxxxx-bbbbb   1/1     Running   0          20s
app01-xxxxxxxxxx-ccccc   1/1     Running   0          20s
```


## Verificar las probes en un pod

Primero obtener el nombre del pod:

```bash
kubectl get pods -n demoapp01
```

Describir recurso tipo ```pod``` del ```deployment``` actualizado:

```bash
POD_NAME=$(kubectl get pods --selector=app=app01 -n demoapp01 -o jsonpath="{.items[0].metadata.name}")
kubectl describe pod ${POD_NAME} -n demoapp01
```

Salida esperada:
```bash
Name:             app01-5f8b5b45bd-5qtk4
Namespace:        demoapp01
Priority:         0
Service Account:  default
Node:             k3d-cluster-demo-agent-0/172.18.0.4
Start Time:       Thu, 09 Apr 2026 21:28:59 +0000
Labels:           app=app01
                  pod-template-hash=5f8b5b45bd
Annotations:      <none>
Status:           Running
IP:               10.42.0.20
IPs:
  IP:           10.42.0.20
Controlled By:  ReplicaSet/app01-5f8b5b45bd
Containers:
  democontainerapp:
...
    Readiness:    http-get http://:8080/ delay=5s timeout=2s period=5s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-zbnpl (ro)
...
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  8m7s  default-scheduler  Successfully assigned demoapp01/app01-5f8b5b45bd-5qtk4 to k3d-cluster-demo-agent-0
  Normal   Pulled     8m7s  kubelet            Container image "quay.io/jandrade/democontainerapp:v1.0" already present on machine
  Normal   Created    8m7s  kubelet            Created container democontainerapp
  Normal   Started    8m7s  kubelet            Started container democontainerapp
  Warning  Unhealthy  8m2s  kubelet            Readiness probe failed: Get "http://10.42.0.20:8080/": dial tcp 10.42.0.20:8080: connect: connection refused
```


## Mostrar eventos relacionados

```bash
kubectl get events -n demoapp01 --sort-by=.metadata.creationTimestamp
```




