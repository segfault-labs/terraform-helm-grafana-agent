variable "cluster_name" {
  type = string
}

variable "cluster_namespace" {
  type = string
}

variable "mode" {
  type = string
  validation {
    condition     = can(regex("^(node|cluster)$", var.mode))
    error_message = "mode must be either 'node' or 'cluster'"
  }
}

variable "prometheus_enabled" {
  type    = bool
  default = true
}

variable "loki_enabled" {
  type    = bool
  default = true
}

variable "loki_pass" {
  type      = string
  sensitive = true
  default   = null
}

variable "loki_url" {
  type    = string
  default = null
}

variable "loki_user" {
  type    = string
  default = null
}

variable "prometheus_labels_filter" {
  type    = string
  default = null
}

variable "prometheus_metrics_filter" {
  type    = string
  default = null
}

variable "prometheus_pass" {
  type      = string
  sensitive = true
  default   = null
}

variable "prometheus_url" {
  type    = string
  default = null
}

variable "prometheus_user" {
  type    = string
  default = null
}

variable "blackbox_targets" {
  type = list(object({
    name = string
    url  = string
  }))
  default = []
}