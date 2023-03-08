module "eks-cluster-a" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.4"

  cluster_name    = "cluster-a"
  cluster_version = var.k8s_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  eks_managed_node_groups = {
    one = {
      name = "eks-cluster-a"

      instance_types = [var.ec2_nodes_type]

      min_size     = var.number_of_worker_nodes
      max_size     = var.number_of_worker_nodes
      desired_size = var.number_of_worker_nodes

      key_name = var.eks_managed_node_groups_ssh_key_pair
    }
  }
}
resource "aws_security_group_rule" "eks_to_nodes_cluster-a" {
  description = "From cluster-a EKS to cluster-a nodes"
  type = "ingress"
  source_security_group_id = module.eks-cluster-a.cluster_security_group_id
  from_port = 1025
  to_port = 10000
  security_group_id = module.eks-cluster-a.node_security_group_id
  protocol = "tcp"
}
resource "aws_security_group_rule" "cluster-a_nodes_to_cluster-a_nodes" {
  description = "From cluster-a nodes to cluster-a nodes"
  type = "ingress"
  source_security_group_id = module.eks-cluster-a.node_security_group_id
  from_port = 0
  to_port = 0
  security_group_id = module.eks-cluster-a.node_security_group_id
  protocol = "-1"
}
resource "aws_security_group_rule" "cluster-b_nodes_to_cluster-a_nodes" {
  description = "From cluster-b nodes to cluster-a nodes"
  type = "ingress"
  source_security_group_id = module.eks-cluster-b.node_security_group_id
  from_port = 0
  to_port = 0
  security_group_id = module.eks-cluster-a.node_security_group_id
  protocol = "-1"
}
# creates IAM role for ebs-csi-controller and assigns AmazonEBSCSIDriverPolicy policy to it
module "ebs-csi-controller_role_cluster-a" {
  source = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  role_name = "ebs-csi-controller-role-cluster-a"
  cluster_service_accounts = {
    (module.eks-cluster-a.cluster_name) = ["kube-system:ebs-csi-controller-sa"]
  }
  role_policy_arns = {
    "arn" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  depends_on = [
     module.eks-cluster-a.cluster_name # implicit dependancy doesn't work for some reason ...
  ]
}
