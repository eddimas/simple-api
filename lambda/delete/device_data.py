import json
import boto3
from boto3.dynamodb.conditions import Key

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
DYNAMODB_TABLE = "ProcessedData"

def lambda_handler(event, context):
    # Extract device_id and value from query parameters
    query_parameters = event.get("queryStringParameters", {})
    if not query_parameters:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'device_id and value are required as query parameters'})
        }
    
    device_id = query_parameters.get("device_id")
    value = query_parameters.get("value")

    if not device_id or not value:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Both device_id and value are required'})
        }

    # Convert `value` to float (ensure number format)
    try:
        value = float(value)
    except ValueError:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Invalid value format. Must be a number'})
        }

    # 🔹 Ensure device_id matches the expected type
    table = dynamodb.Table(DYNAMODB_TABLE)
    schema_response = table.key_schema

    partition_key_type = next((key["KeyType"] for key in schema_response if key["AttributeName"] == "device_id"), None)

    if partition_key_type == "N":  # If device_id is a Number in DynamoDB
        try:
            device_id = int(device_id)
        except ValueError:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Invalid device_id format. Must be a number'})
            }

    elif partition_key_type == "S":  # If device_id is a String in DynamoDB
        device_id = str(device_id)

    # Query DynamoDB for the item
    try:
        response = table.query(
            KeyConditionExpression=Key('device_id').eq(device_id)
        )
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Query operation failed: {str(e)}'})
        }

    items = response.get('Items', [])
    matching_item = next((item for item in items if float(item.get('value', 0)) == value), None)

    if not matching_item:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'No matching item found for deletion'})
        }

    # Ensure the item has a timestamp field
    if 'timestamp' not in matching_item:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error: Matching item is missing timestamp'})
        }

    # 🔹 Convert timestamp type if necessary
    timestamp = matching_item['timestamp']
    timestamp_type = next((key["KeyType"] for key in schema_response if key["AttributeName"] == "timestamp"), None)

    if timestamp_type == "N":  # If timestamp is a number
        timestamp = int(timestamp)
    elif timestamp_type == "S":  # If timestamp is a string
        timestamp = str(timestamp)

    # Print debugging info
    print(f"Trying to delete item with device_id={device_id} and timestamp={timestamp}")

    # Delete the item from DynamoDB
    try:
        table.delete_item(
            Key={
                'device_id': device_id,
                'timestamp': timestamp
            }
        )
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Delete operation failed: {str(e)}'})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Item successfully deleted'})
    }
