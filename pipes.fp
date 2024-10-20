pipeline "list_pipes_orgs" {
  title       = "List Pipes Orgs"
  description = "List all Pipes orgs that the connection has access to."

  param "api_base_url" {
    type        = string
    description = "The Turbot Pipes base URL."
    default     = var.pipes_api_base_url
  }

  param "pipes_connection" {
    type        = connection.pipes
    description = "The Turbot Pipes connection to use."
    default     = var.default_pipes_connection
  }

  step "http" "list_pipes_actor_orgs" {
    url      = "${param.api_base_url}/api/v0/actor/org?limit=100"
    method   = "get"
    insecure = param.api_base_url == "https://pipes.turbot-local.com:8443"
    request_headers = {
      Authorization : "Bearer ${param.pipes_connection.token}"
      Content-Type : "application/json"
    }
  }

  step "message" "output_orgs" {
    for_each = step.http.list_pipes_actor_orgs.response_body.items
    notifier = var.default_notifier
    text = "Access to org: ${each.value.org.handle}"
  }

  output "output_orgs" {
    value = step.http.list_pipes_actor_orgs.response_body.items[*].org.handle
  }
}