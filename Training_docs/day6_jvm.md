# ☕ JVM Memory Internals & Debugging in Kubernetes

---

## 📚 JVM Memory Model Overview

The Java Virtual Machine (JVM) memory is divided into several key areas:

### 🔹 1. Heap Memory (for Objects)

* Divided into **Young Generation** and **Old Generation**
* **Young Gen** → Eden + Survivor spaces (frequent GC here)
* **Old Gen** → Long-lived objects

### 🔹 2. Non-Heap Memory

* **Metaspace** → Class metadata
* **Code Cache** → JIT compiled code

### 🔹 3. Stack Memory

* One stack per thread for method calls, local variables

---

## 🔍 Common Memory Issues in JVM

| Issue                  | Description                                     |
| ---------------------- | ----------------------------------------------- |
| OutOfMemoryError (OOM) | Heap or Metaspace is full                       |
| High GC activity       | GC running too frequently → app slow            |
| Thread contention      | Too many threads → increased memory/CPU         |
| Memory leaks           | Objects held unintentionally → memory not freed |

---

## 🐳 JVM in Kubernetes Context

* Java applications run as containers inside pods.
* Memory is managed by both JVM **and** Kubernetes (cgroup limits).
* Container limits (requests/limits) must be tuned to JVM memory settings.

### JVM Options in K8s:

```yaml
containers:
  - name: my-java-app
    image: my-java-app:latest
    resources:
      limits:
        memory: "1Gi"
    env:
      - name: JAVA_TOOL_OPTIONS
        value: "-XX:+UseContainerSupport -Xmx512m -Xms256m"
```

> `-XX:+UseContainerSupport` ensures JVM respects container memory limits

---

## 🧠 JVM Memory Debugging Tools

### ✅ Heap Dump (memory snapshot)

* Use to analyze memory leaks, object retention
* Tools:

  * `jmap -dump:live,format=b,file=heap.hprof <pid>`
  * Eclipse MAT, VisualVM, JProfiler

### ✅ Thread Dump

* Snapshot of all running threads
* Helps find deadlocks, blocking, high CPU usage
* Tools:

  * `jstack <pid>`
  * VisualVM, IntelliJ Profiler

---

## 🧪 Collecting Dumps in Kubernetes

### 🔹 Step 1: Find pod name

```bash
kubectl get pods -l app=my-java-app
```

### 🔹 Step 2: Exec into pod

```bash
kubectl exec -it my-java-app-pod -- bash
```

### 🔹 Step 3: Identify PID

```bash
ps aux | grep java
```

### 🔹 Step 4: Generate Heap Dump

```bash
jmap -dump:format=b,file=/tmp/heap.hprof <pid>
```

### 🔹 Step 5: Copy it from pod

```bash
kubectl cp my-java-app-pod:/tmp/heap.hprof ./heap.hprof
```

> You can then open the `.hprof` file in Eclipse MAT to analyze retained objects and GC roots.

---

## 📉 Monitoring JVM with Prometheus + Grafana

* Use **JMX Exporter** to expose JVM metrics
* Mount it as a Java agent:

```yaml
containers:
  - name: my-java-app
    image: my-java-app:latest
    ports:
      - containerPort: 9404
    env:
      - name: JAVA_TOOL_OPTIONS
        value: "-javaagent:/opt/jmx-exporter/jmx_prometheus_javaagent.jar=9404:/opt/jmx-exporter/config.yaml"
```

* Metrics include:

  * JVM memory usage
  * GC count/time
  * Thread count
  * Class loading

---

## ⚠️ Best Practices

* Match K8s memory limits with `-Xmx` (avoid OOMKill)
* Enable GC logs (`-Xlog:gc*` or `-XX:+PrintGCDetails`)
* Monitor GC and heap with dashboards
* Automate heap dump collection on `OutOfMemoryError`
* Consider `Kubernetes downward API` to tune memory dynamically

---

## 📦 Summary

| Task                  | Tool / Command                              |
| --------------------- | ------------------------------------------- |
| Check memory config   | JAVA\_TOOL\_OPTIONS, jcmd, jmap             |
| Dump heap             | `jmap` + `kubectl cp`                       |
| Analyze thread issues | `jstack` + VisualVM                         |
| Monitor JVM runtime   | Prometheus + JMX Exporter + Grafana         |
| Prevent container OOM | Align `-Xmx` with `resources.limits.memory` |
