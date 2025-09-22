# README

```bash
chmod +x test.sh
./test.sh
```

https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download
```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

```bash
newgrp docker
minikube start --cpus=2 --memory=4096
```

```bash
minikube dashboard
```

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout rails-tls.key -out rails-tls.crt -subj "/CN=localhost"
mv rails-tls.* k8s/secrets/ingress_tls_certs/
cp k8s/secrets.yaml.example k8s/secrets.yaml
# [Setup rails_secret_key, db_password and tls_certificates]
minikube kubectl -- apply k8s/secrets.yaml
```

```bash
docker build -t rat_pay_app:latest .
minikube kubectl -- apply k8s/postgres.yaml
minikube kubectl -- apply k8s/rat_pay_config.yaml
minikube kubectl -- apply k8s/rat_pay_app.yaml
minikube kubectl -- apply k8s/rat_pay_app_ingress.yaml

echo "$(minikube ip) rat-pay.local" | sudo tee -a /etc/hosts
# [Visit https://rat-pay.local]

minikube kubectl -- apply k8s/kafka.yaml
```

# TODO: Kafka connection
