resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "waf_web_acl_k8s"
  description = "mMnaged rule for our project."
  scope       = "REGIONAL"

  default_action {
    allow {}
  }


  rule {
    name      = "AWS-AWSManagedRulesCommonRuleSet"
    priority  = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name      = "AWS-AWSManagedRulesSQLiRuleSet"
    priority  = 2
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }


  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "iron-metric-name"
    sampled_requests_enabled   = false
  }
}