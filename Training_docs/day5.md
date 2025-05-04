# 🔐 Kubernetes Day 5 - Security, Authentication & Authorization

---

## 🎯 Objectives

By the end of Day 5, you'll be able to:

- Understand **how users and service accounts authenticate** in K8s
- Define who can do what using **RBAC (Role-Based Access Control)**
- Secure your workloads using **Pod Security, Network Policies, and Secrets**
- Learn how to manage **access at scale**
- Fix the security gaps we skipped in earlier days 😉

---

## 🧾 Recap of Earlier Gaps

| Topic                      | What's Missing                  | Covered Today? |
|----------------------------|----------------------------------|----------------|
| Webhook Authentication     | Validating secret headers only   | ✅ Use real auth |
| Pod Deletion Authorization | Used RBAC for specific pod ops   | ✅ Explained fully |
| Secret Handling            | Used `kubectl create secret`     | ✅ Now encrypted |
| ServiceAccount Behavior    | Just used by name                | ✅ Now explained |

---

# 🧑‍💼 Authentication in Kubernetes

Kubernetes **does not manage users itself**. Authentication happens through:

| Method             | Description                                    |
|--------------------|------------------------------------------------|
| Client Certificates| Common for admin access via kubeconfig        |
| Static Tokens      | Basic, not recommended for production          |
| OIDC               | Integrate with identity providers (e.g. Azure AD, Okta) |
| ServiceAccounts    | For workloads inside the cluster               |

### 🔐 Example: kubeconfig with Client Cert
```yaml
users:
- name: tousif-user
  user:
    client-certificate: /home/tousif/.kube/tousif.crt
    client-key: /home/tousif/.kube/tousif.key
````

---

# 🛂 Authorization in Kubernetes

After authentication, Kubernetes asks:
**"Is this user allowed to do this action?"**

This is handled via **RBAC (Role-Based Access Control)**.

---

## 🧱 RBAC Concepts

| Term                   | Description                                        |
| ---------------------- | -------------------------------------------------- |
| **Role**               | Grants permissions within a namespace              |
| **ClusterRole**        | Grants permissions cluster-wide                    |
| **RoleBinding**        | Assigns a Role to a user/serviceaccount            |
| **ClusterRoleBinding** | Binds ClusterRole to user/SA across all namespaces |

---

## 🧪 Example: Role + RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: tousif
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## 🧑‍🔧 ServiceAccount Authentication (for Pods)

When a pod runs, it gets a **ServiceAccount token mounted automatically** at `/var/run/secrets/kubernetes.io/serviceaccount/token`.

You can verify it from inside the pod:

```bash
cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
```

Assign RBAC to ServiceAccounts (like our `pod-recycler`) using RoleBinding or ClusterRoleBinding.

---

# 🔑 Secrets & Secure Config

Avoid using `env` variables or plaintext in YAML.

### ✅ Better Approach

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-creds
        key: password
```

Create secret with encryption at rest enabled (on supported clusters):

```bash
kubectl create secret generic db-creds --from-literal=password=SuperSecure123
```

---

# 📡 Network Policies

By default, **all pods can talk to all other pods** 😬
Use **NetworkPolicy** to restrict traffic between pods by:

* Namespace
* Labels
* Ports

### Example: Allow ingress only from same namespace

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-other-namespaces
  namespace: my-app
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
```

> 🔐 Requires a CNI that supports NetworkPolicy (like Calico, Cilium)

---

# 🧰 Pod Security Standards (PSS)

Enforced at namespace level:

| Mode           | What it does                             |
| -------------- | ---------------------------------------- |
| **Privileged** | Full access, dangerous                   |
| **Baseline**   | Prevents risky settings (e.g., hostPath) |
| **Restricted** | Strongest, blocks privilege escalation   |

```bash
kubectl label namespace dev pod-security.kubernetes.io/enforce=restricted
```

---

# 🔍 Tools for Security Checks

| Tool                 | Use Case                  |
| -------------------- | ------------------------- |
| `kube-bench`         | CIS Benchmark testing     |
| `kubectl auth can-i` | Check RBAC permissions    |
| `kubesec.io`         | Static YAML scanning      |
| `OPA/Gatekeeper`     | Policy enforcement engine |

---

# 🧪 Bonus: Test What a User Can Do

```bash
kubectl auth can-i delete pods --as=tousif -n default
```

---

## ✅ Summary

| Concept                | Covered? |
| ---------------------- | -------- |
| Authentication         | ✅        |
| Authorization (RBAC)   | ✅        |
| Pod Security           | ✅        |
| Network Policies       | ✅        |
| Secrets Best Practices | ✅        |

---

## 📂 Folder Structure for Day 5 Practice

```
k8s-day5-security/
├── rbac-user.yaml
├── rbac-serviceaccount.yaml
├── pod-recycler-auth.yaml
├── network-policy.yaml
├── secret-example.yaml
├── pod-security-label.yaml
├── README.md
```

---

## 🔥 Final Quote

> *“Security in Kubernetes isn’t just about firewalls and secrets — it’s about knowing exactly who can do what, where, and how. And stopping it when they shouldn't.”* 🛡️

---

## 🧠 Next Steps

* Day 6 (Bonus): Logging, Monitoring, and Observability with Prometheus + Grafana
* Real-world security exercises (break/defend lab)
* Helm Secrets and Sealed Secrets
* Integrate RBAC with OIDC Identity Providers


