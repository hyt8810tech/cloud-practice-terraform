resource "aws_route53_zone" "zone" {
  name = var.zone_name
}

resource "aws_route53_record" "record" {
  for_each = { for r in var.records : "${r.name}-${r.type}" => r }
  name     = each.value.name
  records  = lookup(each.value, "values", null)
  type     = each.value.type
  ttl      = lookup(each.value, "ttl", null)
  zone_id  = aws_route53_zone.zone.id
  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = each.value.alias.name
      evaluate_target_health = each.value.alias.evaluate_target_health
      zone_id                = each.value.alias.zone_id
    }
  }
}

resource "aws_route53_record" "ses_mail_txt" {
  count   = var.ses.enabled ? 1 : 0
  records = ["v=spf1 include:amazonses.com ~all"]
  ttl     = 300
  type    = "TXT"
  zone_id = aws_route53_zone.zone.id
  name    = "mail.${var.zone_name}"
}

resource "aws_route53_record" "ses_mail_mx" {
  count   = var.ses.enabled ? 1 : 0
  name    = "mail.${var.zone_name}"
  records = ["10 feedback-smtp.ap-northeast-1.amazonses.com"]
  ttl     = 300
  type    = "MX"
  zone_id = aws_route53_zone.zone.id
}


resource "aws_route53_record" "ses_mail_dmarc" {
  count   = var.ses.enabled ? 1 : 0
  name    = "_dmarc.${var.zone_name}"
  records = ["v=DMARC1; p=none;"]
  ttl     = 300
  type    = "TXT"
  zone_id = aws_route53_zone.zone.id
}

resource "aws_route53_record" "ses_mail_cname" {
  count   = var.ses.enabled ? 3 : 0
  name    = "${element(var.ses.dkim_tokens, count.index)}._domainkey.${var.zone_name}"
  records = ["${element(var.ses.dkim_tokens, count.index)}.dkim.amazonses.com"]
  ttl     = 1800
  type    = "CNAME"
  zone_id = aws_route53_zone.zone.id
}
