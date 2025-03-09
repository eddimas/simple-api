import boto3
import csv
import json
import os

s3_client = boto3.client("s3")
sns_client = boto3.client("sns")

SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, context):
    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key = record["s3"]["object"]["key"]

        # Download file from S3
        response = s3_client.get_object(Bucket=bucket, Key=key)
        content = response["Body"].read().decode("utf-8").splitlines()
        reader = csv.DictReader(content)

        for row in reader:
            message = json.dumps({
                "timestamp": row["Timestamp"],
                "device_id": row["device_id"],
                "value": row["value"]
            })
            sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=message)

    return {"statusCode": 200, "body": "CSV processed successfully"}
