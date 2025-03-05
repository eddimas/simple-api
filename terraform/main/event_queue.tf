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
