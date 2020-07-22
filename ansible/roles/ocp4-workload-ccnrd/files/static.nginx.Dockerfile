FROM registry.redhat.io/rhscl/nginx-114-rhel7:latest

USER root
RUN yum -y install wget

USER 1001
RUN cd /usr/share/nginx/html

RUN mkdir -p bootstrap/3.3.5/css/
RUN wget -O bootstrap/3.3.5/css/bootstrap.min.css https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css
RUN wget -O bootstrap-theme.min.css https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css

RUN mkdir -p bootstrap/3.3.5/js/
RUN wget -O bootstrap/3.3.5/js/bootstrap.min.js https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js

RUN mkdir -p ajax/libs/jquery/2.1.4/
RUN wget -O ajax/libs/jquery/2.1.4/jquery.min.js https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js

RUN mkdir -p bootstrap/3.3.5/fonts/
RUN wget -O bootstrap/3.3.5/fonts/glyphicons-halflings-regular.woff2  https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/fonts/glyphicons-halflings-regular.woff2
RUN wget -O bootstrap/3.3.5/fonts/glyphicons-halflings-regular.woff https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/fonts/glyphicons-halflings-regular.woff
RUN wget -O bootstrap/3.3.5/fonts/glyphicons-halflings-regular.ttf https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/fonts/glyphicons-halflings-regular.ttf


