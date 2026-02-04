variable "zone_name" {
  type = string
}

variable "records" {
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number)
    values  = optional(list(string))
    alias   = optional(object({
      name                   = string
      evaluate_target_health = bool
      zone_id                = string
    }))
  }))
}

variable "ses" {
  type = object({
    enable = bool
    dkim_tokens = list(string)
  })
  default = {
    enable = false
    dkim_tokens = []
  }
}