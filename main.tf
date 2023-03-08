provider "kubernetes" {
  alias = "cluster-a"
  host = module.eks-cluster-a.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster-a.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks-cluster-a.cluster_name]
    command     = "aws"
  }
}

provider "kubernetes" {
  alias = "cluster-b"
  host = module.eks-cluster-b.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster-b.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks-cluster-b.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  alias = "cluster-a"
  kubernetes {
    host = module.eks-cluster-a.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks-cluster-a.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks-cluster-a.cluster_name]
      command     = "aws"
    }
  }
}

provider "helm" {
  alias = "cluster-b"
  kubernetes {
    host = module.eks-cluster-b.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks-cluster-b.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks-cluster-b.cluster_name]
      command     = "aws"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      owner: "mnosal"
    }
  }
}

data "aws_availability_zones" "available" {}