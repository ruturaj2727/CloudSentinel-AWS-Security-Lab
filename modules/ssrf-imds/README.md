# Module 1 | SSRF - IMDSv1 - Credential Theft

## Attack chain
SSRF vulnerability - IMDSv1 metadata endpoint - stolen IAM role credentials - S3 data exfiltration

## Vulnerability
EC2 instance running a Flask app with an unvalidated URL fetch endpoint.
IMDSv1 enabled (http_tokens = optional) no authentication required to access metadata.

## Exploitation
```bash
curl "http://<ip>:5000/fetch?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/ssrf-lab-ec2-role"
```
Returns AccessKeyId, SecretAccessKey, and SessionToken.

## Impact
Full access to any AWS resource the EC2 role is permitted to access.
In this lab: read access to S3 bucket containing simulated sensitive data.

## Detection CloudTrail indicators
- `GetCallerIdentity` called by assumed role session from external IP
- `ec2RoleDelivery: 1.0` in CloudTrail JSON confirms IMDSv1 credential delivery
- Source IP mismatch — role credentials used outside AWS IP ranges

## Hardening
Set `http_tokens = required` in EC2 metadata options (IMDSv2).
Same SSRF attack returns HTTP 401 two-step token requirement breaks single-request exploit.

## Real world reference
Capital One breach 2019 SSRF against WAF on EC2, IMDSv1 credential theft, 100M records exfiltrated.
