import json
import boto3
import datetime

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
DYNAMODB_TABLE = "ProcessedData"
S3_BUCKET = "device-raw-data-bucket"

def lambda_handler(event, context):
    # Extract data from the event
    body = json.loads(event.get('body', '{}'))
    device_id = body.get('device_id')
    value = body.get('value')

    if not device_id or not value:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'device_id and value are required'})
        }

    # Process data (e.g., add a timestamp)
    timestamp = datetime.datetime.utcnow().isoformat()
    processed_data = {
        'device_id': device_id,
        'value': value,
        'timestamp': timestamp
    }

    # Store processed data in the S3 bucket
    s3.put_object(
        Bucket=S3_BUCKET,
        Key=f'processed_data/{device_id}_{timestamp}.json',
        Body=json.dumps(processed_data)
    )

    # Store processed data in DynamoDB
    table = dynamodb.Table(DYNAMODB_TABLE)
    table.put_item(Item={
        'device_id': device_id,
        'timestamp': timestamp,
        'value': value
    })

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Data processed and stored successfully'})
    }