# Module 3 - S3 Misconfiguration + Credential Pivot

## Attack chain
Public bucket (no auth) - sensitive data exposure - hardcoded credentials in public file - pivot to private bucket

## Three scenarios

### Scenario A - Public bucket exposure
S3 bucket with Block Public Access disabled and bucket policy granting s3:GetObject to Principal: "*".
Any unauthenticated HTTP request returns file contents. No AWS credentials required.

### Scenario B - Sensitive data in public bucket
Files exposed without authentication:
- internal/employee-data.csv - simulated PII (names, emails, salaries)
- config/app-config.json - internal database host, API endpoints

### Scenario C - Credential pivot
dev/deployment-notes.txt in the public bucket contains hardcoded AWS access keys.
Attacker reads the file unauthenticated, configures the leaked credentials, and accesses a
private S3 bucket that is otherwise properly secured.

## Exploitation
```bash
# No credentials needed — public HTTP request
curl https://<bucket>.s3.amazonaws.com/internal/employee-data.csv
curl https://<bucket>.s3.amazonaws.com/dev/deployment-notes.txt

# Extract keys from deployment-notes.txt, then pivot
aws configure --profile victim
aws s3 cp s3://s3-lab-private-data-<account-id>/sensitive/customer-records.txt - --profile victim
```

## Detection - CloudTrail indicators
- PutBucketPolicy event with requestParameters.bucketPolicy.Statement[].Principal = "*"
  This fires at misconfiguration creation time catch it before attackers find it
- S3 data events (GetObject) not logged by default requires explicit enablement in trail config
  This is a critical gap: attackers can exfiltrate S3 data with zero CloudTrail trace unless
  data events are enabled

## Hardening
Enable Block Public Access on the bucket (all four settings = true).
Same unauthenticated curl returns AccessDenied XML.

Never store credentials in S3 objects - use IAM roles or SSM Parameter Store instead.

## Real world reference
Thousands of real breaches from misconfigured S3 buckets - GoDaddy, Facebook, Twitch,
and hundreds of healthcare companies. The misconfiguration takes seconds to make and
years to find if no detection is in place.
