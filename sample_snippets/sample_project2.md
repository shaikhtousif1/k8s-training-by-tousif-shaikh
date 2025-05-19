# 🔁 Dynatrace Pod Auto-Recycle – Bash Script + K8s CronJob

This automation runs as a **Kubernetes CronJob** and:
- Calls the **Dynatrace API** to check for open problems
- Looks for alerts related to **high pod failure rate**
- Parses the response and **deletes affected pods**
- Kubernetes automatically **recreates** them via Deployments

No Python. No Docker build. No webhook needed.

---

## 🧱 Components

| Component        | Purpose                                 |
|------------------|-----------------------------------------|
| Bash script      | Queries Dynatrace API & deletes pods    |
| Secret           | Stores Dynatrace API token              |
| ConfigMap        | Stores the Bash script                  |
| CronJob          | Runs the script every 5 minutes         |
| RBAC             | Allows pod deletion in the target NS    |

---

## 🔐 1. Create Secret with Dynatrace Token & API URL

```bash
kubectl create secret generic dynatrace-credentials \
  -n monitoring \
  --from-literal=DT_API_TOKEN='<your-dt-token>' \
  --from-literal=DT_BASE_URL='https://<your-env>.live.dynatrace.com'
````

---

## 📜 2. Create ConfigMap with Bash Script

Save the script as `dynatrace_pod_recycler.sh`:

```bash
#!/bin/bash

TOKEN=$(cat /mnt/secrets/DT_API_TOKEN)
BASE_URL=$(cat /mnt/secrets/DT_BASE_URL)
NAMESPACE=${TARGET_NAMESPACE:-default}

response=$(curl -s -X GET "${BASE_URL}/api/v2/problems?problemSelector=status(\"OPEN\")" \
  -H "Authorization: Api-Token $TOKEN" \
  -H "Content-Type: application/json")

echo "$response" | jq -c '.problems[]' | while read -r problem; do
  title=$(echo "$problem" | jq -r '.title')
  if [[ "$title" == *"Failure rate"* ]]; then
    echo "[ALERT] $title"
    affectedEntities=$(echo "$problem" | jq -r '.affectedEntities[]')
    for entity in $affectedEntities; do
      if [[ "$entity" == *"POD-"* ]]; then
        pod_id="${entity#*POD-}"
        pod_name=$(echo "$pod_id" | tr '[:upper:]' '[:lower:]')
        echo "[ACTION] Deleting pod $pod_name in namespace $NAMESPACE"
        kubectl delete pod "$pod_name" -n "$NAMESPACE"
      fi
    done
  fi
done
```

Create ConfigMap:

```bash
kubectl create configmap dynatrace-pod-recycler-script \
  --from-file=dynatrace_pod_recycler.sh=dynatrace_pod_recycler.sh \
  -n monitoring
```

---

## 📜 3. Create RBAC Permissions

```yaml
# rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dynatrace-bot
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-deleter
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-dynatrace-pod-deleter
  namespace: default
roleRef:
  kind: Role
  name: pod-deleter
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: dynatrace-bot
  namespace: monitoring
```

Apply it:

```bash
kubectl apply -f rbac.yaml
```

---

## ⏰ 4. Create the CronJob YAML

```yaml
# cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: dynatrace-pod-recycler
  namespace: monitoring
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: dynatrace-bot
          restartPolicy: OnFailure
          containers:
          - name: recycler
            image: bitnami/kubectl:latest
            command: ["/bin/bash", "/scripts/dynatrace_pod_recycler.sh"]
            volumeMounts:
              - name: script
                mountPath: /scripts
              - name: dt-secret
                mountPath: /mnt/secrets
                readOnly: true
            env:
              - name: TARGET_NAMESPACE
                value: default
          volumes:
            - name: script
              configMap:
                name: dynatrace-pod-recycler-script
                defaultMode: 0755
            - name: dt-secret
              secret:
                secretName: dynatrace-credentials
```

Apply it:

```bash
kubectl apply -f cronjob.yaml
```

---

## 🧪 5. Verify It’s Working

List cron jobs:

```bash
kubectl get cronjob -n monitoring
```

Force a run (to test):

```bash
kubectl create job --from=cronjob/dynatrace-pod-recycler dynatrace-pod-recycler-manual -n monitoring
```

Check pod logs:

```bash
kubectl logs -l job-name=dynatrace-pod-recycler-manual -n monitoring
```

---

## 🧠 Summary

| Task                     | Command                             |
| ------------------------ | ----------------------------------- |
| Create Secret            | `kubectl create secret ...`         |
| Create ConfigMap Script  | `kubectl create configmap ...`      |
| Deploy RBAC              | `kubectl apply -f rbac.yaml`        |
| Deploy CronJob           | `kubectl apply -f cronjob.yaml`     |
| Trigger CronJob manually | `kubectl create job --from=cronjob` |
| View Logs                | `kubectl logs -l job-name=...`      |

---

## ✅ Benefits of This Approach

* No need to run Flask app or expose services
* No Dockerfile to build or maintain
* Full control over interval and execution
* Secure via RBAC + Secret volume

---


