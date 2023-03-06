resource "aws_codecommit_repository" "backend-server" {
  repository_name = "finback"
  description     = "Backend demo"
}

resource "aws_codecommit_repository" "frontend-server" {
  repository_name = "finfront"
  description     = "Frontend demo"
}