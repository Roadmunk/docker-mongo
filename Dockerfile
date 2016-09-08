FROM mongo:3.0.12

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/a454892f3c2ebbc22bd15e446415b8fcb7c1cfa4/wait-for-it.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/wait-for-it.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--replSet=development"]
