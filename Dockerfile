FROM mongo:3.4.4

ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/a454892f3c2ebbc22bd15e446415b8fcb7c1cfa4/wait-for-it.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/wait-for-it.sh

COPY *.sh /usr/local/bin/
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
