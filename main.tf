data "aws_region" "current" {}

data "archive_file" "acrchive_file" {
  type = "zip"
  source_file = "${path.module}/lambda.js"
  output_path = "${path.module}/function.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "apigw-lambda"
  filename = data.archive_file.acrchive_file.output_path
  
  runtime = "nodejs16.x"
  handler = "lambda.apiHandler"

  memory_size = 128

  source_code_hash = data.archive_file.acrchive_file.output_base64sha256

  role = "arn:aws:iam::111111111111:role/apigw"
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name = "API Gateway Lambda integration"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = "{somethingId}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource.id
  http_method = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda_function.arn}/invocations"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_stage" "stage" {
    deployment_id = aws_api_gateway_deployment.deployment.id
    rest_api_id = aws_api_gateway_rest_api.rest_api.id
    stage_name = "dev"
}
