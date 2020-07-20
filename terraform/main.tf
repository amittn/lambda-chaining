# iam
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

resource "aws_iam_role_policy" "frontend_lambda_role_policy" {
  name   = "frontend-lambda-role-policy"
  role   = "${aws_iam_role.iam_for_lambda.id}"
  policy = "${data.aws_iam_policy_document.lambda_log_and_invoke_policy.json}"
}

data "aws_iam_policy_document" "lambda_log_and_invoke_policy" {

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]

  }

  statement {
    effect = "Allow"

    actions = ["lambda:InvokeFunction", "lambda:InvokeAsync"]

    resources = ["arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:*"]
  }

}

# lambda
resource "aws_lambda_function" "first_lambda" {
#  filename      = "lambda-chaining-1.0-SNAPSHOT.jar"
  s3_bucket        = "${aws_s3_bucket_object.object_jar.bucket}"
  s3_key           = "${aws_s3_bucket_object.object_jar.key}"
  function_name    = "${var.environment}-first-lambda"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "example.HandlerApiGateway::handleRequest"
  source_code_hash = "${filebase64sha256("lambda-chaining-1.0-SNAPSHOT.jar")}"
  runtime          = "${var.lambda_runtime_java}"
  timeout          = "20"
  memory_size      = "200"

  environment {
    variables = {
      foo = "bar"
      AWS_LAMBDA_REGION = "${data.aws_region.current.name}"
      INVOKE_TYPE_USED = "${var.lambda_invoke_type}"
      LAMBDA_TO_BE_INVOKED = "${aws_lambda_function.second_lambda.function_name}"
    }
  }
}

resource "aws_lambda_function" "second_lambda" {
  #  filename      = "lambda-chaining-1.0-SNAPSHOT.jar"
  s3_bucket        = "${aws_s3_bucket_object.object_jar.bucket}"
  s3_key           = "${aws_s3_bucket_object.object_jar.key}"
  function_name    = "${var.environment}-second-lambda"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "example.Handler::handleRequest"
  source_code_hash = "${filebase64sha256("lambda-chaining-1.0-SNAPSHOT.jar")}"
  runtime          = "${var.lambda_runtime_java}"
  timeout          = "10"
  memory_size      = "150"

  environment {
    variables = {
      foo = "bar"
    }
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.environment}-myapi"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.first_lambda.arn}/invocations"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.first_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  #source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}/${aws_api_gateway_resource.resource.path}"
  source_arn = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${aws_lambda_function.first_lambda.function_name}"
}


# API Gateway Deployment
resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = ["aws_api_gateway_integration.integration"]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "test"

  variables = {
    "answer" = "2"
  }
}