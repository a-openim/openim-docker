#!/bin/bash

# OpenIM Kubernetes Ingress Deployment Script
# This script deploys Kubernetes Ingress for OpenIM frontend services

set -e

# Configuration
NAMESPACE="openim"
INGRESS_CLASS="nginx"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}OpenIM Kubernetes Ingress Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed!${NC}"
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster!${NC}"
    exit 1
fi

echo -e "${GREEN}Kubernetes cluster connection: OK${NC}"
echo ""

# Create namespace if it doesn't exist
echo -e "${BLUE}Checking namespace '${NAMESPACE}'...${NC}"
if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
    echo -e "${YELLOW}Creating namespace '${NAMESPACE}'...${NC}"
    kubectl create namespace ${NAMESPACE}
    echo -e "${GREEN}Namespace '${NAMESPACE}' created${NC}"
else
    echo -e "${GREEN}Namespace '${NAMESPACE}' already exists${NC}"
fi
echo ""

# Check if Ingress Controller is installed
echo -e "${BLUE}Checking Ingress Controller...${NC}"
if ! kubectl get pods -n ingress-nginx &> /dev/null; then
    echo -e "${YELLOW}Ingress Controller not found. Installing NGINX Ingress Controller...${NC}"
    
    # Install NGINX Ingress Controller
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml
    
    echo -e "${YELLOW}Waiting for Ingress Controller to be ready...${NC}"
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    echo -e "${GREEN}Ingress Controller installed successfully${NC}"
else
    echo -e "${GREEN}Ingress Controller is already installed${NC}"
fi
echo ""

# Deploy Ingress resources
echo -e "${BLUE}Deploying Ingress resources...${NC}"
kubectl apply -f ingress.yaml -n ${NAMESPACE}
echo -e "${GREEN}Ingress resources deployed${NC}"
echo ""

# Get Ingress information
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Ingress Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${GREEN}Ingress Resources:${NC}"
kubectl get ingress -n ${NAMESPACE}
echo ""

echo -e "${GREEN}Access URLs:${NC}"
echo -e "  Single Host Mode:"
echo -e "    OpenIM Web Frontend:  http://openim.example.com/"
echo -e "    OpenIM Admin Frontend: http://openim.example.com/admin"
echo ""
echo -e "  Multi-Host Mode:"
echo -e "    OpenIM Web Frontend:  http://web.openim.example.com/"
echo -e "    OpenIM Admin Frontend: http://admin.openim.example.com/"
echo ""

echo -e "${YELLOW}Note: Update the 'host' field in ingress.yaml to match your domain${NC}"
echo ""

echo -e "${YELLOW}To get Ingress IP/Port:${NC}"
echo -e "  kubectl get ingress -n ${NAMESPACE}"
echo ""

echo -e "${YELLOW}To view Ingress logs:${NC}"
echo -e "  kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller"
echo ""

echo -e "${YELLOW}To check Ingress status:${NC}"
echo -e "  kubectl describe ingress openim-ingress -n ${NAMESPACE}"
echo ""

echo -e "${YELLOW}To delete Ingress:${NC}"
echo -e "  kubectl delete -f ingress.yaml -n ${NAMESPACE}"
echo ""
