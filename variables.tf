variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "k8s_version" {
  type = string
  default = "1.24"
}

variable "eks_cluster-a_name" {
  type = string
  default = "cluster-a"
}
variable "eks_cluster-b_name" {
  type = string
  default = "cluster-b"
}
# Managed nodes group parameters
variable "number_of_worker_nodes" {
  type = number 
  default = 3
}
variable "ec2_nodes_type" {
  type = string
  default = "t3.small"
}
variable "eks_managed_node_groups_ssh_key_pair" {
  type = string
  default = ""
}

# IAM for ebs-csi-controller
variable "ebs-csi-controller-role-name" {
  type = string 
  default = "ebs-csi-controller-role"
}
