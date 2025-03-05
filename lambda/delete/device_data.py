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
    
    # Convert value to float for comparison
    try:
        value = float(value)
    except ValueError:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Invalid value format. Must be a number'})
        }
    
    # Query DynamoDB for the item
    table = dynamodb.Table(DYNAMODB_TABLE)
    response = table.query(
        KeyConditionExpression=Key('device_id').eq(device_id)
    )
    
    items = response.get('Items', [])
    matching_item = next((item for item in items if float(item.get('value', 0)) == value), None)
    
    if not matching_item:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'No matching item found for deletion'})
        }
    
    # Delete the item from DynamoDB
    table.delete_item(
        Key={
            'device_id': matching_item['device_id'],
            'timestamp': matching_item['timestamp']  # Ensure timestamp is included for unique deletion
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Item successfully deleted'})
    }
