# Module 4 - Secrets Leakage

## Three scenarios

### Scenario A - EC2 User Data
Credentials hardcoded in EC2 instance user data script.
Readable via describe-instance-attribute with no instance access needed.

```bash
aws ec2 describe-instance-attribute \
  --instance-id <id> \
  --attribute userData \
  --query 'UserData.Value' \
  --output text | base64 --decode
```
Returns full plaintext bash script including DB passwords, API keys, Stripe secrets.

### Scenario B - Lambda Environment Variables
Credentials stored as Lambda environment variables.
Readable by any IAM principal with lambda:GetFunctionConfiguration.

```bash
aws lambda get-function-configuration \
  --function-name secrets-lab-insecure-function \
  --query 'Environment.Variables'
```
Returns all secrets in plaintext JSON instantly.

### Scenario C - SSM Parameter Store comparison
Secure Lambda stores only parameter paths in env vars, not values.
Same attacker query returns paths only - no credentials.

SSM SecureString retrieved separately:
```bash
aws ssm get-parameter --name /secrets-lab/db-password --with-decryption
```
Returns decrypted value but ONLY if the calling identity has ssm:GetParameter permission.
This is the critical difference: access is IAM-controlled and every read is logged in CloudTrail.

## Key lesson
SSM SecureString is only secure when combined with tightly scoped IAM.
ssm:GetParameter on Resource: "*" defeats the purpose entirely.
Correct pattern: scope ssm:GetParameter to specific parameter ARNs and specific roles only.

## Detection - CloudTrail indicators
- ec2:DescribeInstanceAttribute attacker reading user data
- lambda:GetFunctionConfiguration attacker reading env vars
- ssm:GetParameter every SSM read is logged, unlike env var reads
  This audit trail is one of SSM's key advantages over env vars

## Hardening
- Never put credentials in EC2 user data or Lambda environment variables
- Use SSM Parameter Store SecureString for all secrets
- Scope ssm:GetParameter IAM permissions to specific parameter paths and specific roles
- Rotate any credentials that have appeared in user data or env vars immediately
