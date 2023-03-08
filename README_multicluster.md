The lab setup for experimenting with Consul partitions on AWS EKS (EC2)

### 1) Test your AWS CLI credentials:
```
aws sts get-caller-identity
```
### 2) Create an EKS cluster:
```
terraform init
terraform plan
terraform apply
```
### 3) Configure the kubernetes contexts:
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster-a_name)
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster-b_name)
```

# Install Consul in cluster-a

```
export CLUSTER_A_CONTEXT=arn:aws:eks:$(terraform output -raw region):$(aws sts get-caller-identity | jq -r '.["Account"]'):cluster/$(terraform output -raw cluster-a_name)
export CLUSTER_B_CONTEXT=arn:aws:eks:$(terraform output -raw region):$(aws sts get-caller-identity | jq -r '.["Account"]'):cluster/$(terraform output -raw cluster-b_name)
kubectl config use-context $CLUSTER_A_CONTEXT
kubectl config current-context

kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=$(terraform output -raw iam_ebs-csi-controller_role_cluster-a)
kubectl rollout restart deployment ebs-csi-controller -n kube-system

kubectl create namespace consul
kubectl apply -f license.yaml
kubectl apply -f bootstrap-token.yaml
kubectl apply --kustomize "github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.1"
helm install consul hashicorp/consul -n consul --values consul_values_a.yaml --version=1.0.2
```
# Copy Secrets to cluster-b

kubectl --context $CLUSTER_B_CONTEXT create namespace consul

kubectl get secret -n consul consul-ca-cert -o yaml | \
kubectl --context $CLUSTER_B_CONTEXT apply -n consul -f -

kubectl get secret -n consul consul-ca-key -o yaml | \
kubectl --context $CLUSTER_B_CONTEXT apply -n consul -f -

kubectl get secret -n consul consul-gossip-encryption-key -o yaml | \
kubectl --context $CLUSTER_B_CONTEXT apply -n consul -f -

# Prepare cluster-b

kubectl config use-context $CLUSTER_B_CONTEXT
kubectl config current-context
kubectl annotate serviceaccount ebs-csi-controller-sa -n kube-system eks.amazonaws.com/role-arn=$(terraform output -raw iam_ebs-csi-controller_role_cluster-b)
kubectl rollout restart deployment ebs-csi-controller -n kube-system

kubectl apply -f license.yaml
kubectl apply -f bootstrap-token.yaml
kubectl apply --kustomize "github.com/hashicorp/consul-api-gateway/config/crd?ref=v0.5.1"


# Get cluster-b EKS API endpoint

export CLUSTER_B_EKS_ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name == \"$CLUSTER_B_CONTEXT\")].cluster.server}")

# Get cluster-a external Consul server LB

export CLUSTER_A_CONSUL_LB=$(kubectl --context $CLUSTER_A_CONTEXT get svc -n consul | grep consul-expose-servers | awk '{print $4}')

# EDIT VALUES IN consul_values_b.yaml 

sed -e "s|<cluster-b_eks_api_endpoint>|${CLUSTER_B_EKS_ENDPOINT}|g" -e "s|<cluster-a_external_server_lb>|${CLUSTER_A_CONSUL_LB}|g" consul_values_b_template.yaml > consul_values_b.yaml

# Install Consul in cluster-b

helm install consul hashicorp/consul -n consul --values consul_values_b.yaml --version=1.0.2

# Workaround for api-gateway-controller crashing due to "x509: certificate is valid for client.dc1.consul, localhost, not server.dc1.consul" error

kubectl get deployment consul-api-gateway-controller -n consul -o json | jq '.spec.template.spec.containers[] | select(.name == "api-gateway-controller") | .env'
kubectl set env -n consul deployment/consul-api-gateway-controller -c api-gateway-controller CONSUL_TLS_SERVER_NAME-
kubectl get deployment consul-api-gateway-controller -n consul -o json | jq '.spec.template.spec.containers[] | select(.name == "api-gateway-controller") | .env'

# Discovering cluster-a Consul UI URL

kubectl --context $CLUSTER_A_CONTEXT get svc -n consul | grep consul-ui | awk '{print $4}'


# Deleting everything

kubectl config use-context $CLUSTER_B_CONTEXT
helm uninstall consul -n consul
kubectl config use-context $CLUSTER_A_CONTEXT
helm uninstall consul -n consul
terraform destroy

### WARNING! By default SGs assigned to the created ELBs allow incoming connections from ANY address. You might want to limit it to your own IP