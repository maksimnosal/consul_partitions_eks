#------ general -----

output "region" {
  description = "AWS region"
  value       = var.region
}

#----- cluster-a ------

output "cluster-a_name" {
  description =  "cluster-a name"
  value       = module.eks-cluster-a.cluster_name
}

output "cluster-a_endpoint" {
  description = "cluster-a EKS endpoint"
  value       = module.eks-cluster-a.cluster_endpoint
}

output "cluster_security_group_id_cluster-a" {
  description = "cluster-a control plane SG"
  value       = module.eks-cluster-a.cluster_security_group_id
}

output "node_security_group_id_cluster-a" {
  description = "cluster-a nodes SG"
  value       = module.eks-cluster-a.cluster_security_group_id
}

output "iam_ebs-csi-controller_role_cluster-a" {
  description = "ebs-csi-controller_role_cluster-a"
  value = module.ebs-csi-controller_role_cluster-a.iam_role_arn
}

#----- cluster-b ---------

output "cluster-b_name" {
  description = "cluster-b name"
  value       = module.eks-cluster-b.cluster_name
}

output "cluster-b_endpoint" {
  description = "cluster-b EKS endpoint"
  value       = module.eks-cluster-b.cluster_endpoint
}

output "cluster_security_group_id_cluster-b" {
  description = "cluster-b control plane SG"
  value       = module.eks-cluster-b.cluster_security_group_id
}

output "node_security_group_id_cluster-b" {
  description = "cluster-b nodes SG"
  value       = module.eks-cluster-b.cluster_security_group_id
}

output "iam_ebs-csi-controller_role_cluster-b" {
  description = "ebs-csi-controller_role_cluster-b"
  value = module.ebs-csi-controller_role_cluster-b.iam_role_arn
}