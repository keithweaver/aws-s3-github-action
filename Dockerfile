# https://aws.amazon.com/blogs/developer/aws-cli-v2-docker-image/
# https://hub.docker.com/r/amazon/aws-cli
FROM amazon/aws-cli:2.4.23

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
