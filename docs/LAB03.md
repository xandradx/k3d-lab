# LAB03 - Habilitando Readiness Probe y Liveness Probe


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

Salida esperada similar:

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

Luego describir uno:

```bash
POD_NAME=$(kubectl get pods --selector=app=app01 -n demoapp01 -o jsonpath="{.items[0].metadata.name}")
kubectl describe pod ${POD_NAME} -n demoapp01
```

Debe mostrar algo similar a esto:

```bash
Readiness:  http-get http://:8080/ delay=5s timeout=2s period=5s #success=1 #failure=3
Liveness:   http-get http://:8080/ delay=15s timeout=2s period=10s #success=1 #failure=3
```


## Ver eventos relacionados

```bash
kubectl get events -n demoapp01 --sort-by=.metadata.creationTimestamp
```



- comprobar cómo Kubernetes decide cuándo enviar tráfico y cuándo reiniciar contenedores

