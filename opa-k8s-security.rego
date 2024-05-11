############### opa-k8s-security.rego ###############


package main

# Deny rule for services that are not of type NodePort
deny[msg] {
  input.kind = "Service" # Check if the Kubernetes resource is a Service
  not input.spec.type = "NodePort" # Deny if the service type is not NodePort
  msg = "Service type should be NodePort" # Set error message
}

# Deny rule for deployments where containers run as root
deny[msg] {
  input.kind = "Deployment" # Check if the Kubernetes resource is a Deployment
  not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true # Deny if the container runs as root
  msg = "Containers must not run as root - use runAsNonRoot within container security context" # Set error message
}
