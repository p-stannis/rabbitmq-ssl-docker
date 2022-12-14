FROM rabbitmq:3.9

RUN rabbitmq-plugins enable --offline rabbitmq_management
RUN rabbitmq-plugins enable --offline rabbitmq_stomp
RUN rabbitmq-plugins enable --offline rabbitmq_web_stomp

RUN apt-get update \
	&& apt-get install openssl -y  \ 
	&& apt-get install dos2unix  \
	&& mkdir -p /home/testca/certs \
	&& mkdir -p /home/testca/private \
	&& chmod 700 /home/testca/private \
	&& echo 01 > /home/testca/serial \
	&& touch /home/testca/index.txt

COPY rabbitmq.config.AutoSSL /etc/rabbitmq/rabbitmq.config
RUN mkdir /ssl-certs
# COPY ssl-certs/ /ssl-certs
COPY openssl.cnf /home/testca
COPY prepare-server.sh generate-client-keys.sh /home/

RUN mkdir -p /home/server \
	&& mkdir -p /home/client \
	&& chmod +x /home/prepare-server.sh /home/generate-client-keys.sh

RUN dos2unix /home/prepare-server.sh

RUN dos2unix /home/generate-client-keys.sh

RUN /bin/bash /home/prepare-server.sh \
	&& /etc/init.d/rabbitmq-server restart

CMD /bin/bash /home/generate-client-keys.sh && rabbitmq-server

EXPOSE 15671 15672 15674 61613 61614
