#!/bin/bash
# SHA Compare
# Compares the SHA of a local Docker image to that of the remote Docker Hub image of the same name
#
# Usage:
#   ./sha-compare.sh org/image:tag
#
# Example:
#   ./sha-compare.sh portainer/portainer-ee:latest

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ref="${1}"
repo="${ref%:*}"
tag="${ref##*:}"
acceptM="application/vnd.docker.distribution.manifest.v2+json"
acceptML="application/vnd.docker.distribution.manifest.list.v2+json"
token=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" \
        | jq -r '.token')
remotesha=$(curl -H "Accept: ${acceptM}" -H "Accept: ${acceptML}" -H "Authorization: Bearer $token" -I -s "https://registry-1.docker.io/v2/${repo}/manifests/${tag}" | tr -d '\r' | sed -En 's/^docker-content-digest: (.*).*/\1/p')
echo "Remote SHA: [$remotesha]"
localsha=$(docker image inspect $ref --format '{{.RepoDigests}}' | sed -r 's/.*@(.*)].*/\1/')
echo "Local SHA:  [$localsha]"
if [ "$remotesha" = "$localsha" ]; then
  echo -e "${GREEN}SHAs match${NC}"
else
  echo -e "${RED}SHAs do NOT match${NC}"
fi
