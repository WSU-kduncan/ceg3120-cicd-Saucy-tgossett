FROM node:18-bullseye

RUN apt update
RUN npm install -g -y @angular/cli


RUN mkdir /bird
WORKDIR /bird

RUN mkdir src

COPY wsu-hw-ng-main/package.json /bird/

RUN npm install 

COPY wsu-hw-ng-main/angular.json /bird/
COPY wsu-hw-ng-main/*.json /bird/
COPY *wsu-hw-ng-main/*.js /bird/
COPY wsu-hw-ng-main/README.md /bird/
COPY wsu-hw-ng-main/src/ /bird/src/

EXPOSE 4200

CMD ["ng", "serve", "-o", "--host", "0.0.0.0"]
