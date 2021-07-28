# PHP7.0-OCI
PHP 7.0 With OCI8 Database Driver

# Build Image
$ docker build -t webserver-7.0 .

# Run Container
$ docker run -d --name Webserver -v D:/Webserver:/var/www/html/ -p 80:80 webserver-7.0

Change:  
1. D:/Webserver with your project location on host machine
