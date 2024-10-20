pipeline "hello" {
  title       = "Hello"
  description = "This pipeline says hello to a person."

  param "name" {
    type    = string
    default = var.name
  }

  step "message" "notify_hello" {
    notifier = notifier.default
    text     = "Hello, ${param.name}!"
  }

  output "ouput_hello" {
    value = "Hello, ${param.name}!"
  }
}

pipeline "get_astronauts" {

  step "http" "whos_in_space" {
    url    = "http://api.open-notify.org/astros"
    method = "get"
  }

  output "people_in_space" {
    value = step.http.whos_in_space.response_body.people
  }

}

pipeline "output_astronauts" {

  step "pipeline" "get_astronauts" {
    pipeline = pipeline.get_astronauts
  }

  step "transform" "astronaut_names" {
    value = [for row in step.pipeline.get_astronauts.output.people_in_space : row.name]
  }

  output "people_by_name" {
    value = join(", ", step.transform.astronaut_names.value)
  }

  step "message" "notify_astronaut_names" {
    notifier = notifier.default
    text     = join(", ", step.transform.astronaut_names.value)
  }

}

pipeline "broken_output_astronauts" {

  step "pipeline" "broken_get_astronauts" {
    pipeline = pipeline.get_astronauts
  }

  step "transform" "broken_astronaut_names" {
    value = { for row in step.pipeline.broken_get_astronauts.output.people_in_space : row.name => row }
  }

  step "message" "broken_notify_astronaut_names" {
    notifier = notifier.default
    text     = join(", ", step.transform.broken_astronaut_names.value)
  }

}