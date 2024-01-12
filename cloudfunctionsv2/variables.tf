# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

#CLOUD FUNCTION V2 INSTANCE SETTINGS

variable "cfv2_region" {
  description = "(Required) The region where the Cloud Function will be created."
  type        = string
  default = "us-central1"
  nullable    = false
}

variable "cfv2_project" {
  description = "(Required) The ID of the project in which the resources belong."
  type        = string
  default = "prj-bu1-n-sample-base-bd59"
  nullable    = false
}

variable "cfv2_name" {
  description = "(Required) A user-defined name of the function. The function names must be unique globally."
  type        = string
  default = "cfv2_http"
  nullable    = false
}

variable "cfv2_runtime" {
  description = "(Required) The runtime in which the function is going to run. Eg. 'python310', 'nodejs12', 'nodejs14', 'java11', 'ruby27', etc."
  type        = string
  default = "python311"
  nullable    = false
}


variable "cfv2_entry_point" {
  description = "(Required) A user-defined name of the function. The function names must be unique globally."
  type        = string
  default = "hello_get"
  nullable    = false
}

variable "cfv2_labels" {
  description = "(Required) A set of key/value label pairs to assign to the function. Label keys must follow the requirements at https://cloud.google.com/resource-manager/docs/creating-managing-labels#requirements."
  type        = map(string)
  default = {
    company = "123"
    division = "123"
  }

}

#CLOUD FUNCTION V2 IAM SETTINGS

variable "cfv2_runtime_sa" {
  description = "(Required) Service account to run the function."
  type        = string
  default = "value"
  nullable    = false
}

#CLOUD FUNCTION V2 NETWORK SETTINGS

variable "vpc_connector" {
  description = "(Required) The VPC Network Connector. The format of this field is 'projects/*/locations/*/connectors/*'."
  type        = string
  default = "cfv2connectortf2"
  nullable    = false
}

variable "vpc_connector_egress_settings" {
  description = "(Optional) The egress settings for the connector, controlling what traffic is diverted through it. "
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
  validation {
    condition     = var.vpc_connector_egress_settings == "PRIVATE_RANGES_ONLY"
    error_message = "Changing the default value of vpc_connector_egress_settings is not allowed"
  }
}

variable "cfv2_ingress_settings" {
  description = "(Optional) The ingress settings for CFV2, controlling incoming traffic through it. "
  type        = string
  default     = "ALLOW_INTERNAL_ONLY"
  validation {
    condition     = var.cfv2_ingress_settings == "ALLOW_INTERNAL_ONLY"
    error_message = "Changing the default value of cfv2 ingress is not allowed"
  }
}


variable "cmek" {
  description = "(Required) Customer Managed Encryption Key to be used by the CFV2"
  type        = string
  default = "value"
  nullable    = false
}


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "cfv2_available_memory_mb" {
  description = "(Optional) The amount of memory available for a function. Defaults to 256M. Supported units are k, M, G, Mi, Gi. If no unit is supplied the value is interpreted as bytes."
  type        = string
  default     = "4Gi"
}


variable "cfv2_max_instance_request_concurrency" {
  description = "(Optional) Sets the maximum number of concurrent requests that each instance can receive."
  type        = number
  default     = 1
}

variable "cfv2_available_cpu" {
  description = "(Optional) The number of CPUs used in a single container instance. Default value is calculated from available memory."
  type        = string
  default     = "2"
}

variable "cfv2_timeout" {
  description = "(Optional) Timeout (in seconds) for the function. Cannot be more than 3600 seconds and 540 seconds for HTTP and event-driven functions respectively."
  type        = number
  default     = 540
}

variable "cfv2_max_instances" {
  description = "(Optional) The limit on the maximum number of function instances that may coexist at a given time. Cannot be more than 100 for 2nd gen Cloud Functions"
  type        = number
  default     = 3
}

variable "cfv2_min_instances" {
  description = "(Optional) The limit on the maximum number of function instances that may coexist at a given time. Cannot be more than 100 for 2nd gen Cloud Functions"
  type        = number
  default     = 1
}


variable "cfv2_env_var" {
  description = "(Optional) A set of key/value environment variable pairs to assign to the function."
  type        = map(string)
  default     = {}
}

variable "cfv2_evtarc_trigger" {
  description = "(Optional) In case of using event-driven CFV2 "
  type = object({
    event_type            = string
    service_account_email = string
  })
  default = null
}

variable "cfv2_evtarc_trigger_retry" {
  description = "(Optional) Retry policy to be used by the eventarc trigger managed by the cfv2 "
  type        = string
  default     = "RETRY_POLICY_DO_NOT_RETRY"
}




