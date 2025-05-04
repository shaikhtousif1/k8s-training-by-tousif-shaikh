# 📘 Kubernetes Day 3 - Advanced Workloads, Storage, and Helm

---

## 📋 Recap of Day 2

- ✅ Deep Dive into Kubernetes Core Objects (Pods, Deployments, Services)
- ✅ Wrote and applied YAML manifests
- ✅ Explored ReplicaSets, ConfigMaps, Secrets, and Ingress
- ✅ KillerKoda hands-on with real-world object management

---

## 🎯 Today's Objectives

- Understand **Persistent Storage** in Kubernetes (PVC, PV)
- Learn advanced controllers: **StatefulSet** and **DaemonSet**
- Grasp **Kubernetes Networking** fundamentals (DNS, communication)
- Get hands-on with **Helm** for application packaging
- Deploy apps using **Helm Charts**

---

# 📦 Persistent Volumes & Claims

> **Definition**: Kubernetes abstracts storage using PV (provider) and PVC (consumer). Think of PV as the storage room, and PVC as the ticket to access it.

### 📄 PV Manifest Example:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
```

### 📄 PVC Manifest Example:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

---

# 🏢 StatefulSet

> **Definition**: Used to manage stateful applications (like databases) where each pod has a **stable identity**, hostname, and persistent storage.

### 📄 StatefulSet Manifest Example:
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: "mysql"
  replicas: 2
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: {{var.name}}
          image: mysql:{{app.vers}}
          volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: mysql-persistent-storage
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

---

# 🛠 DaemonSet

> **Definition**: Ensures that a copy of a pod runs on **every node** (or selected ones).

### 📄 DaemonSet Manifest Example:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-agent
spec:
  selector:
    matchLabels:
      name: log-agent
  template:
    metadata:
      labels:
        name: log-agent
    spec:
      containers:
        - name: log-agent
          image: fluent/fluentd
```

---

# 🌐 Kubernetes Networking 101

### 🔑 Key Concepts

- Each Pod has a unique IP address.
- CoreDNS is responsible for service name resolution.
- Pods can communicate directly across nodes.
- Services use label selectors to route traffic.
- Use `nslookup` and `curl` inside pods to debug.

### 🧪 Useful Commands

```bash
kubectl exec -it <pod-name> -- nslookup <service-name>
kubectl exec -it <pod-name> -- curl <service-name>:<port>
```

---

# 🔧 Helm - The Package Manager for Kubernetes

> Helm helps you define, install, and upgrade complex Kubernetes apps using pre-packaged charts.

### 📦 Helm Chart Structure
```
mychart/
├── Chart.yaml         # Metadata
├── values.yaml 
values-prod.yaml        # Configurable parameters
└── templates/         # Kubernetes manifests with Go templating
```

### 🧪 Helm Commands

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo nginx
helm install my-nginx bitnami/nginx
helm list
helm upgrade my-nginx bitnami/nginx --set service.type=LoadBalancer set --image=DEV_0053
helm uninstall my-nginx
```

---

# 🧪 Hands-on Tasks (KillerKoda)

✅ Create a PersistentVolume and PVC.  
✅ Deploy a StatefulSet (e.g., MySQL or Redis).  
✅ Deploy a DaemonSet (e.g., log collector).  
✅ Test intra-Pod communication with DNS and Services.  
✅ Install and customize an app using Helm.

---

## 🧠 Pro Tips

- `volumeClaimTemplates` are exclusive to StatefulSets.
- DaemonSet runs one pod per node by default.
- Always validate DNS with `nslookup` from inside a pod.
- Helm values can be overridden using `--set` or `-f custom-values.yaml`.

---

## 🔮 What's Next (Day 4 Teaser)

- Kubernetes Probes: Liveness, Readiness, Startup  
- Resource Limits & Requests  
- Autoscaling (HPA, VPA)  
- GitOps with ArgoCD  
- CI/CD in Kubernetes

---

## 📂 Folder Structure for Practice

```
k8s-day3/
├── pvc.yaml
├── statefulset.yaml
├── daemonset.yaml
├── networking-test.yaml
├── helm/
│   └── mychart/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
└── README.md
```

---

> _"With StatefulSets, storage gets personal. With DaemonSets, everyone’s included. And with Helm? That’s your Kubernetes cheat code."_ 🧙‍♂️
```