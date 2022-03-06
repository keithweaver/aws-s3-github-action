# AWS S3 Github Action

Upload, download, or list files/folders through Github Actions.

```
- uses: keithweaver/aws-s3-github-action@v1.0.0
  with:
    command: cp
    source: ./local_file.txt
    destination: s3://yourbucket/folder/local_file.txt
    aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

**Inputs**

| Variable name      | Required/Optional  | Default  | Description                |
| ------------------ | ------------------ | -------- | -------------------------- |
| `command`          | Optional           | `cp`     | This is the command that is being performed. When using the AWS CLI, it's the portion following the service. `aws s3 cp ...` <- `cp`, `aws s3 ls` <- `ls` |
| `source`           | Required           | N/A      | Depending on the command, this could be the directory you are requesting list, or the source file. |
| `destination`      | Required for `cp`, `mv` and `sync` | N/A      | The location where you want the file to arrive. |
| `aws_access_key_id` | Optional   | N/A | This is the credentials from an IAM role for getting access to a bucket. [More info](https://docs.aws.amazon.com/cli/latest/reference/configure/) |
| `aws_secret_access_key` | Optional   | N/A | This is the credentials from an IAM role for getting access to a bucket. [More info](https://docs.aws.amazon.com/cli/latest/reference/configure/) |
| `aws_session_token` | Optional   | N/A | This is the credentials from an IAM role for getting access to a bucket. [More info](https://docs.aws.amazon.com/cli/latest/reference/configure/) |
| `metadata_service_timeout` | Optional   | N/A | The number of seconds to wait until the metadata service request times out. [More info](https://docs.aws.amazon.com/cli/latest/reference/configure/) |

## FAQs

**Where can I see this run in a pipeline as an example?**

TODO

**How can I use a specific version or test a feature branch?**

You are specifying the tag or branch by using the `@` after the Action name. Below, it uses `v1.0.0` which is based on the tag.

```
- uses: keithweaver/aws-s3-github-action@v1.0.0
  ...
```

This uses the master branch:

```
- uses: keithweaver/aws-s3-github-action@master
```

This uses a feature branch called `dev-branch`:

```
- uses: keithweaver/aws-s3-github-action@dev-branch
```

It is recommended that you point to a specific version to avoid unexpected changes affecting your workflow.


**Can I run this local with Docker?**

```
# You should have Docker on your local and running.
docker build . -t aws-s3-action
docker run \
  --env INPUT_AWS_ACCESS_KEY_ID="<ACCESS_KEY>" \
  --env INPUT_AWS_SECRET_ACCESS_KEY="<ACCESS_SECRET>" \
  --env INPUT_SOURCE="./sample.txt" \
  --env INPUT_DESTINATION="s3://yourbucket/sample.txt" \
  aws-s3-action
# Docker image must follow the environment variables or they will not set.
```

**Can I run this local outside of Docker?**

You can run a bash script

```
INPUT_AWS_ACCESS_KEY_ID="<ACCESS_KEY>" \
  INPUT_AWS_SECRET_ACCESS_KEY="<ACCESS_SECRET>" \
  INPUT_SOURCE="./sample.txt" \
  INPUT_DESTINATION="s3://yourbucket/sample.txt" \
  bash entrypoint.sh
```


## Errors

**upload failed: ./test1.txt to s3://.../test1.txt Unable to locate credentials**

You didn't set credentials correctly. Common reason; forgot to set the Github Secrets.

**An error occurred (SignatureDoesNotMatch) when calling the PutObject operation: The request signature we calculated does not match the signature you provided. Check your key and signing method.**

Solution is [here](https://github.com/aws/aws-cli/issues/602#issuecomment-60387771). [More info](https://stackoverflow.com/questions/4770635/s3-error-the-difference-between-the-request-time-and-the-current-time-is-too-la), [more](https://forums.docker.com/t/syncing-clock-with-host/10432/6).

**botocore.utils.BadIMDSRequestError**

[Here](https://stackoverflow.com/questions/68348222/aws-s3-ls-gives-error-botocore-utils-badimdsrequesterror-botocore-awsrequest-a) is the solution. We set the AWS region as a required argument as a result.

**upload failed: folder1/ to s3://.../folder1/ [Errno 21] Is a directory: '/github/workspace/folder1/'**

You need to a recursive flag for the `cp`. Looks like:

```
- uses: keithweaver/aws-s3-github-action@v1.0.0
  name: Copy Folder
  with:
    command: cp
    source: ./folder1/
    destination: s3://bucket/folder1/
    aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws_region: us-east-1
    flags: --recursive
```
