resource "aws_waf_rule" "wafrule" {
    name = "ironwafrule"
    metric_name = "ironwafrule"
}

resource "aws_waf_web_acl" "wafacl" {
    depends_on = [
        aws_waf_rule.wafrule,
    ]

    name = "webacl"
    metric_name = "webacl"

    default_action {
        type = "block"
    }

    rules {
        action {
            type = "block"
        }

        priority = 1
        rule_id = aws_waf_rule.wafrule.id
        type = "REGULAR"
    }
}