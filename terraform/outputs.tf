output "iam_role" {
  value = "${aws_iam_role.iam_for_lambda.arn}"
}

output "aws_region" {
  value = "${data.aws_region.current.name}"
}


output "aws_account" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "git_marker" {
  value = "${var.git_marker}"
}

output "api_gateway_id" {
  value = "${aws_api_gateway_rest_api.api.id}"
}

output "api_gateway_root_resource_id" {
  value = "${aws_api_gateway_rest_api.api.root_resource_id}"
}

output "api_gateway_created_date" {
  value = "${aws_api_gateway_rest_api.api.created_date}"
}


output "deployment_id" {
  value = "${aws_api_gateway_deployment.MyDemoDeployment.id}"
}

output "deployment_invoke_url" {
  value = "${aws_api_gateway_deployment.MyDemoDeployment.invoke_url}"
}

output "deployment_execution_arn" {
  value = "${aws_api_gateway_deployment.MyDemoDeployment.execution_arn}"
}

output "ndeployment_created_date" {
  value = "${aws_api_gateway_deployment.MyDemoDeployment.created_date}"
}
