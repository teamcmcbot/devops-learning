# Task 08:

One of the Nautilus DevOps team members was working on to update an existing Kubernetes template. Somehow, he made some mistakes in the template and it is failing while applying. We need to fix this as soon as possible, so take a look into it and make sure you are able to apply it without any issues. Also, do not remove any component from the template like pods/deployments/volumes etc.


`/home/thor/mysql_deployment.yml` is the template that needs to be fixed.


Note: The kubectl utility on jump_host has been configured to work with the kubernetes cluster.

```yaml
thor@jumphost ~$ cat mysql_deployment.yml 
apiVersion: apps/v1 
kind: Persistentvolume 
metadata:
  name: mysql-pv
  labels:
    type: local
spec:
  storageClassName: standard       
  capacity:
    storage: 250Mi
  accessModes: ReadWriteOnce 
  hostPath:                       
    path: "/mnt/data"
  persistentVolumeReclaimPolicy: 
    - Retain   
---    
apiVersion: apps/v1 
kind: Persistentvolumeclaim       
metadata:                          
  name: mysql-pv-claim
  labels:
    app: mysql-app 
spec:                              
  storageClassName: standard       
  accessModes: ReadWriteOnce             
  resources:
    requests:
      storage: 250MB 
---
apiVersion: v1                    
kind: Service                      
metadata:
  name: mysql         
  labels:             
  app: mysql-app  
spec:
  type: NodePort
  ports:
    - targetPort: 3306
      port: 3306
      nodePort: 30011
  selector:                       
    app: mysql_app
    tier: mysql
---
apiVersion: app/v1 
kind: Deployment                    
metadata:
  name: mysql-deployment           
  labels:                         
  app: mysql-app   
spec:
  selector:
    matchlabels:                  
    app: mysql-app 
    tier: mysql 
  strategy:
    type: Recreate 
  template:         
    metadata:
      labels:        
        app: mysql-app
        tier: mysql
    spec:            
      containers:
      - image: mysql:5.6 
        name: mysql
        env:              
        - name: MYSQL_ROOT_PASSWORD 
          valueFrom:     
            secretKeyRef:
            name: mysql-root-pass 
              key: password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
            name: mysql-db-url 
              key: database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
            name: mysql-user-pass 
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
            name: mysql-user-pass 
              key: password
        ports:
        - containerPort: 3306              
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage  
          mountPath: /var/lib/mysql
      volumes:                        
      - name: mysql-persistent-storage
          persistentVolumeClaim: 
          claimName: mysql-pv-claim

```

## Additional info:

```bash
thor@jumphost ~$ k get secrets
NAME              TYPE     DATA   AGE
mysql-db-url      Opaque   1      111s
mysql-root-pass   Opaque   1      112s
mysql-user-pass   Opaque   2      112s
```

```bash
thor@jumphost ~$ k apply -f mysql_deployment.yml 
[resource mapping not found for name: "mysql-pv" namespace: "" from "mysql_deployment.yml": no matches for kind "Persistentvolume" in version "apps/v1"
ensure CRDs are installed first, resource mapping not found for name: "mysql-pv-claim" namespace: "" from "mysql_deployment.yml": no matches for kind "Persistentvolumeclaim" in version "apps/v1"
ensure CRDs are installed first, error parsing mysql_deployment.yml: error converting YAML to JSON: yaml: line 28: mapping values are not allowed in this context]
Error from server (BadRequest): error when creating "mysql_deployment.yml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.app"
```

```bash
thor@jumphost ~$ k apply -f mysql_deployment.yml 
[resource mapping not found for name: "mysql-pv" namespace: "" from "mysql_deployment.yml": no matches for kind "PersistentVolume" in version "apps/v1"
ensure CRDs are installed first, resource mapping not found for name: "mysql-pv-claim" namespace: "" from "mysql_deployment.yml": no matches for kind "PersistentVolumeClaim" in version "apps/v1"
ensure CRDs are installed first, error parsing mysql_deployment.yml: error converting YAML to JSON: yaml: line 28: mapping values are not allowed in this context]
Error from server (BadRequest): error when creating "mysql_deployment.yml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.app"
```

```bash
thor@jumphost ~$ k apply -f mysql_deployment.yml 
error parsing mysql_deployment.yml: error converting YAML to JSON: yaml: line 28: mapping values are not allowed in this context
Error from server (BadRequest): error when creating "mysql_deployment.yml": PersistentVolume in version "v1" cannot be handled as a PersistentVolume: json: cannot unmarshal string into Go struct field PersistentVolumeSpec.spec.accessModes of type []v1.PersistentVolumeAccessMode
Error from server (BadRequest): error when creating "mysql_deployment.yml": PersistentVolumeClaim in version "v1" cannot be handled as a PersistentVolumeClaim: quantities must match the regular expression '^([+-]?[0-9.]+)([eEinumkKMGTP]*[-+]?[0-9]*)$'
Error from server (BadRequest): error when creating "mysql_deployment.yml": Service in version "v1" cannot be handled as a Service: strict decoding error: unknown field "metadata.app"
thor@jumphost ~$ 
```


## Solution:

Multiple errors in spelling / camelcase of kind,metadata,labels and indentations.

```yaml
apiVersion: v1 
kind: PersistentVolume 
metadata:
  name: mysql-pv
  labels:
    type: local
spec:
  storageClassName: standard       
  capacity:
    storage: 250Mi
  accessModes: 
    - ReadWriteOnce 
  hostPath:                       
    path: "/mnt/data"
  persistentVolumeReclaimPolicy: Retain
---    
apiVersion: v1 
kind: PersistentVolumeClaim       
metadata:                          
  name: mysql-pv-claim
  labels:
    app: mysql-app 
spec:                              
  storageClassName: standard       
  accessModes: 
    - ReadWriteOnce             
  resources:
    requests:
      storage: 250Mi
---
apiVersion: v1                    
kind: Service                      
metadata:
  name: mysql         
  labels:             
    app: mysql-app  
spec:
  type: NodePort
  ports:
    - targetPort: 3306
      port: 3306
      nodePort: 30011
  selector:                       
    app: mysql_app
    tier: mysql
---
apiVersion: apps/v1 
kind: Deployment                    
metadata:
  name: mysql-deployment           
  labels:                         
    app: mysql-app   
spec:
  selector:
    matchLabels:
      app: mysql-app 
      tier: mysql 
  strategy:
    type: Recreate 
  template:         
    metadata:
      labels:        
        app: mysql-app
        tier: mysql
    spec:            
      containers:
      - image: mysql:5.6 
        name: mysql
        env:              
        - name: MYSQL_ROOT_PASSWORD 
          valueFrom:     
            secretKeyRef:
              name: mysql-root-pass 
              key: password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-db-url 
              key: database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass 
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass 
              key: password
        ports:
        - containerPort: 3306              
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage  
          mountPath: /var/lib/mysql
      volumes:                        
      - name: mysql-persistent-storage
        persistentVolumeClaim: 
          claimName: mysql-pv-claim
```