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
- Generate TLS certificates (self-signed for demo) or setup existing certificates signed by trusted CA.
- Setup DB password and rails secret key.
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout rails-tls.key -out rails-tls.crt -subj "/CN=localhost"
mv rails-tls.* k8s/secrets/ingress_tls_certs/
cp k8s/secrets.yaml.example k8s/secrets.yaml
# [Setup rails_secret_key, db_password and tls_certificates]
minikube kubectl -- apply k8s/secrets.yaml
```

#### 4. Build a docker image:
```bash
docker build -t rat_pay_app:latest .
```

#### 5. Apply k8s manifests:
```bash
minikube kubectl -- apply k8s/postgres.yaml
minikube kubectl -- apply k8s/rat_pay_config.yaml
minikube kubectl -- apply k8s/rat_pay_app.yaml
minikube kubectl -- apply k8s/rat_pay_app_ingress.yaml
minikube kubectl -- apply k8s/kafka.yaml
```

#### 6. Visit RatPay payment page:
```bash
echo "$(minikube ip) rat-pay.local" | sudo tee -a /etc/hosts
# [Visit https://rat-pay.local]
```
https://rat-pay.local
