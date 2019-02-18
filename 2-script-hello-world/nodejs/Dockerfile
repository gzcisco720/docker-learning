FROM node:latest
COPY ["app.js", "package*.json", "/app/"]
WORKDIR /app/
RUN npm install
EXPOSE 8988
CMD [ "node","./app.js" ]