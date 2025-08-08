#!/bin/bash

ROLE_ARN=$1
SESSION_NAME=$2
EXTERNAL_ID=$3
PROFILE_NAME=$4

if [ -z "$ROLE_ARN" ] || [ -z "$SESSION_NAME" ] || [ -z "$EXTERNAL_ID" ] || [ -z "$PROFILE_NAME" ]; then
  echo "Usage: source $0 <role-arn> <session-name> <external-id> <profile-name>"
  return 1 2>/dev/null || exit 1
fi

# Assume the role
CREDS=$(aws sts assume-role \
  --role-arn "$ROLE_ARN" \
  --role-session-name "$SESSION_NAME" \
  --external-id "$EXTERNAL_ID" \
  --output json)

# Parse credentials
AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

# Write to ~/.aws/credentials
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$PROFILE_NAME"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$PROFILE_NAME"
aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile "$PROFILE_NAME"

echo ""
echo "✅ Role assumed and stored under profile [$PROFILE_NAME] in ~/.aws/credentials"
echo ""
echo "To use it in VS Code or terminal:"
echo "  export AWS_PROFILE=$PROFILE_NAME"
echo "  code ."
echo ""
