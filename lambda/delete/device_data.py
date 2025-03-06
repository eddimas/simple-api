import json
import boto3
from decimal import Decimal

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

    # Convert `value` to Decimal (DynamoDB does not support float)
    try:
        value = Decimal(value)
    except ValueError:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Invalid value format. Must be a number'})
        }

    table = dynamodb.Table(DYNAMODB_TABLE)

    # 🔹 Step 1: Scan the table to find the matching item
    try:
        response = table.scan(
            FilterExpression="device_id = :d_id AND #v = :val",
            ExpressionAttributeNames={"#v": "value"},
            ExpressionAttributeValues={":d_id": device_id, ":val": value}
        )
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Scan operation failed: {str(e)}'})
        }

    items = response.get('Items', [])

    if not items:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'No matching item found for deletion'})
        }

    # 🔹 Step 2: Extract the timestamp from the first matching item
    matching_item = items[0]  # Take the first match
    timestamp = matching_item.get("timestamp")

    if not timestamp:
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Error: Matching item is missing timestamp'})
        }

    # 🔹 Step 3: Ensure Correct Data Types for `delete_item`
    # Check device_id type in DynamoDB
    if isinstance(matching_item['device_id'], Decimal):  # If device_id is stored as Number
        device_id = int(device_id)  # Ensure it's an integer
    else:
        device_id = str(device_id)  # Ensure it's a string

    # Ensure timestamp matches the stored type
    if isinstance(matching_item['timestamp'], Decimal):  # If timestamp is stored as Number
        timestamp = int(timestamp)  # Convert to integer
    else:
        timestamp = str(timestamp)  # Convert to string

    # Print for debugging
    print(f"Deleting item with device_id={device_id} and timestamp={timestamp}")

    # 🔹 Step 4: Delete the item using the exact key structure
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
