// Auto-generated variable declarations from massdriver.yaml
variable "aws_authentication" {
  type = object({
    data = object({
      arn         = string
      external_id = optional(string)
    })
    specs = object({
      aws = optional(object({
        region = optional(string)
      }))
    })
  })
}
variable "aws_region" {
  type = string
}
variable "enable_flow_logs" {
  type    = bool
  default = false
}
variable "high_availability" {
  type    = bool
  default = true
}
variable "md_metadata" {
  type = object({
    default_tags = object({
      managed-by  = string
      md-manifest = string
      md-package  = string
      md-project  = string
      md-target   = string
    })
    deployment = object({
      id = string
    })
    name_prefix = string
    observability = object({
      alarm_webhook_url = string
    })
    package = object({
      created_at             = string
      deployment_enqueued_at = string
      previous_status        = string
      updated_at             = string
    })
    target = object({
      contact_email = string
    })
  })
}
variable "monitoring" {
  type = object({
    mode = optional(string)
    alarms = optional(object({
      ip_address_utilization = optional(object({
        percent = number
      }))
      nat_gateway_port_allocation = optional(object({
        count = number
      }))
    }))
  })
  default = null
}
variable "network" {
  type = object({
    automatic = optional(bool)
    mask      = optional(number)
    cidr      = optional(string)
  })
}
// Auto-generated variable declarations from massdriver.yaml
variable "dns" {
  type = object({
    enable_dns     = bool
    hosted_zone_id = optional(string)
  })
  default = null
}
