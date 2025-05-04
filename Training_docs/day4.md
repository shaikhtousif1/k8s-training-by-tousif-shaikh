# 📘 Kubernetes Day 4 - Probes, Scaling, and GitOps (Production Ready K8s)

---

## 📋 Recap of Day 3

- ✅ Worked with Persistent Volumes and Claims
- ✅ Deployed Stateful and DaemonSets
- ✅ Explored Kubernetes Networking
- ✅ Introduced Helm and deployed applications using Charts

---

## 🎯 Today's Objectives

- Learn about **Probes** (Liveness, Readiness, Startup)
- Understand **Resource Requests and Limits**
- Implement **Horizontal Pod Autoscaling**
- Get introduced to **Vertical Pod Autoscaling**
- Understand **GitOps with ArgoCD**
- Learn best practices for **production-ready clusters**

---

# 🔍 Kubernetes Probes

Probes are like periodic health check-ups for containers. Kubernetes uses them to determine **if a container is alive and well**, or just chilling and doing nothing. There are three types:

### 1. Liveness Probe
> Checks if the app is still running. If it fails repeatedly, the container is restarted.

### 2. Readiness Probe
> Checks if the app is ready to accept traffic. If it fails, the pod is removed from Service endpoints.

### 3. Startup Probe
> Used for apps that take time to start. While this probe is failing, liveness & readiness are **disabled**.

### ✅ Example: All 3 Probes
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5

startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 10
````

### 🔧 Commands to Test Probes

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

---

# 📦 Resource Requests & Limits

> Resource management ensures **fair scheduling** and prevents a pod from becoming a CPU/memory hog.

### ✅ Syntax Example:

```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"
```

| Term     | Purpose                           |
| -------- | --------------------------------- |
| Requests | Minimum resources pod needs       |
| Limits   | Maximum resources pod can consume |

Kubernetes uses **requests** to schedule pods and enforces **limits** at runtime.

## Day 4 Sample

- [Day 4 Sample](../sample_snippets/day4_sample.yaml)

---

# 📈 Horizontal Pod Autoscaler (HPA)

> Automatically scales the number of pods based on CPU or custom metrics.

### ✅ Prerequisites:

* Metrics server must be running in the cluster

### ✅ Create HPA Example:

```bash
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=1 --max=10
```

### ✅ YAML Example:

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 50
```

### 🔍 Commands to Monitor

```bash
kubectl get hpa
kubectl describe hpa nginx-hpa
```

---

# 📏 Vertical Pod Autoscaler (VPA) - Intro

> VPA adjusts **resource requests/limits** of pods based on usage.

* Still not widely used in production for long-lived apps
* Works better for **batch or low-availability pods**
* Can be used in `recommendation`, `auto`, or `off` mode

# Day 4 - Continue

[Day 4 - HPA in details ](./day4-hpa.md)
---

# 🚀 GitOps with ArgoCD

> ArgoCD = Git as the single source of truth for your Kubernetes deployments

### 🔁 How it Works

1. You store manifests or Helm charts in Git.
2. ArgoCD **watches the Git repo** and **syncs** to the cluster.
3. Any drift between Git and the cluster is flagged or auto-corrected.

### 📦 Key Benefits:

* Full traceability of deployments
* Rollbacks are just Git rollbacks!
* Auditable, reproducible, and team-friendly

### ✅ ArgoCD Setup (Conceptual)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access ArgoCD UI (port-forward)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login
argocd login localhost:8080
```

---

# 📘 Hands-On Tasks

✅ Add Liveness, Readiness, and Startup probes to a running Pod
✅ Set resource requests/limits for a Deployment
✅ Install metrics-server and configure an HPA
✅ Simulate CPU load and observe autoscaling
✅ Set up ArgoCD and deploy an app using a GitHub repo

---

# 📂 Folder Structure Suggestion

```
k8s-day4/
├── probes.yaml
├── resources.yaml
├── hpa.yaml
├── vpa.yaml (optional)
├── argocd/
│   ├── app.yaml
│   └── values.yaml
└── README.md
```

---

## 🧠 Tips to Explain During Interviews

* "Probes let Kubernetes **decide the health** of the app – not you."
* "Resource requests **influence scheduling**, limits **enforce control**."
* "HPA scales pods *horizontally*, VPA tweaks resource *vertically*."
* "With ArgoCD, **Git becomes the control plane**, enabling GitOps practices."

---

## 🧠 Final Production Readiness Checklist (Mini Version)

* [ ] Health Probes configured
* [ ] Resource requests & limits defined
* [ ] HPA enabled for web-facing apps
* [ ] Secrets managed securely (not hardcoded)
* [ ] Logging & monitoring in place
* [ ] Helm charts or Kustomize used for templating
* [ ] GitOps enabled for auditability (ArgoCD, Flux)

---

> *"GitOps doesn't just bring order to chaos — it makes Kubernetes deployments boring. And boring is beautiful in production."* 🤓

