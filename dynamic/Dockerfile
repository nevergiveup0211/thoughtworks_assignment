FROM tomcat
EXPOSE 8080

# WORKDIR /usr/local/tomcat/webapps
CMD mkdir -p /Users/dcameron/persistence/files\*
ADD https://s3.amazonaws.com/infra-assessment/companyNews.war /usr/local/tomcat/webapps
# ENTRYPOINT /usr/local/tomcat/bin/startup.sh
CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]
