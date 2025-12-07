# RatPay - Demo Payment Platform

[![CI](https://github.com/gudel98/rat-pay/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/gudel98/rat-pay/actions/workflows/ci.yml)
[![Dependabot Updates](https://github.com/gudel98/rat-pay/actions/workflows/dependabot/dependabot-updates/badge.svg?branch=main)](https://github.com/gudel98/rat-pay/actions/workflows/dependabot/dependabot-updates)

### Local testing (requires psql setup):
```bash
chmod +x test.sh
./test.sh
```

### Deployment:

#### 1. [Install minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download)
```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

#### 2. Start minikube cluster:
```bash
minikube start --cpus=2 --memory=4096

# Additionally, you can monitor the cluster via UI:
minikube dashboard
```

#### 3. Secrets:
- Setup DB password and rails secret key.
```bash
cp k8s/secrets.yaml.example k8s/secrets.yaml
# [Setup rails_secret_key, db_password and tls_certificates]
```

#### 4. Build a docker image:
```bash
docker build -t rat_pay_app:latest .
minikube image load rat_pay_app:latest
```

#### 5. Apply k8s manifests:
```bash
kubectl apply -R -f k8s/
```

#### 6. Visit RatPay payment page:
https://rat-pay.online/up
