### shield 
resource "aws_shield_protection" "iron-shield" {
    name = "iron-shield"
    resource_arn = aws_instance.bastion_a.arn

#shield standard 활성화
}