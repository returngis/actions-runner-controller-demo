#!/bin/bash

set -e

source .devcontainer/.env

CLUSTER_NAME="arc-demo"

if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Cluster ${CLUSTER_NAME} already exists"
else
    echo -e "Create a kind cluster ⎈"
    kind create cluster --name ${CLUSTER_NAME} --config .devcontainer/kind-config.yaml
fi

echo -e "Installing Actions Runner Controller 🐈‍⬛"

NAMESPACE="arc-systems"
helm install arc \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller


echo -c "Configuring a runner scale set"

INSTALLATION_NAME="arc-runner-set"
NAMESPACE="arc-runners"
GITHUB_CONFIG_URL="https://github.com/returngis"
GITHUB_PAT="$PAT"
helm install "${INSTALLATION_NAME}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --set githubConfigUrl="${GITHUB_CONFIG_URL}" \
    --set githubConfigSecret.github_token="${GITHUB_PAT}" \
    oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

kubectl get pods -n arc-systems
kubectl get pods -n arc-runners