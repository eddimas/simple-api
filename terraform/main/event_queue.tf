resource "aws_sns_topic" "event_notifications" {
  name = "device-event-topic"
}

resource "aws_sqs_queue" "event_queue" {
  name = "device-event-queue"
}

resource "aws_sns_topic_subscription" "queue_subscription" {
  topic_arn = aws_sns_topic.event_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.event_queue.arn
}


/////////////
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.event_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_to_dynamodb.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_to_dynamodb.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.event_notifications.arn
}
