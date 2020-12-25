# To build this stack:
# docker build -t quay.io/username/cloudnative-workspaces-quarkus:VVV -f stack.Dockerfile .
# docker push quay.io/username/cloudnative-workspaces-quarkus:VVVV

FROM registry.redhat.io/codeready-workspaces/plugin-java11-rhel8:latest

ENV MANDREL_VERSION=20.1.0.2.Final
ENV QUARKUS_VERSION=1.7.5.Final-redhat-00007
ENV TKN_VERSION=0.13.1
ENV KN_VERSION=0.17.3
ENV OC_VERSION=4.6
ENV GRAALVM_HOME="/usr/local/mandrel-java11-${MANDREL_VERSION}"

USER root

RUN wget -O /tmp/oc.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC_VERSION}/linux/oc.tar.gz && cd /usr/bin && tar -xvzf /tmp/oc.tar.gz && chmod a+x /usr/bin/oc && rm -f /tmp/oc.tar.gz

RUN wget -O /tmp/kn.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/serverless/${KN_VERSION}/kn-linux-amd64-${KN_VERSION}.tar.gz && cd /usr/bin && tar -xvzf /tmp/kn.tar.gz ./kn && chmod a+x kn && rm -f /tmp/kn.tar.gz

RUN wget -O /tmp/tkn.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/${TKN_VERSION}/tkn-linux-amd64-${TKN_VERSION}.tar.gz && cd /usr/bin && tar -xvzf /tmp/tkn.tar.gz tkn&& chmod a+x tkn && rm -f /tmp/tkn.tar.gz

RUN sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && sudo microdnf install -y npm zlib-devel glibc-devel libffi-devel gcc siege && sudo curl -Lo /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && sudo chmod a+x /usr/bin/jq

RUN wget -O /tmp/mandrel.tar.gz https://github.com/graalvm/mandrel/releases/download/mandrel-${MANDREL_VERSION}/mandrel-java11-linux-amd64-${MANDREL_VERSION}.tar.gz && cd /usr/local && tar -xvzf /tmp/mandrel.tar.gz && rm -rf /tmp/mandrel.tar.gz

USER jboss

RUN mkdir -p /home/jboss/.m2

COPY settings.xml /home/jboss/.m2

RUN cd /tmp && mkdir project && cd project && mvn io.quarkus:quarkus-maven-plugin:${QUARKUS_VERSION}:create -DprojectGroupId=org.acme -DprojectArtifactId=footest -DplatformVersion=${QUARKUS_VERSION} -Dextensions="quarkus-agroal,quarkus-arc,quarkus-hibernate-orm,quarkus-hibernate-orm-panache,quarkus-jdbc-h2,quarkus-jdbc-postgresql,quarkus-kubernetes,quarkus-scheduler,quarkus-smallrye-fault-tolerance,quarkus-smallrye-health,quarkus-smallrye-opentracing" && mvn -f footest clean compile package && cd / && rm -rf /tmp/project

RUN cd /tmp && mkdir project && cd project && mvn io.quarkus:quarkus-maven-plugin:${QUARKUS_VERSION}:create -DprojectGroupId=org.acme -DprojectArtifactId=footest -DplatformVersion=${QUARKUS_VERSION} -Dextensions="quarkus-smallrye-reactive-streams-operators,quarkus-smallrye-reactive-messaging,quarkus-smallrye-reactive-messaging-kafka,quarkus-swagger-ui,quarkus-vertx,quarkus-kafka-client, quarkus-smallrye-metrics,quarkus-smallrye-openapi" && mvn -f footest clean compile package -Pnative && cd / && rm -rf /tmp/project

RUN cd /tmp && git clone https://github.com/RedHat-Middleware-Workshops/cloud-native-workshop-v2m4-labs && cd cloud-native-workshop-v2m4-labs && git checkout ocp-${OC_VERSION} && for proj in *-service ; do mvn -fn -f ./$proj dependency:resolve-plugins dependency:resolve dependency:go-offline clean compile -DskipTests ; done && cd /tmp && rm -rf /tmp/cloud-native-workshop-v2m4-labs

RUN siege && sed -i 's/^connection = close/connection = keep-alive/' $HOME/.siege/siege.conf && sed -i 's/^benchmark = false/benchmark = true/' $HOME/.siege/siege.conf

RUN echo '-w "\n"' > $HOME/.curlrc

USER root
RUN chown -R jboss /home/jboss/.m2
RUN chmod -R a+w /home/jboss/.m2
RUN chmod -R a+rwx /home/jboss/.siege