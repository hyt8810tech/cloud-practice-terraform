variable "name" {}
variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
}
variable "retained_image_count" {
  type    = number
  default = "3"
  validation {
    condition     = var.retained_image_count >= 3
    error_message = "The retained_image_count must be greater than or equal to 3."
  }
}
