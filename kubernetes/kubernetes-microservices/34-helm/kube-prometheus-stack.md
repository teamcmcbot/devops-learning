# Kube-Prometheus-Stack

## Install Kube-Prometheus-Stack via OCI

```bash
helm install monitoring oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack
Pulled: ghcr.io/prometheus-community/charts/kube-prometheus-stack:79.5.0
Digest: sha256:c17227aa021929eea997bfa5e33338aa16778e311fbe4a510ac7629fae79d6c1
I1114 11:31:50.023687   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:50.023706   45368 warnings.go:110] "Warning: unrecognized format \"int32\""
I1114 11:31:50.201918   45368 warnings.go:110] "Warning: unrecognized format \"int32\""
I1114 11:31:50.201965   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:50.301931   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:50.301953   45368 warnings.go:110] "Warning: unrecognized format \"int32\""
I1114 11:31:50.327738   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:50.536359   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:50.536384   45368 warnings.go:110] "Warning: unrecognized format \"int32\""
I1114 11:31:50.817646   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:50.817673   45368 warnings.go:110] "Warning: unrecognized format \"int32\""
I1114 11:31:50.894423   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:51.126114   45368 warnings.go:110] "Warning: unrecognized format \"int32\""
I1114 11:31:51.126141   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:51.206271   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:51.415239   45368 warnings.go:110] "Warning: unrecognized format \"int64\""
I1114 11:31:51.415265   45368 warnings.go:110] "Warning: unrecognized format \"int32\""
I1114 11:32:02.438556   45368 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"
I1114 11:32:02.438569   45368 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"
I1114 11:32:02.438604   45368 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"
I1114 11:32:02.439376   45368 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"
I1114 11:32:02.439435   45368 warnings.go:110] "Warning: spec.SessionAffinity is ignored for headless services"
NAME: monitoring
LAST DEPLOYED: Fri Nov 14 11:31:51 2025
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=monitoring"

Get Grafana 'admin' user password by running:

  kubectl --namespace default get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace default get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring" -oname)
  kubectl --namespace default port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace default -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo


Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

## After Installation

```bash
kubectl get all -o wide
NAME                                                         READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
pod/alertmanager-monitoring-kube-prometheus-alertmanager-0   2/2     Running   0          25m   10.244.0.14    minikube   <none>           <none>
pod/monitoring-grafana-5b87668f77-b5lcm                      3/3     Running   0          26m   10.244.0.11    minikube   <none>           <none>
pod/monitoring-kube-prometheus-operator-5cdc56d76c-prl7s     1/1     Running   0          26m   10.244.0.10    minikube   <none>           <none>
pod/monitoring-kube-state-metrics-5459bf8fdf-8pk6z           1/1     Running   0          26m   10.244.0.12    minikube   <none>           <none>
pod/monitoring-prometheus-node-exporter-dgrh4                1/1     Running   0          26m   192.168.49.2   minikube   <none>           <none>
pod/prometheus-monitoring-kube-prometheus-prometheus-0       2/2     Running   0          25m   10.244.0.15    minikube   <none>           <none>

NAME                                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
service/alertmanager-operated                     ClusterIP   None             <none>        9093/TCP,9094/TCP,9094/UDP   25m   app.kubernetes.io/name=alertmanager
service/kubernetes                                ClusterIP   10.96.0.1        <none>        443/TCP                      81m   <none>
service/monitoring-grafana                        ClusterIP   10.100.247.82    <none>        80/TCP                       26m   app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=grafana
service/monitoring-kube-prometheus-alertmanager   ClusterIP   10.98.178.169    <none>        9093/TCP,8080/TCP            26m   alertmanager=monitoring-kube-prometheus-alertmanager,app.kubernetes.io/name=alertmanager
service/monitoring-kube-prometheus-operator       ClusterIP   10.110.156.60    <none>        443/TCP                      26m   app=kube-prometheus-stack-operator,release=monitoring
service/monitoring-kube-prometheus-prometheus     ClusterIP   10.105.221.163   <none>        9090/TCP,8080/TCP            26m   app.kubernetes.io/name=prometheus,operator.prometheus.io/name=monitoring-kube-prometheus-prometheus
service/monitoring-kube-state-metrics             ClusterIP   10.101.128.242   <none>        8080/TCP                     26m   app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=kube-state-metrics
service/monitoring-prometheus-node-exporter       ClusterIP   10.101.147.246   <none>        9100/TCP                     26m   app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=prometheus-node-exporter
service/prometheus-operated                       ClusterIP   None             <none>        9090/TCP                     25m   app.kubernetes.io/name=prometheus

NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE   CONTAINERS      IMAGES                                     SELECTOR
daemonset.apps/monitoring-prometheus-node-exporter   1         1         1       1            1           kubernetes.io/os=linux   26m   node-exporter   quay.io/prometheus/node-exporter:v1.10.2   app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=prometheus-node-exporter

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                                            IMAGES                                                                                                       SELECTOR
deployment.apps/monitoring-grafana                    1/1     1            1           26m   grafana-sc-dashboard,grafana-sc-datasources,grafana   quay.io/kiwigrid/k8s-sidecar:1.30.10,quay.io/kiwigrid/k8s-sidecar:1.30.10,docker.io/grafana/grafana:12.2.1   app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=grafana
deployment.apps/monitoring-kube-prometheus-operator   1/1     1            1           26m   kube-prometheus-stack                                 quay.io/prometheus-operator/prometheus-operator:v0.86.2                                                      app=kube-prometheus-stack-operator,release=monitoring
deployment.apps/monitoring-kube-state-metrics         1/1     1            1           26m   kube-state-metrics                                    registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0                                                app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=kube-state-metrics

NAME                                                             DESIRED   CURRENT   READY   AGE   CONTAINERS                                            IMAGES                                                                                                       SELECTOR
replicaset.apps/monitoring-grafana-5b87668f77                    1         1         1       26m   grafana-sc-dashboard,grafana-sc-datasources,grafana   quay.io/kiwigrid/k8s-sidecar:1.30.10,quay.io/kiwigrid/k8s-sidecar:1.30.10,docker.io/grafana/grafana:12.2.1   app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=grafana,pod-template-hash=5b87668f77
replicaset.apps/monitoring-kube-prometheus-operator-5cdc56d76c   1         1         1       26m   kube-prometheus-stack                                 quay.io/prometheus-operator/prometheus-operator:v0.86.2                                                      app=kube-prometheus-stack-operator,pod-template-hash=5cdc56d76c,release=monitoring
replicaset.apps/monitoring-kube-state-metrics-5459bf8fdf         1         1         1       26m   kube-state-metrics                                    registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0                                                app.kubernetes.io/instance=monitoring,app.kubernetes.io/name=kube-state-metrics,pod-template-hash=5459bf8fdf

NAME                                                                    READY   AGE   CONTAINERS                     IMAGES
statefulset.apps/alertmanager-monitoring-kube-prometheus-alertmanager   1/1     25m   alertmanager,config-reloader   quay.io/prometheus/alertmanager:v0.29.0,quay.io/prometheus-operator/prometheus-config-reloader:v0.86.2
statefulset.apps/prometheus-monitoring-kube-prometheus-prometheus       1/1     25m   prometheus,config-reloader     quay.io/prometheus/prometheus:v3.7.3,quay.io/prometheus-operator/prometheus-config-reloader:v0.86.2
```
