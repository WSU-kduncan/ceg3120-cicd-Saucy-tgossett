FROM node:18-bullseye

RUN apt update
RUN apt install -y npm
RUN npm install -g -y @angular/cli
RUN apt install -y unzip

WORKDIR /angular-site
ADD angular-bird.zip /angular-site/angular-bird.zip
RUN unzip angular-bird.zip
RUN rm angular-bird.zip

WORKDIR /angular-site/wsu-hw-ng-main

RUN npm install

EXPOSE 4200

CMD ["ng", "serve", "-o", "--host", "0.0.0.0"]
