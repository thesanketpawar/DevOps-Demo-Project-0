locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  instances = {
    control-plane = {
      name          = "k8s-control-plane"
      instance_type = "t3.small"
    }

    worker1 = {
      name          = "k8s-worker1"
      instance_type = "t3.small"
    }

    worker2 = {
      name          = "k8s-worker2"
      instance_type = "t3.small"
    }

    jenkins = {
      name          = "jenkins-server"
      instance_type = "t3.small"
    }
  }
}
