# Use Confluent's Kafka Connect base image
ARG VERSION_TAG=7.7.1
ARG IMAGE_URL=confluentinc/cp-kafka-connect
FROM ${IMAGE_URL}:${VERSION_TAG}

# Environment variables for reusable component versions (updated)
ENV NETTY_VERSION=4.1.118.Final \
    JETTY_VERSION=9.4.57.v20241219 \
    ASYNC_HTTP_VERSION=2.12.4 \
    AVRO_JAR_VERSION=1.11.4 \
    PROTOBUF_VERSION=3.25.5 \
    COMMONS_IO_VERSION=2.15.1 \
    BEANUTILS_VERSION=1.11.0 \
    MINA_CORE_VERSION=2.2.4

USER root

# 1. Remove vulnerable JARs and embedded jars in bundled confluent files
RUN find /usr/share/java/ \
    -name "json-smart-*.jar" -delete \
    -o -name "netty-*.jar" -delete \
    -o -name "jetty-*.jar" -delete \
    -o -name "async-http-client-*.jar" -delete \
    -o -name "mina-core-*.jar" -delete \
    -o -name "protobuf-java*.jar" -delete \
    -o -name "commons-io*.jar" -delete \
    -o -name "commons-beanutils*.jar" -delete \
    -o -name "avro*.jar" -delete \
    -o -name "acl-*.jar" -delete \
    -o -name "confluent-metrics-*.jar" -delete \
    -o -name "telemetry-client-*.jar" -delete

# 2. Download secure versions of JARs using ENV variables
RUN wget https://repo1.maven.org/maven2/io/netty/netty-all/${NETTY_VERSION}/netty-all-${NETTY_VERSION}.jar -O /usr/share/java/kafka/netty-all.jar && \
    wget https://repo1.maven.org/maven2/io/netty/netty-handler/${NETTY_VERSION}/netty-handler-${NETTY_VERSION}.jar -O /usr/share/java/kafka/netty-handler.jar && \
    wget https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-server/${JETTY_VERSION}/jetty-server-${JETTY_VERSION}.jar -O /usr/share/java/kafka/jetty-server.jar && \
    wget https://repo1.maven.org/maven2/org/asynchttpclient/async-http-client/${ASYNC_HTTP_VERSION}/async-http-client-${ASYNC_HTTP_VERSION}.jar -O /usr/share/java/kafka/async-http-client.jar && \
    wget https://repo1.maven.org/maven2/org/apache/mina/mina-core/${MINA_CORE_VERSION}/mina-core-${MINA_CORE_VERSION}.jar -O /usr/share/java/kafka/mina-core.jar && \
    wget https://repo1.maven.org/maven2/org/apache/avro/avro/${AVRO_JAR_VERSION}/avro-${AVRO_JAR_VERSION}.jar -O /usr/share/java/kafka/avro.jar && \
    wget https://repo1.maven.org/maven2/com/google/protobuf/protobuf-java/${PROTOBUF_VERSION}/protobuf-java-${PROTOBUF_VERSION}.jar -O /usr/share/java/kafka/protobuf-java.jar && \
    wget https://repo1.maven.org/maven2/commons-beanutils/commons-beanutils/${BEANUTILS_VERSION}/commons-beanutils-${BEANUTILS_VERSION}.jar -O /usr/share/java/kafka/commons-beanutils.jar && \
    wget https://repo1.maven.org/maven2/commons-io/commons-io/${COMMONS_IO_VERSION}/commons-io-${COMMONS_IO_VERSION}.jar -O /usr/share/java/kafka/commons-io.jar

# 3. Install secure Python 3.9 + latest pip + latest avro-python3
RUN dnf update -y && \
    dnf install -y python39 python39-pip python39-setuptools && \
    ln -sf /usr/bin/python3.9 /usr/bin/python3 && \
    ln -sf /usr/bin/pip3.9 /usr/bin/pip3 && \
    python3 -m pip install --upgrade pip setuptools avro-python3 && \
    dnf autoremove -y

# 4. Final cleanup to remove cache and leftover pip junk
RUN rm -rf /var/cache/dnf /tmp/* /root/.cache/pip && \
    rm -rf /usr/lib/python*/site-packages/{pip*,setuptools*}

# 5. Final verification (optional)
RUN ls -la /usr/share/java/kafka && \
    python3 --version && \
    pip3 --version && \
    pip3 show avro-python3

USER nobody
