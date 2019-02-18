### Docker Stack
- Docker stack has several different settings. [offical docs](https://docs.docker.com/compose/compose-file/) 
- Image in docker stack file cannot be built, customized image should be posted to docker hub first.
- Run `docker stack deploy <StackName> --compose-file=<File>`, `docker stack deploy vote --compose-file=docker-stack.yml`
- Run `docker stack ls` to check stacks in Swarm
- Run `docker stack ps <StackName>` to check services status in stack

### Secret in swarm
![Secret](https://res.cloudinary.com/deey9oou3/image/upload/v1548242881/Screen_Shot_2019-01-23_at_10.26.45_pm.png)
**Two ways to create a secret:**
- Create secret from file `docker secret create <SecretName> <FilePath>`
- Create secret from terminal `echo <Secret> | docker secret create my_secret -`
- Assign secret to service `docker service create --secret=<SecretName> ...`
- Example of creating wordpress container with secret `docker service create --name some-mysql -v /my/custom:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:tag`