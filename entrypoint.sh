#!/bin/sh

function usage_docs {
  echo ""
  echo "- uses: pipedrive/aws-s3-github-action@master"
  echo "  with:"
  echo "    command: cp"
  echo "    source: >"  # Use '>' to start a multiline string
  echo "      ./local_file.txt"
  echo "      ./another_local_file.txt"
  echo "      ./yet_another_local_file.txt"
  echo "    destination: s3://yourbucket/folder/"
  echo "    aws_access_key_id: \${{ secret.AWS_ACCESS_KEY_ID }}"
  echo "    aws_secret_access_key: \${{ secret.AWS_SECRET_ACCESS_KEY }}"
  echo ""
}
function get_configuration_settings {
  if [ -z "$INPUT_AWS_ACCESS_KEY_ID" ]
  then
    echo "AWS Access Key Id was not found. Using configuration from previous step."
  else
    aws configure set aws_access_key_id "$INPUT_AWS_ACCESS_KEY_ID"
  fi

  if [ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ]
  then
    echo "AWS Secret Access Key was not found. Using configuration from previous step."
  else
    aws configure set aws_secret_access_key "$INPUT_AWS_SECRET_ACCESS_KEY"
  fi

  if [ -z "$INPUT_AWS_SESSION_TOKEN" ]
  then
    echo "AWS Session Token was not found. Using configuration from previous step."
  else
    aws configure set aws_session_token "$INPUT_AWS_SESSION_TOKEN"
  fi

  if [ -z "$INPUT_METADATA_SERVICE_TIMEOUT" ]
  then
    echo "Metadata service timeout was not found. Using configuration from previous step."
  else
    aws configure set metadata_service_timeout "$INPUT_METADATA_SERVICE_TIMEOUT"
  fi

  if [ -z "$INPUT_AWS_REGION" ]
  then
    echo "AWS region not found. Using configuration from previous step."
  else
    aws configure set region "$INPUT_AWS_REGION"
  fi
}
function get_command {
  VALID_COMMANDS=("sync" "mb" "rb" "ls" "cp" "mv" "rm")
  COMMAND="cp"
  if [ -z "$INPUT_COMMAND" ]
  then
    echo "Command not set using cp"
  elif [[ ! ${VALID_COMMANDS[*]} =~ "$INPUT_COMMAND" ]]
  then
    echo ""
    echo "Invalid command provided :: [$INPUT_COMMAND]"
    usage_docs
    exit 1
  else
    echo "Using provided command"
    COMMAND=$INPUT_COMMAND
  fi
}
function validate_source_and_destination {
  if [ "$COMMAND" == "cp" ] || [ "$COMMAND" == "mv" ] || [ "$COMMAND" == "sync" ]
  then
    # Require source and target
    if [ -z "$INPUT_SOURCE" ] && [ "$INPUT_DESTINATION" ]
    then
      echo ""
      echo "Error: Requires source and destination."
      usage_docs
      exit 1
    fi

    # Verify at least one source or target have s3:// as prefix
    # if [[] || []]
    if [[ ! "$INPUT_SOURCE" =~ ^s3:// ]] && [[ ! "$INPUT_DESTINATION" =~ ^s3:// ]]
    then
      echo ""
      echo "Error: Source or target must have s3:// as prefix."
      usage_docs
      exit 1
    fi
  else
    # Require source
    if [ -z "$INPUT_SOURCE" ]
    then
      echo "Error: Requires source."
      usage_docs
      exit 1
    fi

    # Verify at source has s3:// as prefix
    if [[ ! $INPUT_SOURCE =~ ^s3:// ]]
    then
      echo "Error: Source must have s3:// as prefix."
      usage_docs
      exit 1
    fi
  fi
}
function main {
  echo "v1.0.0"
  get_configuration_settings
  get_command
  validate_source_and_destination

  aws --version

  IFS=$'\n' # Set the Internal Field Separator to newline

  # Split the multiline input into an array
  read -ra SOURCE_ARRAY <<< "$INPUT_SOURCE"


  for source in "${SOURCE_ARRAY[@]}"; do
    if [ "$COMMAND" == "cp" ] || [ "$COMMAND" == "mv" ] || [ "$COMMAND" == "sync" ]
    then
      echo "aws s3 $COMMAND \"$source\" $INPUT_DESTINATION $INPUT_FLAGS"
      aws s3 "$COMMAND" "$source" "$INPUT_DESTINATION" $INPUT_FLAGS
    else
      echo "aws s3 $COMMAND \"$source\" $INPUT_FLAGS"
      aws s3 "$COMMAND" "$source" $INPUT_FLAGS
    fi
  done
}

main
