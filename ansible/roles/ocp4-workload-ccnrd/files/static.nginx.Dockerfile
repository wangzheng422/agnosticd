FROM docker.io/library/nginx

RUN mkdir -p bootstrap/3.3.5/css/
RUN wget -O bootstrap/3.3.5/css/bootstrap.min.css https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css

