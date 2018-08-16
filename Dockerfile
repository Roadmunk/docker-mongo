FROM mongo:4.1.1

ENV TZ=America/Toronto
RUN echo America/Toronto > /etc/timezone

ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/db049716e42767d39961e95dd9696103dca813f1/wait-for-it.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/wait-for-it.sh

COPY *.sh /usr/local/bin/
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
