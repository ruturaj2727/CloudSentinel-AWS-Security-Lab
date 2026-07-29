# Module 2 - IAM Privilege Escalation (AttachUserPolicy)

## Attack chain
Low-privilege IAM user with iam:AttachUserPolicy permission - self-grants AdministratorAccess - full account compromise

## Vulnerability
A user was granted the `iam:AttachUserPolicy` permission scoped to their own ARN.
This single permission allows the user to attach ANY managed policy to themselves, including AdministratorAccess.

## Exploitation
```bash
aws iam attach-user-policy \
  --user-name low-priv-user \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```
One API call. No confirmation, no warning. Silent success - `responseElements: null` in CloudTrail.

## Before / After
- Before: `aws s3 ls` - AccessDenied
- After: `aws s3 ls` - full bucket listing returned

## Impact
Complete AWS account takeover from a single misconfigured IAM permission.

## Detection - CloudTrail indicators
- `eventName: AttachUserPolicy`
- `userIdentity.userName` matches `requestParameters.userName` - user attaching a policy to themselves
- `requestParameters.policyArn` contains AdministratorAccess or another high-privilege policy
- This combination is one of the highest-signal indicators of privilege escalation in AWS

## Hardening
Removed `iam:AttachUserPolicy` from the user's policy entirely.
Same attack command now returns AccessDenied.

## Real world reference
This is one of ~21 documented IAM privilege escalation paths (Rhino Security Labs research).
Among the most common in real environments - developers are frequently over-granted IAM
management permissions "to get things working."
