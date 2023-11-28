FROM centos:centos7
ARG mysql_url
ARG mysql_asc_url

RUN groupadd -r mysql && useradd -r -g mysql mysql

#RUN apt-get update && \
#    apt-get install -y curl binutils

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5

#RUN locale-gen en_US.UTF-8 &&\
#    update-locale

ENV LANG en_US.UTF-8

ENV LANGUAGE en_US:en

ENV LC_ALL en_US.UTF-8

RUN curl -SL "$mysql_url" -o mysql.tar.gz && \
    curl -SL "$mysql_asc_url" -o mysql.tar.gz.asc && \
    gpg --verify mysql.tar.gz.asc && \
    mkdir /usr/local/mysql && \
    tar -xzf mysql.tar.gz -C /usr/local/mysql --strip-components=1 && \
    rm mysql.tar.gz* && \
    rm -rf /usr/local/mysql/mysql-test /usr/local/mysql/sql-bench && \
    rm -rf /usr/local/mysql/bin/*-debug /usr/local/mysql/bin/*_embedded && \
    find /usr/local/mysql -type f -name "*.a" -delete && \
    { find /usr/local/mysql -type f -executable -exec strip --strip-all '{}' + || true; } && \
# apt-get purge -y --auto-remove binutils && \
    rm -rf /var/lib/apt/lists/*

ENV PATH $PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts

WORKDIR /usr/local/mysql

VOLUME /var/lib/mysql

VOLUME /var/log/mysql

COPY mysql-5.1/my.cnf /etc/my.cnf

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld", "--datadir=/var/lib/mysql", "--user=mysql"]
