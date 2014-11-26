FROM larsks/f21base

RUN yum -y install \
	haproxy \
	python-jinja2; \
	yum clean all

COPY gen-haproxy-config /usr/bin/gen-haproxy-config
RUN chmod 755 /usr/bin/gen-haproxy-config

RUN mkdir -p /etc/haproxy/templates
COPY haproxy.cfg.tmpl /etc/haproxy/templates/haproxy.cfg.tmpl

COPY start.sh /start.sh
RUN chmod 755 start.sh

CMD ["/start.sh"]

