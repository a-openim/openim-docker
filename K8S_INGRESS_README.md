# OpenIM Kubernetes Ingress Deployment Guide

## Overview

This guide explains how to deploy Kubernetes Ingress for OpenIM frontend services with your actual domain configuration.

## Configuration

### Domain Names
- **OpenIM Web Frontend (H5)**: https://h5-openim.36x9.com
- **OpenIM Admin Frontend**: https://admin-openim.36x9.com

### Node IP
- **Node IP**: 10.88.88.13

## Prerequisites

1. **Kubernetes Cluster**: Ensure you have a running Kubernetes cluster
2. **kubectl**: Install and configure kubectl to access your cluster
3. **NGINX Ingress Controller**: Will be installed automatically by the deployment script
4. **Cert-Manager**: Required for automatic SSL/TLS certificate management (optional but recommended)

## Deployment Steps

### 1. Deploy OpenIM Services

First, deploy the OpenIM services using Docker Compose:

```bash
# Start OpenIM services
docker compose up -d

# Verify services are running
docker compose ps
```

### 2. Deploy Kubernetes Ingress

Run the deployment script:

```bash
# Deploy Ingress
./deploy_k8s_ingress.sh
```

The script will:
- Check kubectl installation and cluster connection
- Create the `openim` namespace
- Install NGINX Ingress Controller (if not present)
- Deploy the Ingress resources with your domain configuration

### 3. Verify Ingress Deployment

Check the Ingress status:

```bash
# View Ingress resources
kubectl get ingress -n openim

# View Ingress details
kubectl describe ingress openim-ingress -n openim

# View Ingress Controller pods
kubectl get pods -n ingress-nginx
```

### 4. DNS Configuration

Ensure your domain DNS records point to your Kubernetes cluster:

```
h5-openim.36x9.com      →  <Kubernetes Ingress IP>
admin-openim.36x9.com   →  <Kubernetes Ingress IP>
```

To get the Ingress IP:

```bash
kubectl get ingress -n openim
```

## SSL/TLS Configuration

### Option 1: Using Cert-Manager (Recommended)

1. Install Cert-Manager:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

2. Create a ClusterIssuer for Let's Encrypt:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

3. The Ingress will automatically obtain SSL certificates from Let's Encrypt.

### Option 2: Manual SSL Certificates

If you have your own SSL certificates:

```bash
# Create TLS secret
kubectl create secret tls openim-tls-secret \
  --cert=path/to/cert.crt \
  --key=path/to/cert.key \
  -n openim
```

## Access URLs

After successful deployment, access your OpenIM services:

- **OpenIM Web Frontend**: https://h5-openim.36x9.com
- **OpenIM Admin Frontend**: https://admin-openim.36x9.com

## Troubleshooting

### Check Ingress Controller Logs

```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Check Ingress Events

```bash
kubectl describe ingress openim-ingress -n openim
```

### Test DNS Resolution

```bash
# Test DNS resolution
nslookup h5-openim.36x9.com
nslookup admin-openim.36x9.com

# Test connectivity
curl -I https://h5-openim.36x9.com
curl -I https://admin-openim.36x9.com
```

### Common Issues

1. **502 Bad Gateway**: Check if backend services are running
   ```bash
   kubectl get pods -n openim
   ```

2. **Certificate Issues**: Check cert-manager logs
   ```bash
   kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager
   ```

3. **DNS Not Resolving**: Verify DNS records are correctly configured

## Management Commands

### View Ingress Status

```bash
kubectl get ingress -n openim
kubectl get svc -n ingress-nginx
```

### Update Ingress Configuration

Edit the ingress.yaml file and apply changes:

```bash
kubectl apply -f ingress.yaml -n openim
```

### Delete Ingress

```bash
kubectl delete -f ingress.yaml -n openim
```

### Delete Ingress Controller

```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml
```

## Additional Configuration

### Custom Annotations

The Ingress includes the following annotations for optimal performance:

- `nginx.ingress.kubernetes.io/ssl-redirect: "true"` - Redirect HTTP to HTTPS
- `nginx.ingress.kubernetes.io/proxy-body-size: "50m"` - Max upload size
- `nginx.ingress.kubernetes.io/proxy-connect-timeout: "600"` - Connection timeout
- `nginx.ingress.kubernetes.io/proxy-send-timeout: "600"` - Send timeout
- `nginx.ingress.kubernetes.io/proxy-read-timeout: "600"` - Read timeout

### Backend Services

The Ingress routes traffic to the following backend services:

- `openim-web-front:80` - Web frontend service
- `openim-admin-front:80` - Admin frontend service

## Support

For issues or questions, refer to:
- [NGINX Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
