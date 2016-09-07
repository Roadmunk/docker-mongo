FROM mongo:3.0.12

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/wait-for-it.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["--replSet=development"]
