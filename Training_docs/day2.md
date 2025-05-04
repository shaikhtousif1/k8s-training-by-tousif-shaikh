# 📘 Kubernetes Day 2 - Deep Dive into Kubernetes Objects

---

## 📋 Recap of Day 1

- ✅ Kubernetes Architecture Overview
- ✅ Basic Kubernetes Commands (`kubectl get`, `describe`, `apply`, `delete`)
- ✅ Docker vs Traditional VMs
- ✅ Simple Deployment Hands-on

---

## 🎯 Today's Objectives

- Understand **Kubernetes Objects** and how they interact.
- Learn to write and apply **Manifest files** (YAMLs).
- Perform real-world tasks on a Kubernetes Cluster (KillerKoda hands-on).
- Understand Kubernetes Controllers and their role.

---

# 🧩 Core Kubernetes Objects - In-Depth

---

## 1. Pod

> **Definition**:  
> A Pod is the smallest deployable object in Kubernetes, representing a single instance of a running process in your cluster.

**Key Points:**
- One Pod = one or more containers.
- Containers inside a Pod share:
  - Network IP
  - Storage Volumes
- Pods are ephemeral. (Temporary, recreated if fail)

**Simple Pod Manifest:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: nginx-container
      image: nginx
      ports:
        - containerPort: 80
```

**Important Commands:**
```bash
kubectl apply -f pod.yaml
kubectl get pods
kubectl describe pod mypod
kubectl delete pod mypod
```

---

## 2. ReplicaSet

> **Definition**:  
> Ensures that a specified number of Pod replicas are running at any given time.

**Key Points:**
- It replaces failed Pods automatically.
- Mostly managed automatically via Deployments.

**Sample Manifest:**

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: my-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
```

---

## 3. Deployment

> **Definition**:  
> A Deployment manages ReplicaSets and provides declarative updates to Pods and ReplicaSets.

**Key Points:**
- Handles scaling (up/down).
- Supports rolling updates and rollbacks.
- The recommended way to deploy applications.

**Deployment Manifest:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

**Important Commands:**
```bash
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl rollout status deployment nginx-deployment
kubectl scale deployment nginx-deployment --replicas=5
kubectl rollout undo deployment nginx-deployment
```

---

## 4. Service

> **Definition**:  
> An abstraction which defines a logical set of Pods and a policy by which to access them.

**Types of Services:**
| Type           | Purpose                                 |
|----------------|-----------------------------------------|
| ClusterIP      | Internal access within the cluster      |
| NodePort       | Exposes service on a port on each node  |
| LoadBalancer   | Provision external load balancer (Cloud) |
| ExternalName   | Maps Service to external DNS name       |

**Simple NodePort Service Manifest:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30036
```

**Important Commands:**
```bash
kubectl apply -f service.yaml
kubectl get services
kubectl describe svc nginx-service
```

---

## 5. ConfigMap and Secret

| ConfigMap  | Secret         |
|------------|----------------|
| Stores non-sensitive config like URLs | Stores sensitive info like passwords |
| Data is plain text | Data is base64 encoded |

**Example ConfigMap:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: mongodb://db.example.com:27017
```

**Example Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  password: bXlwYXNzd29yZA==   # (this is base64 of 'mypassword')
```

---

## 6. Ingress

> **Definition**:  
> Exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.

**Ingress Example:**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```

---

# 🔥 Hands-on Tasks You Can Perform on KillerKoda:

✅ Create a Pod manually using `kubectl run` and using YAML.

✅ Create a Deployment, scale it up and down, then rollback.

✅ Create a NodePort Service and access the app externally.

✅ Create a ConfigMap and a Secret and use them in a Pod.

✅ (Advanced) Create an Ingress and map it to your Service.

---

# 🧠 Deep Side Notes - Manifest Writing Tips

- Always match `selector.matchLabels` in Deployment with `labels` inside Pod template.
- `spec.template` is the actual Pod spec inside ReplicaSet/Deployment.
- Services connect to Pods **based on label selectors**, not Pod names.
- Secrets must have data encoded in **base64** format.
- Ingress Controllers must be installed separately (like nginx-ingress).

---

# 🚀 What's Coming Next (Day 3 Teaser)

- Volumes and Persistent Volumes
- StatefulSets (Managing Stateful Applications)
- DaemonSets (One Pod Per Node)
- Kubernetes Networking Concepts
- Helm Charts for application packaging

---

> _"Kubernetes is simple — once you understand the invisible hands (Controllers) running the show!"_ 💬

---

# 📂 Folder Structure Suggestion (for Practice)

```plaintext
k8s-day2/
├── pod.yaml
├── replicaset.yaml
├── deployment.yaml
├── service.yaml
├── configmap.yaml
├── secret.yaml
├── ingress.yaml
└── README.md
```

# Day 2 - Continue
[Day 2 - Kubeconfig Concept](./day2_kubeconfig.md)