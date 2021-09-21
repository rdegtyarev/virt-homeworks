FROM node
WORKDIR /var/www
RUN git clone https://github.com/simplicitesoftware/nodejs-demo.git

WORKDIR /var/www/nodejs-demo
EXPOSE 3000

RUN npm install

ENTRYPOINT npm start --host 0.0.0.0