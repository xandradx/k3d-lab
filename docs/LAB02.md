# Escalando Deployment

Modifique la definición de su recurso de deployment y actualice la cantidad de replicas a "3".

Editando la sección:

```yaml
spec:
  replicas: 1
```
por

```yaml
spec:
  replicas: 3
```

Aplique los cambios:


```kubectl apply -f k8s/02-deployment.yaml```

Salida:
```
deployment.apps/app01 configured
```

Puede validar la cantidas de pods en el namespace demoapp01.

```kubectl get pods -n demoapp01```

Salida:

```
NAME                   READY   STATUS    RESTARTS   AGE
app01-6fb8c9d6-4gfkm   1/1     Running   0          9m19s
app01-6fb8c9d6-q8zcp   1/1     Running   0          2m1s
app01-6fb8c9d6-bzzkr   1/1     Running   0          2m1s
```

Vamos a utilizar la forma imperativa para cambiar la cantidad de replicas a ```2```.

```
kubectl scale --replicas=2 deployment/app01 -n demoapp01
```

Salida:
```
deployment.apps/app01 scaled
```

Valide nuevamente la cantidad de pods en el namespace.

Tome nota que este cambio no fue registrado en el archivo de definición del recurso, por lo que el estado del sistema es inconsistente con la definición del archivo.

## Validando cambio en estado actual contra la definición del recurso

```
kubectl diff -f k8s/02-deployment.yaml
```

Salida:

```
diff -u -N /tmp/LIVE-1639003980/apps.v1.Deployment.demoapp01.app01 /tmp/MERGED-3052297133/apps.v1.Deployment.demoapp01.app01
--- /tmp/LIVE-1639003980/apps.v1.Deployment.demoapp01.app01	2026-04-09 19:27:27.669977009 +0000
+++ /tmp/MERGED-3052297133/apps.v1.Deployment.demoapp01.app01	2026-04-09 19:27:27.669977009 +0000
@@ -6,7 +6,7 @@
     kubectl.kubernetes.io/last-applied-configuration: |
       {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"labels":{"app":"app01"},"name":"app01","namespace":"demoapp01"},"spec":{"replicas":3,"selector":{"matchLabels":{"app":"app01"}},"strategy":{},"template":{"metadata":{"creationTimestamp":null,"labels":{"app":"app01"}},"spec":{"containers":[{"image":"quay.io/jandrade/democontainerapp:v1.0","name":"democontainerapp","resources":{"limits":{"cpu":100,"memory":"128Mi"},"requests":{"cpu":"10m","memory":"10Mi"}}}]}}}}
   creationTimestamp: "2026-04-09T19:16:30Z"
-  generation: 6
+  generation: 7
   labels:
     app: app01
   name: app01
@@ -15,7 +15,7 @@
   uid: 6d485b1a-1234-4984-a259-05e166d623aa
 spec:
   progressDeadlineSeconds: 600
-  replicas: 2
+  replicas: 3
   revisionHistoryLimit: 10
   selector:
     matchLabels:
 ```

La salida ha sido recortada, puede observar que se muestran los cambios que existen entre el estado actual y la definición del recurso


Edite la definición del recurso colocando las cantidad de replicas en ```2```.

Y aplique nuevamente los cambios al deployment.

```kubectl apply -f k8s/deployment.yaml```

Salida:

```
deployment.apps/app01 configured
```

Puede volver a consultar las diferencias entre los estados con el comando anterior:

```kubectl diff -f k8s/deployment.yaml```

La salida estará vacía.

Puede consultar el código de salida del comando anterior.

```echo $?```

Salida:
```
0
```

La opción ``--diff`` utilizando en el comando ```kubectl```, nos devuelve ```0``` cuando no hay cambios y ```1``` cuando estos existen.

Podemos utilizar esta caracteristica en nuestros pipelines en el proceso de Integración y Despliegue continuo (CI/CD) así como en GitOps en la detención de cambios.




