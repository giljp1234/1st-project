
provider "helm" {
    version = "~> 2.0"
    
}

resource "kubernetes_namespace" "alb-ingress-controller" {
    metadata { 
        name = "kube-system"
    }
}


resource "helm_release" "alb-ingress-controller" {
    name = "alb-ingress-controller"
    repository = "https://kubernetes-charts.storage.googleapis.com/"
    chart = "alb-ingress-controller"

    namespace = kubernetes_namespace.alb-ingress-controller.metadata[0].name

    set {
        name = "awsRegion"
        value = var.region
    }
    set {
        name = "image.repository"
        value = "docker.io/amazon/aws-alb-ingress-controller"
    }
    set {
        name = "image.tag"
        value = "v1.1.8"
    }
    set {
        name = "fullnameOverride"
        value = "alb-ingress-controller"
    }
    set {
        name = "serviceAccount.create"
        value = "true"
    }
    set {
        name = "serviceAccount.name"
        value = "alb-ingress-controller"
    }
    set {
        name = "clusterName"
        value = aws_eks_cluster.iron_eks.name
    }

    depends_on = [
        kubernetes_namespace.alb-ingress-controller,
        aws_eks_cluster.iron_eks,
    ]
}

variable "region" {
    type = string
    default = "ap-northeast-2"
}
