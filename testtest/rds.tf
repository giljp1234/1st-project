
resource "aws_db_subnet_group" "iron_rds_eks" {
  name = "eks_group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_c.id]
  tags = {
    "Name" = "iron_rds_eks"
  }
}
resource "aws_rds_cluster" "iron-data-cluster" {
  cluster_identifier = "iron-data-cluster"
  engine = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.10.2"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  database_name = "irondb"
  master_username = "iron"
  master_password = "iron1234"
  skip_final_snapshot = false
  db_subnet_group_name = aws_db_subnet_group.iron_rds_eks.name
  vpc_security_group_ids = [aws_security_group.private-rds.id]

  tags = {
    name = "iron-data-cluster-cluster"
  }
}

resource "aws_rds_cluster_instance" "cluster_instances"{
  count = 2
  identifier = "iron-data-cluster-${count.index}"
  cluster_identifier = aws_rds_cluster.iron-data-cluster.id
  instance_class = "db.t3.small"
  engine = aws_rds_cluster.iron-data-cluster.engine
  engine_version = aws_rds_cluster.iron-data-cluster.engine_version
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.iron_rds_eks.name
}
