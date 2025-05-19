# 🔭 Kubernetes Day 7 – Full Observability: Metrics, Logs & Traces

---

## 🎯 Objectives

By the end of this chapter, you’ll be able to:

- Deploy full observability stack: **Prometheus, Grafana, Loki, Tempo**
- Understand **How–What–Trigger (HWT)** model of observability
- Build **dashboards** & setup **alerts**
- Trace a request from start to finish
- Create a local or cloud-based **demo setup**

---

## 🧠 What is Observability?

Observability answers:  
> **"What is my system doing right now?"**  
> **"Why did it behave that way?"**

It’s made up of:

| Pillar   | Purpose                    | Tools             |
|----------|----------------------------|-------------------|
| Logs     | What happened?             | Loki, Fluentbit   |
| Metrics  | What’s happening now?      | Prometheus        |
| Traces   | How it happened end-to-end | Tempo, Jaeger     |

---

## 🧩 The HWT Framework

| HWT        | Explanation                              |
|------------|------------------------------------------|
| **How**    | How is the system behaving overall?      |
| **What**   | What changed recently?                   |
| **Trigger**| What triggered the issue or alert?       |

Use this flow when debugging or designing alerts.

---

# 🛠️ Setup: The Observability Stack

We'll use the **Kube-Prometheus Stack** for metrics and Grafana  
Add **Loki** for logs and **Tempo** for tracing.

---

## 📦 Step 1: Install Prometheus + Grafana

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install k8s-monitoring prometheus-community/kube-prometheus-stack
````

---

## 📦 Step 2: Install Loki + Tempo

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack
helm install tempo grafana/tempo
```

---

## 📟 Step 3: Port Forward Grafana

```bash
kubectl port-forward svc/k8s-monitoring-grafana 3000:80
```

Visit `http://localhost:3000`
Login: `admin / prom-operator`

---

## 🧪 Step 4: Explore

| What to Try                        | Where               |
| ---------------------------------- | ------------------- |
| View node/pod CPU                  | Grafana Dashboards  |
| Check logs via Loki                | Explore tab         |
| Add alert: Pod restarts > 3        | Alerting → New Rule |
| Tempo tracing (advanced apps only) | Tempo data source   |

---

## 🗃️ Sample Folder Structure

```
k8s-day7-observability/
├── prometheus-values.yaml
├── loki-values.yaml
├── tempo-values.yaml
├── alerts/
│   └── high-restart-rate.yaml
├── dashboards/
│   └── node-metrics.json
├── README.md
```

---

## 📡 Setup for Practice / Demo

### 🧪 Option 1: Local with Kind

```bash
kind create cluster --name obs-demo
```

Install observability stack via Helm (as above)

### ☁️ Option 2: Practice on:

| Platform                                         | Link                              |
| ------------------------------------------------ | --------------------------------- |
| [KillerCoda](https://killercoda.com)             | Instant Kubernetes playground     |
| [Play with K8s](https://labs.play-with-k8s.com/) | 1-node labs (limited Helm)        |
| [Minikube](https://minikube.sigs.k8s.io/)        | Full-featured local playground    |
| [Civo](https://www.civo.com/)                    | Free trial K8s clusters (2 weeks) |
| [DigitalOcean](https://do.co/k8s)                | Cloud K8s (pay-as-you-go)         |

---

## 🎥 Bonus: Recording a Demo

Use tools like:

* **K9s** for CLI-based visual demo
* **Simple screen recording** (OBS Studio or CleanShot)
* **Grafana Explore Tab** walkthrough with narration
* Highlight HWT via a pod restart example

---

## 📢 Tips for Demos

* Use a **sample microservice app** (e.g. `hotrod`, `sock-shop`)
* Induce issues (`kubectl delete pod`, stress test)
* Show logs, metrics & trace correlation in Grafana

---

## 🔥 Final Takeaway

> “Logs show you the past, metrics tell you the now, traces reveal the journey. Together, they’re your debugging superpower.” ⚡

---

## ✅ Day 7 Summary

| Feature          | Covered |
| ---------------- | ------- |
| Prometheus Setup | ✅       |
| Loki Logs        | ✅       |
| Tempo Tracing    | ✅       |
| Dashboards       | ✅       |
| Alerts           | ✅       |
| HWT Framework    | ✅       |

---
# Day 7 - Continue

[Day 7 - Observability Stack Details](./day7_cont.md)

---
## 📂 Extra: `alerts/high-restart-rate.yaml`

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: pod-restart-alerts
  labels:
    release: k8s-monitoring
spec:
  groups:
  - name: pod-alerts
    rules:
    - alert: HighPodRestartRate
      expr: increase(kube_pod_container_status_restarts_total[5m]) > 3
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "High pod restart rate detected"
        description: "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is restarting frequently."
````

---



