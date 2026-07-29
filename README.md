# AWS Cloud Security Lab
![Image Alt](https://github.com/kaveeshanirmal141/aws-security-lab/blob/main/AWS%20CloudSecurity%20Lab%20Art.jpeg?raw=true)

A hands-on offensive security lab covering six AWS attack categories.
Each module deploys vulnerable infrastructure via Terraform, executes the attack,
documents CloudTrail detection indicators, applies hardening, and destroys all resources.

Built by an 18-year-old cybersecurity student as a self-directed project alongside
an Advanced Diploma in Cyber Security.

## Modules

| Module | Category | Attack Chain |
|--------|----------|-------------|
| 1 | SSRF - Credential Theft | SSRF - IMDSv1 - IAM role credentials - S3 exfil |
| 2 | IAM Privilege Escalation | iam:AttachUserPolicy - self-grant AdministratorAccess |
| 3 | S3 Misconfiguration | Public bucket - sensitive data - hardcoded creds - private bucket pivot |
| 4 | Secrets Leakage | EC2 user data + Lambda env vars vs SSM Parameter Store |
| 5 | Container Role Abuse | RCE in container - IMDS - task role credentials - S3 exfil |
| 6 | Lambda Privilege Escalation | iam:PassRole + lambda:CreateFunction - backdoor admin user |

## Stack
- Infrastructure: Terraform
- Cloud: AWS (us-east-1)
- Attack tools: AWS CLI, curl, Python
- Detection: AWS CloudTrail

## Structure
Each module is self-contained under `modules/`. Deploy with `terraform apply`,
attack, document, harden, then `terraform destroy`. Cost: $0 (free tier).

## Real world references
- Module 1: Capital One breach 2019 (SSRF + IMDSv1)
- Module 3: GoDaddy, Twitch, hundreds of healthcare orgs (S3 misconfiguration)
- Modules 2 + 6: Rhino Security Labs IAM privilege escalation research (21 documented paths)
