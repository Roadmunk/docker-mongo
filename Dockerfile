FROM mongo:3.6.4

ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/a2acebe3f5513642f19c0d6bed565b23096eac60/wait-for-it.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/wait-for-it.sh

COPY *.sh /usr/local/bin/
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
