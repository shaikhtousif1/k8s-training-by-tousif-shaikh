# 🤖 Kubernetes Pod Auto-Recycle via Dynatrace Webhook

This project automates pod recovery for JVM/memory-related pod failures by integrating **Dynatrace alerts** with a **custom webhook** that deletes unhealthy pods. Kubernetes automatically recreates the pods, restoring service health.

---

## 📌 Use Case

- JVM garbage collection or memory issues cause a pod to exceed **60% failure rate**.
- Service degradation occurs even if a **single pod** misbehaves.
- Developers can't push fixes due to policy constraints.
- Manual pod recycling is too slow and error-prone.

✅ This automation deletes the bad pod **instantly** on alert, restoring performance.

---

## ⚙️ Architecture Overview

```text
Dynatrace Alert
   ↓ (webhook POST)
Webhook Receiver (Flask app in K8s)
   ↓
Parse pod name
   ↓
kubectl delete pod <name> -n <namespace>
   ↓
Kubernetes self-heals by recreating pod
````

---

## 🧩 Components

* Dynatrace alert + webhook integration
* Flask app running as a Kubernetes pod
* Kubernetes ServiceAccount with RBAC to delete pods
* NodePort Service for receiving webhook calls

---

## 🔐 Dynatrace Configuration

1. Go to **Settings → Anomaly Detection → Custom Metrics**
2. Create an alert for:

   * Metric: `builtin:kubernetes.pods.failed`
   * Condition: failure rate > `60%`
3. Go to **Settings → Integration → Problem Notifications → Add Notification**
4. Choose **Custom Webhook**

### Webhook Settings:

* **URL**: `http://<NodeIP>:30888/webhook`
* **Method**: `POST`
* **Header**:

  * Key: `X-Webhook-Secret`
  * Value: `tousif_secret_123`
* **Payload**:

```json
{
  "eventType": "{State}",
  "problemTitle": "{ProblemTitle}",
  "podName": "{ImpactedEntityName}",
  "failureRate": "{FailureRate}"
}
```

---

## 🛠️ How to Deploy the Webhook on Kubernetes

### 1. Create Secret for Webhook Auth

```bash
kubectl create secret generic webhook-env \
  --from-literal=WEBHOOK_SECRET=tousif_secret_123 \
  --from-literal=TARGET_NAMESPACE=default \
  -n monitoring
```

---

### 2. Create RBAC (Role + ServiceAccount)

```yaml
# rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-recycler
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: delete-pods
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: delete-pods-binding
  namespace: default
roleRef:
  kind: Role
  name: delete-pods
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: pod-recycler
  namespace: monitoring
```

```bash
kubectl apply -f rbac.yaml
```

---

### 3. Create Deployment for the Flask Webhook

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dynatrace-webhook
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dynatrace-webhook
  template:
    metadata:
      labels:
        app: dynatrace-webhook
    spec:
      serviceAccountName: pod-recycler
      containers:
      - name: webhook
        image: tousifdevops/dynatrace-webhook:latest  # replace with your image/ ACR url 
        envFrom:
        - secretRef:
            name: webhook-env
        ports:
        - containerPort: 8080
```

---

### 4. Expose the Webhook via NodePort

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: dynatrace-webhook
  namespace: monitoring
spec:
  type: NodePort
  selector:
    app: dynatrace-webhook
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30888
```

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

---

## 🐍 Flask Webhook App Code

```python
# app.py
from flask import Flask, request
import os
import subprocess

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def handle_webhook():
    if request.headers.get("X-Webhook-Secret") != os.getenv("WEBHOOK_SECRET"):
        return "Unauthorized", 403

    data = request.get_json()
    pod_name = data.get("podName", "").lower()
    namespace = os.getenv("TARGET_NAMESPACE", "default")

    if pod_name:
        print(f"Recycling pod: {pod_name}")
        subprocess.call(["kubectl", "delete", "pod", pod_name, "-n", namespace])
        return f"Deleted pod {pod_name}", 200
    return "Pod name not found", 400

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
```

---

## 🐳 Dockerfile

```Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY app.py .
RUN pip install flask
CMD ["python", "app.py"]
```

Build and push:

```bash
docker build -t tousifdevops/dynatrace-webhook:latest .
docker push tousifdevops/dynatrace-webhook:latest
```

---

## 🔐 Security Best Practices

* Use secrets instead of hardcoding tokens
* Use RBAC-scoped roles (`pods/delete` only in target namespace)
* Use `kubectl delete pod --grace-period=30` if graceful termination needed
* Protect your webhook with firewall or Ingress + Auth

---

## ✅ Result

Whenever a pod has failure rate > 60%:

* Dynatrace triggers alert
* Alert hits webhook (`/webhook`)
* Pod is deleted
* Kubernetes automatically recreates it
* Users never notice the blip 🧙‍♂️

