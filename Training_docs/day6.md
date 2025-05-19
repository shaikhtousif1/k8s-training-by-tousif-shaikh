
# 🚦 Kubernetes Day 6 – Taints & Tolerations + Intro to Observability

---

## 🎯 Objectives

By the end of Day 6, you'll be able to:

- Use **taints and tolerations** to control pod scheduling
- Isolate workloads based on node characteristics
- Understand the **basics of observability** in Kubernetes
- Set the stage for Day 7: full observability stack with logging, metrics & tracing

---


# 🧲 Section 1: Taints, Tolerations & Node Affinity

---

## 💡 What is a Taint?

A **taint** is added to a node to **repel** pods.  
Only those pods that have a matching **toleration** are allowed to be scheduled on it.

```bash
kubectl taint nodes <node-name> dedicated=infra:NoSchedule
````

---

## 🧯 What is a Toleration?

A **toleration** in a pod's spec lets it tolerate a taint:

```yaml
tolerations:
- key: "dedicated"
  operator: "Equal"
  value: "infra"
  effect: "NoSchedule"
```

---

## 🤝 Node Labels + Node Affinity

**Labels** are key-value pairs added to nodes.

```bash
kubectl label node <node-name> type=gpu
```

Then you can **force pods to prefer or require** those nodes using `nodeAffinity`.

---

## 🧪 Example: Pod with Toleration + Node Affinity

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-toleration-pod
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "infra"
    effect: "NoSchedule"
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: "type"
            operator: "In"
            values:
            - gpu
```

---

## 🤔 Difference Between Taints & Node Affinity

| Feature          | Taints & Tolerations          | Node Affinity                                  |
| ---------------- | ----------------------------- | ---------------------------------------------- |
| Who defines it?  | Node adds taint               | Pod defines affinity                           |
| Purpose          | Repel unwanted pods           | Attract pod to specific nodes                  |
| Default behavior | Block pods unless tolerated   | Pod will be scheduled elsewhere if not matched |
| Use case         | Isolation, critical workloads | Placement preferences (e.g., GPU)              |

---

## 🔧 Real World Combo Example

```bash
# Taint the node
kubectl taint nodes node1 dedicated=infra:NoSchedule

# Label the same node
kubectl label node node1 type=gpu
```

Then use a pod like this:

```yaml
tolerations:
- key: "dedicated"
  operator: "Equal"
  value: "infra"
  effect: "NoSchedule"
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: "type"
          operator: "In"
          values:
          - gpu
```

---

## ✅ Recap: Scheduling Controls

| Mechanism      | Purpose                       | Defined By |
| -------------- | ----------------------------- | ---------- |
| Node Taint     | Repel pods from node          | Node       |
| Pod Toleration | Allow pod on tainted node     | Pod        |
| Node Affinity  | Prefer specific nodes for pod | Pod        |
| Node Label     | Basis for affinity/toleration | Node       |

---

## 🔍 Verify Node Details

```bash
kubectl get nodes --show-labels
kubectl describe node <node-name> | grep -i taints
```

---

## ✅ Practice Steps for KillerCoda

```bash
# Step 1: Label and Taint a node
kubectl label node $(kubectl get nodes -o name | head -1) type=gpu
kubectl taint node $(kubectl get nodes -o name | head -1) dedicated=infra:NoSchedule

# Step 2: Apply the pod with both toleration and affinity
kubectl apply -f affinity-toleration-pod.yaml

# Step 3: Verify pod placement
kubectl get pods -o wide
```

# 📡 Section 2: Intro to Observability in Kubernetes

---

## 🤔 Why Observability?

As your system grows, you need to answer:

* What’s running slow?
* Why is this pod restarting?
* Where is the bottleneck?

**Observability = Seeing inside your system’s behavior.**

---

## 🧱 3 Pillars of Observability

| Pillar  | What It Shows         | Common Tools         |
| ------- | --------------------- | -------------------- |
| Logs    | What happened?        | Loki, Fluentbit, EFK |
| Metrics | What's happening now? | Prometheus, Grafana  |
| Traces  | How it happened?      | Jaeger, Tempo        |

---

## 🛠 Install Prometheus & Grafana (Optional for Preview)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install k8s-monitoring prometheus-community/kube-prometheus-stack
```

```bash
kubectl port-forward svc/k8s-monitoring-grafana 3000:80
```

* Username: `admin`
* Password: `prom-operator`

---

## 🆚 Monitoring vs Observability

| Monitoring              | Observability                |
| ----------------------- | ---------------------------- |
| "Is it up?"             | "Why is it broken or slow?"  |
| Predefined dashboards   | Ad-hoc root cause analysis   |
| Limited insight         | Deep system understanding    |
| Known problem detection | Unknown-unknown discovery 🔍 |

---

## 🧠 Summary: Observability Preview

| Concept           | Covered?          |
| ----------------- | ----------------- |
| Logs              | ✅ Basic explained |
| Metrics           | ✅ With Prometheus |
| Traces            | ✅ Conceptual      |
| Why Observability | ✅ Yes             |

---

## 📂 Folder Structure – Day 6

```
k8s-day6/
├── pod-toleration.yaml
├── tainted-node.sh
├── prometheus-grafana-install.sh
├── README.md
```

---

## ⏭️ What's Next – Day 7 Sneak Peek

* Setup full **Prometheus stack**
* Add **Loki** for logs and **Tempo** for traces
* Understand **HWT: How, What, Trigger**
* Create **custom dashboards** and alerts in Grafana
* Observability in **multi-service debugging**

---

## 🔥 Final Quote

> "Taints prevent chaos. Observability reveals it. Together, they give you control and insight."
