variable "env" {
  type = string
}

variable "cloud_pratica" {
  type = object({
    domain = string
  })
}
