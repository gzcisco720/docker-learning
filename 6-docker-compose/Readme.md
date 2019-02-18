### Docker Compose

- **Deploy a wordpress by using existing knowledge**
```
docker run -d -v mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress --name mysql mysql:latest
# OR
docker run -d -v mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=wordpress --name mysql mysql:5.7
docker run --name wordpress -d -e WORDPRESS_DB_HOST=mysql:3306 -p 80:80 --link mysql wordpress
```
**Note:**
Error "MySQL Connection Error: (2054) The server requested authentication method unknown to the client" will happen, if running mysql 8.0 due to the new authentication method.
**Solution:**
```
docker exec -it mysql bash
mysql -u root -p
ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'root';
```

### About Experiments
- **Wordpress:**
This is a simple example of docker compose. 
`docker-compose up` to run all containers. 
`docker-compose stop` to stop the containers. 
`docker-compose down` to stop and remove the contianers.

- **Flask-redis:**
This is a simple of how to use user customised image in docker-compose.yml.
```
  build:
    context: .
    dockerfile: Dockerfile
```

- **Flask-scale:**
!(haproxy)[https://res.cloudinary.com/deey9oou3/image/upload/v1547181604/Screen_Shot_2019-01-11_at_3.38.19_pm.png]
To scale our web server we can run `docker-compose scale <ServiceName>=<Number>`, but the issue here is that we should not map the port of web to the same port on the host. so we removed the -port part under web service.
Then, we need start a load balancer container to send data to each web service container.
```
docker-compose up
docker-compose scale web=5
```
you can check simply check the result by running `curl 127.0.0.1:80` in your vm
OR
visiting localhost:8988 in the brower of your laptop

It can be found that, each time you send request to visit the page, the host name will be different. Because Load balancer will send our request to different web contianers.

- **Voting App**
This is the best example which is a voting project contains 5 containers.

https://github.com/dockersamples/example-voting-app