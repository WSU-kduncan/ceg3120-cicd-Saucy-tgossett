FROM node:18-bullseye

RUN apt update
RUN npm install -g -y @angular/cli

WORKDIR /wsu-hw-ng-main

RUN mkdir /bird
WORKDIR /bird

COPY package.json /bird/

RUN npm install 

COPY angular.json /bird/
COPY.json /bird/
COPY *.js /bird/
COPY README.md /bird/
COPY ./src /bird/src/

EXPOSE 4200

CMD ["ng", "serve", "-o", "--host", "0.0.0.0"]
