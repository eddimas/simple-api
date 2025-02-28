import json
import boto3
import datetime

s3 = boto3.client('s3')

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
    processed_data = {
        'device_id': device_id,
        'value': value,
        'timestamp': datetime.datetime.utcnow().isoformat()
    }

    # Store processed data in the S3 bucket
    s3.put_object(
        Bucket='device-raw-data-bucket',
        Key=f'processed_data/{device_id}_{datetime.datetime.utcnow().isoformat()}.json',
        Body=json.dumps(processed_data)
    )

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Data processed and stored successfully'})
    }