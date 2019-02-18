## About this experiment

This experiment includes two containers flask web server and redis. They are connected together by using default bridge network.
Everytime the server is visited, browser will show "Hello Container World! I have been seen <Number> times and my hostname is <ID>."

### Run 
- `docker pull redis`
- `docker run --name redis -d redis`
- `cd flask-redis`
- `docker build -t flask`
- `docker run --name flask -d -p 5000:5000 --link redis -e REDIS_HOST=redis flusk`
