# DevOps Mega Project - Practice Pipeline

Maps 1:1 to the whiteboard flow:

```
1. Application  -> 2. Master (Terraform, t2.large) -> 3. DevSecOps (Sonar/Trivy/OWASP/Docker)
                                                     -> 4. Kubernetes Cluster (EKS, Node1+Node2)
5. GitOps (Git Repo -> ArgoCD) -> back into EKS -> 6. Monitoring (Prometheus/Grafana/Helm)
```

## Repo layout

| Folder            | Diagram box       | What it does                                    |
|-------------------|--------------------|--------------------------------------------------|
| `app/`            | Application (1)    | Node.js sample app + Dockerfile                  |
| `terraform/master`| Master machine (2) | IAM, Key Pair, SG, t2.large EC2 running Jenkins  |
| `terraform/eks`   | Kubernetes Cluster (4)| EKS cluster + 2-node managed node group      |
| `security/`       | DevSecOps (3)       | Sonar, Trivy, OWASP configs                     |
| `jenkins/`        | DevSecOps (3)        | Jenkinsfile driving the whole pipeline          |
| `k8s/`            | GitOps (5)           | Deployment/Service manifests ArgoCD applies     |
| `argocd/`         | GitOps (5)           | ArgoCD Application (auto-sync + self-heal)      |
| `helm/monitoring/`| Monitoring (6)       | kube-prometheus-stack values + ServiceMonitor    |

## Run order (practice checklist)

1. **Provision Master**
   ```bash
   cd terraform/master
   terraform init && terraform apply
   # note the jenkins_url output, log in, unlock Jenkins with initialAdminPassword
   ```

2. **Provision EKS**
   ```bash
   cd ../eks
   terraform init && terraform apply
   aws eks update-kubeconfig --region ap-south-1 --name devops-mega-eks
   kubectl get nodes   # should show Node 1 + Node 2
   ```

3. **Install ArgoCD on the cluster**
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   kubectl apply -f argocd/application.yaml
   ```

4. **Install monitoring stack**
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install monitoring prometheus-community/kube-prometheus-stack \
     -n monitoring --create-namespace -f helm/monitoring/values-kube-prometheus-stack.yaml
   kubectl apply -f helm/monitoring/servicemonitor.yaml
   ```

5. **Configure Jenkins**
   - Install plugins: SonarQube Scanner, OWASP Dependency-Check, Docker Pipeline, SSH Agent.
   - Add credentials: `dockerhub-creds`, `gitops-ssh-key`, `argocd-auth-token`.
   - Create a Pipeline job pointing at `jenkins/Jenkinsfile` in this repo.

6. **Push a code change** -> Jenkins builds, scans (Sonar/Trivy/OWASP), pushes image,
   updates the GitOps repo -> ArgoCD auto-syncs to EKS -> Grafana dashboard shows the new pods.

## Notes for practice

- Replace `yourdockerhubuser`, `yourgithubuser`, and the ArgoCD/Sonar server URLs with your own.
- `allowed_ssh_cidr` in `terraform/master/variables.tf` defaults wide open (`0.0.0.0/0`) for
  quick practice - lock it to your IP before leaving it running.
- `trivy.yaml` is set to fail the build on HIGH/CRITICAL CVEs - that's intentional, it's the
  security gate. Fix the underlying dependency, don't just widen the severity list.
- Everything here is destroyable: `terraform destroy` in both `terraform/master` and
  `terraform/eks` when you're done practicing, to avoid AWS charges.
Testing webhook trigger
