# kubectl v1.5
# docker run --rm supinf/kubectl version
# docker run --rm -it -v $HOME/.kube/:/root/.kube/ supinf/kubectl get pods

FROM alpine:3.5

ENV KUBECTL_VERSION=1.4.7

RUN apk --no-cache add --virtual build-dependencies curl \
  && apk --no-cache add ca-certificates  \
  && curl --location --output /usr/bin/kubectl \
      https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl \
  && chmod +x /usr/bin/kubectl \
  && apk del --purge build-dependencies

ENTRYPOINT ["kubectl"]
CMD ["help"]
