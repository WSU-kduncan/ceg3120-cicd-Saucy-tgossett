FROM node:18-bullseye

RUN apt update
RUN apt install -y npm
RUN npm install -g -y @angular/cli
RUN apt install -y unzip

WORKDIR /bird
ADD angular-bird.zip /bird/angular-bird.zip
RUN unzip angular-bird.zip
RUN rm angular-bird.zip

WORKDIR /bird/wsu-hw-ng-main

RUN npm install

EXPOSE 4200

CMD ["ng", "serve", "-o", "--host", "0.0.0.0"]
