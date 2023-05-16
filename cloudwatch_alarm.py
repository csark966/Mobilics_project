import boto3

# Set the AWS region
region = 'ap-south-1'

# EC2 instance ID
instance_id = 'i-0e3e9858be1fcce97'

# CPU utilization threshold
threshold_percentage = 80

# Duration for triggering the alarm
evaluation_periods = 5

# Period for checking CPU utilization
period = 60

# Create a CloudWatch client
cloudwatch = boto3.client('cloudwatch', region_name=region)

# Create the alarm
response = cloudwatch.put_metric_alarm(
    AlarmName='HighCPUUtilization',
    ComparisonOperator='GreaterThanThreshold',
    EvaluationPeriods=evaluation_periods,
    MetricName='CPUUtilization',
    Namespace='AWS/EC2',
    Period=period,
    Statistic='Average',
    Threshold=threshold_percentage,
    ActionsEnabled=True,
    AlarmDescription='Alarm when CPU exceeds 80%',
    Dimensions=[
        {
            'Name': 'InstanceId',
            'Value': instance_id
        },
    ],
    AlarmActions=[
         "arn:aws:sns:ap-south-1:572520932829:cloudwatch_alarm.fifo"
    ],
)

print(response)
