#!/bin/bash

set -e

# if .env file does not exist throw error
if [ ! -f .devcontainer/.env ]; then
    echo "Please create a .env file in the .devcontainer folder"
    exit 1
fi

# if private-key.pem file does not exist throw error
if [ ! -f .devcontainer/private-key.pem ]; then
    echo "Please download your private-key.pem file in the .devcontainer folder"
    exit 1
fi

source .devcontainer/.env

CLUSTER_NAME="arc-demo"

echo -e "Clear kubectl context"
kubectl config unset contexts.${CLUSTER_NAME}

if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Cluster ${CLUSTER_NAME} already exists"
    kind delete cluster --name ${CLUSTER_NAME}
    echo -e "Create a kind cluster ⎈"
    kind create cluster --name ${CLUSTER_NAME} --config .devcontainer/kind-config.yaml
else
    echo -e "Create a kind cluster ⎈"
    kind create cluster --name ${CLUSTER_NAME} --config .devcontainer/kind-config.yaml
fi

echo -e "Installing Actions Runner Controller 🐈‍⬛"

echo -e "First we need to create a secret with the permissions to download the Docker image from the GitHub Container Registry"

NAMESPACE="arc-systems"

kubectl create ns "${NAMESPACE}"

kubectl create secret docker-registry ghcr \
    --docker-server=ghcr.io \
    --docker-username=$GITHUB_USERNAME \
    --docker-password=$GITHUB_TOKEN \
    --namespace=$NAMESPACE


helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --values .devcontainer/runner-controller-values.yaml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller


kubectl get pods -n arc-systems

echo -c "Configuring a runner scale set"

INSTALLATION_NAME="$ORG_NAME-arc-runner-set"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/$ORG_NAME"

# Load private-key.pem into GITHUB_PRIVATE_KEY
GITHUB_PRIVATE_KEY=$(cat .devcontainer/private-key.pem)
kubectl create ns "${NAMESPACE}"

kubectl create secret generic pre-defined-secret \
  --namespace=$NAMESPACE \
  --from-literal=github_app_id="${GITHUB_APP_ID}" \
  --from-literal=github_app_installation_id="${GITHUB_APP_INSTALLATION_ID}" \
  --from-literal=github_app_private_key="${GITHUB_PRIVATE_KEY}"

kubectl create secret docker-registry ghcr \
    --docker-server=ghcr.io \
    --docker-username=$GITHUB_USERNAME \
    --docker-password=$GITHUB_TOKEN \
    --namespace=$NAMESPACE

helm install "${INSTALLATION_NAME}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret=pre-defined-secret \
    --values .devcontainer/runner-controller-values.yaml \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

kubectl get pods -n arc-systems
kubectl get pods -n arc-runners --watch