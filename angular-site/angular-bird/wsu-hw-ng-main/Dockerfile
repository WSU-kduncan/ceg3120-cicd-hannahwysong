FROM node:18-bullseye

RUN apt update 
RUN apt install -y npm
RUN npm install -g @angular/cli

RUN mkdir /build
WORKDIR /build

COPY package*.json /build/ 

RUN npm install 

COPY angular.json /build/
COPY *.json /build/
COPY *.js /build/
COPY README.md /build/
COPY ./src /build/src/

EXPOSE 4200 

CMD ["ng", "serve", "--host", "0.0.0.0"]
