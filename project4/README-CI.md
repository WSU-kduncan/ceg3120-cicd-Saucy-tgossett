# Project 4

## Part 1 - Docker-ize it

### CI Project Overview

#### What are we doing? Why?

This project containerizes a simple Angular web application (angular-site) using Docker. The goal is to learn the fundamentals of containerization, container image creation, and pushing an image to a public DockerHub repository. Using containers streamlines development and deployment. Which ensures consistency across different platforms.

#### Tools Used:

 - Docker
 - DockerHub
 - Angular CLI
 - Node.js (npm)
 - GitHub
 - node:18-bullseye

### Containerizing your Application:

#### How to install docker + dependencies on MACOS

  1. Open the [Docker Desktop](https://docs.docker.com/desktop/) link.
  2. Once inside scroll to the bottom of the page, you should see a `Install Docker Desktop` cube.
  3. In that cube three different systems will be listed - Mac, Windows, and Linix. Click Mac.
  4. You should see two buttons - `Docker Desktop for Mac with Apple silicon` and `Docker Desktop for Mac with Intel chip`.
  5. Find out what chip your macbook is - 2019 and below use intel chips.
  6. Double click on the button with the correct chip - in this case I click `Docker Desktop for Mac with Intel chip`.
  7. Once that download is finished drag the `Docker.dmg` file onto your desktop
  8. Open your termnial.
  9. Run these commands:
   
  ```
   $ sudo hdiutil attach Docker.dmg
   $ sudo /Volumes/Docker/Docker.app/Contents/MacOS/install
   $ sudo hdiutil detach /Volumes/Docker
  ```
  10. Docker Desktop is now installed to your applications folder.

#### Confirming Docker is Installed

To confirm if docker has been installed correctly run `docker --version` then test if you can run contianers by running `docker run hello-world` which will download and runs a test container from docker hub.

#### Trouble Shooting

If you're having a problem with Docker working after you've installed it on macOS (most commonly occurs a day or so after it was initially installed) first make sure `Docker Desktop` is open and working. You should see the docker whale at the top of your screen to the left of your batterie's percantage. If it sill isn't working use these links, [Docker not working on Mac(adding path)](https://stackoverflow.com/questions/64009138/docker-command-not-found-when-running-on-mac) and [Docker not working on Mac(redownloading with brew)](https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos)

#### Manually Setting Up a Container - NEED TO DO

  - how to build & configure a container (without building an image) that runs the `angular-site` application

#### Dockerfile & Building Images

##### Dockerfile Basics

Instructions:
  - `FROM`: Selects base image (Node.js 18)
      - (`Ubuntu` or in this case `node:18-bullseye`)
  - `WORKDIR`: Sets working directory in the container
  - `COPY`: Copies files into the container
  - `ADD`: Copies files from a specified source location into the container
  - `RUN`: Installs Angular CLI and dependencies
  - `EXPOSE`: Documents port 4200 (optional)
  - `CMD`: Starts the Angular app

With the instructions above you can create your `Dockerfile` with a similar format to this:

```
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
```

In this example `ADD` was used instead of `COPY` so `angular-bird.zip` could be copyed from a specified location without already haveing to be unzipped. Its best practice to use `COPY` unless you specifically need the archive-extracting or URL-downloading features of `ADD`.

##### Building the Image

Use this command to build your image: `docker build -t angular-site .` 
Where `-t` is tagging your image with the name `angular-site` and the `.` tells the consle that the `Dockerfile` it should use is in the same directory.

##### Run a Container from the Image

Use this command to run a container from your image: `docker run 4200:4200 angular-site`
Where `4200:4200` is port mapping between your host and the container and `angular-site` tells the container what image to use.

##### Verifying the Application 

###### From Container Side

There are two ways you can verify your container is running without leaving your terminal:
  - First you can use the command `docker ps -a` wich will bring up all containers on you system running or not. From there you can look under the status catorgory and if it says `up to [num]` where `[num]` is the number of hours/mins its been running.
  - Second you can use the command `docker log [name of container]` which will outprint something like this if its working:
```
- Generating browser application bundles (phase: setup)...
✔ Browser application bundle generation complete.

Initial Chunk Files   | Names         |  Raw Size
vendor.js             | vendor        |   2.42 MB |
polyfills.js          | polyfills     | 313.71 kB |
styles.css, styles.js | styles        | 224.62 kB |
main.js               | main          |  95.43 kB |
runtime.js            | runtime       |   6.52 kB |

| Initial Total |   3.04 MB

Build at: 2025-04-08T03:21:14.688Z - Hash: c79711fd8a99397d - Time: 35137ms

** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **


✔ Compiled successfully.
✔ Browser application bundle generation complete.

5 unchanged chunks

Build at: 2025-04-08T03:21:15.805Z - Hash: c79711fd8a99397d - Time: 833ms

✔ Compiled successfully.

```

###### From Host Side

To verify from host side all you have to do is open a tab in your browser type in `http://localhost:4200` if its working you should see your website.

#### Working with DockerHub

##### Create Public Repo in DockerHub
  1. Log into `https://hub.docker.com`
  2. Click `Repositories` → `Create Repository`
  3. Repository name: `YOURLASTNAME-ceg3120`
  4. Visibility: `Public`
  5. Click `Create`

##### Create a Personal Access Token (PAT)
  1. Go to your `DockerHub` → `Account Settings` → `Security` → `New Access Token`
  2. Change access permissions to `Read/Write`
  3. Copy the token (you will not see it again)

##### Authenticate with DockerHub via CLI

Use the command `docker login -u your-dockerhub-username`, when promted type in your personal access token (PAT)

##### Push Image to DockerHub

To push an image first you have to tag it with the command: `docker tag image-name your-dockerhub-username/YOURLASTNAME-CEG3120:tag-name` then use this command to push your image to `Dockerhub`: `docker push your-dockerhub-username/YOURLASTNAME-CEG3120:tag-name`

##### Link to my DockerHub repository for this project

   - [Saucydorito's CEG3120 Docker hub](https://hub.docker.com/repository/docker/saucydorito/gossett-ceg3120/general)

## Part 2 - GitHub Actions and DockerHub ( / 5)

- Configuring GitHub Secrets:
  - How to set a secret for use by GitHub Actions
  - What secret(s) are set for this project
- Behavior of GitHub workflow
  - summary of what your workflow does
  - **Link** to workflow file in your GitHub repository
  - summary of what a user would need to change or configure if using your workflow to duplicate your project

## Part 3 - Diagram ( / 2)

- Logically diagrammed steps for this project's continuous integration workflow

## `Dockerfile` ( / 4)
- builds from logical container image on DockerHub
- installs required dependencies
- copies application into container
- starts application when container is run using built image

## GitHub Action Workflow ( / 4)
- Secrets defined in repository settings
- triggers on logical action in repository
- build an image based on your `Dockerfile`
- pushes image to your DockerHub repository

Helpful Resources:
- [Unzipping in Terminal](https://www.reddit.com/r/techsupport/comments/rgo3mo/how_do_i_extract_zip_files_on_linux/)
- [Installing Node with homebrew](https://nodejs.org/en/download/package-manager/all)
- [Finding IP on Mac](https://www.whatismybrowser.com/detect/what-is-my-local-ip-address/#macos)
- [IP Command for Mac](https://discussions.apple.com/thread/7145789?sortBy=rank)
- [Docker not working on Mac(adding path)](https://stackoverflow.com/questions/64009138/docker-command-not-found-when-running-on-mac)
- [Docker not working on Mac(redownloading with brew)](https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos)
- [How to share files between Mac host and Docker containers](https://docs.docker.com/desktop/settings-and-maintenance/settings/#file-sharing)
- [`docker ps -a` not updating - run log show](https://discussions.apple.com/thread/8312866?sortBy=rank)
- [Docker buildx](https://stackoverflow.com/questions/75739545/docker-buildx-error-buildkit-is-enabled-but-the-buildx-component-is-missing-or)
- [config.json - Invalid character '"' after object key:value pair](https://stackoverflow.com/questions/60417430/jfrog-artifactory-invalid-character-after-object-keyvalue-pair)
- [Building a Dockerfile](https://docs.docker.com/get-started/workshop/09_image_best/)
