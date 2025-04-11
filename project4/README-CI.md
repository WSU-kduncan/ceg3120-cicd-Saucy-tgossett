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

#### **How to install docker + dependencies on MACOS**

  1. Open the [Docker Desktop](https://docs.docker.com/desktop/) link.
  2. Once inside scroll to the bottom of the page, you should see a `Install Docker Desktop` cube.
  3. In that cube three different systems will be listed - Mac, Windows, and Linix. Click **Mac**.
  4. Choose your chip:  
   - `Docker Desktop for Mac with Apple silicon`  
   - `Docker Desktop for Mac with Intel chip` (Macs from 2019 and earlier)
  5. Download the correct version.
  6. Once that download is finished drag the `Docker.dmg` file onto your desktop.
  7. Open your termnial.
  8. Run these commands:
   
  ```
   $ sudo hdiutil attach Docker.dmg
   $ sudo /Volumes/Docker/Docker.app/Contents/MacOS/install
   $ sudo hdiutil detach /Volumes/Docker
  ```
  9. Docker Desktop is now installed to your applications folder.

#### **Confirming Docker is Installed**

To confirm if docker has been installed correctly:
```
docker --version
docker run hello-world
```
This tests that Docker can run containers successfully.

#### **Trouble Shooting**

If you're having a problem with Docker working after you've installed it on macOS (most commonly occurs a day or so after it was initially installed) first make sure `Docker Desktop` is open and working. You should see the docker whale at the top of your screen to the left of your batterie's percantage. If it sill isn't working use these links, [Docker not working on Mac(adding path)](https://stackoverflow.com/questions/64009138/docker-command-not-found-when-running-on-mac) and [Docker not working on Mac(redownloading with brew)](https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos)

#### Manually Setting Up a Container

**IMPORTANT** 
You must be in the directory with only your `angular-bird.zip` in it.

##### **Step 1: Start a Container Using a Node Base Image**

```
docker run -it -p 8080:4200 --name manual-container -v ${PWD}:/angular-site node:18-bullseye bash
```
Explanation of Flags:
  - `-it`: Opens interactive terminal access inside the container.

  - `-p 8080:4200`: Maps port 8080 of the container to port 4200 on your host.

  - `--name manual-ng-container`: Names the container for easier reference.

  - `-v ${PWD}:/angular-site`: Mounts the current host directory (containing your Angular app `.zip`) into /angular-site inside the container.

  - `node:18-bullseye`: The base image with node:18-bullseye.

##### **Step 2: Install Dependencies Inside the Container**

Once inside the container:
```
apt update
apt install -y unzip
apt install -y npm
npm install -g @angular/cli
cd angular-site
```

Unzip `angular-bird.zip`:
```
unzip angular-bird.zip
rm -r angular-bird.zip
```

Navigate to your Angular project folder:
```
cd wsu-hw-ng-main
```

Install the project dependencies:
```
npm install
```

##### **Step 3: Run the Angular Application**

```
ng serve --host 0.0.0.0
```

##### **Verifying the Application** 

###### *From Container Side*

You should see output similar to:
```
** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **


✔ Compiled successfully.
✔ Browser application bundle generation complete.

5 unchanged chunks

Build at: 2025-04-08T03:21:15.805Z - Hash: c79711fd8a99397d - Time: 833ms

✔ Compiled successfully.

```

###### *From Host Side*

Open your browser type in 
```
http://localhost:8080
```
You should see your Angular site.( You will type in `8080` because we mapped our container to `8080:4200`)

#### Dockerfile & Building Images

##### **Dockerfile Basics**

Instructions:
  - `FROM`: Selects base image
      - e.g, `Ubuntu` or in this case `node:18-bullseye`
  - `WORKDIR`: Sets working directory in the container
  - `COPY`: Copies files into the container
  - `ADD`: Copies files from a specified source location into the container
  - `RUN`: Installs Angular CLI and dependencies
  - `EXPOSE`: Documents port 4200 (optional)
  - `CMD`: Starts the Angular app

Example `Dockerfile`:

```
FROM node:18-bullseye

RUN apt update
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
[Building a Dockerfile]
In this example `ADD` was used instead of `COPY` so `angular-bird.zip` could be copyed from a specified location without already haveing to be unzipped. Its best practice to use `COPY` unless you specifically need the archive-extracting or URL-downloading features of `ADD`. Head to [ADD vs. COPY](https://phoenixnap.com/kb/docker-add-vscopy#:~:text=In%20the%20part%20where%20their,remote%20location%20via%20a%20URL.).

##### **Building the Image**

```
 docker build -t image-name .
```
- `-t` is tagging your image 
- `.` refers to the current directory (where the Dockerfile is located)

##### **Run a Container from the Image**

```
docker run 4200:4200 --name container-name image-name bash
```
- `4200:4200` is port mapping between your host and the container
- `image-name` tells the container what image to use
-  `--name` gives the container a name of your choosing

##### **Verifying the Application** 

###### *From Container Side*

There are two ways you can verify your container is running without leaving your terminal:
  - `docker ps -a`  to list containers and check the Status column (e.g., Up X minutes)
  - `docker log container-name` which will outprint something like this if its working:
```
** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **


✔ Compiled successfully.
✔ Browser application bundle generation complete.

5 unchanged chunks

Build at: 2025-04-08T03:21:15.805Z - Hash: c79711fd8a99397d - Time: 833ms

✔ Compiled successfully.

```

###### *From Host Side*

Open your browser type in 
```
http://localhost:4200
```
You should see your Angular site.

#### Working with DockerHub

##### **Create Public Repo in DockerHub**
  1. Log into `https://hub.docker.com`
  2. Click `Repositories` → `Create Repository`
  3. Repository name: `YOURLASTNAME-ceg3120`
  4. Visibility: `Public`
  5. Click `Create`

##### **Create a Personal Access Token (PAT)**
  1. Go to your `DockerHub` → `Account Settings` → `Security` → `New Access Token`
  2. Change access permissions to `Read/Write`
  3. Copy the token (you will not see it again)

##### **Authenticate with DockerHub via CLI**

```
docker login -u your-dockerhub-username
```
When promted type in your personal access token (PAT)

##### **Push Image to DockerHub**

1. Tag your image
```
docker tag image-name your-dockerhub-username/YOURLASTNAME-CEG3120:tag-name
```
3. Push your image `Dockerhub`
```
docker push your-dockerhub-username/YOURLASTNAME-CEG3120:tag-name
```

##### **Link to my DockerHub repository for this project**

   - [Saucydorito's CEG3120 Docker hub](https://hub.docker.com/repository/docker/saucydorito/gossett-ceg3120/general)

## Part 2 - GitHub Actions and DockerHub

### Configuring GitHub Secrets:

 #### Creating a PAT for authentication 

   1. Click on you github profile and click on settings, Once in settings scroll to the bottom and look towards the bottom left of the screen.
   2. Click into `<> Devloper Settings`.
   3. Click on the `Personal Access token` drop down menu and select `Tokens(classic)`.
   4. In the top right of the screen click on `Genarate New Token` and select `Genarate New Token (classic)`.
   5. Add a Note - What is it for?
   6. Choose an experation date.
   7. Click on the check box next to `repo` and `workflow`.
   8. Scroll to the bottom and click `Generate token`.
   9. Copy your token and keep it some where safe.

  #### How to set repository Secrets for use by GitHub Actions

   ##### Secret(s) are set for this project

### CI with GitHub Actions:

  #### Summary of what your workflow does and when it does it

  #### Explanation of workflow steps

  #### Explanation / highlight of values that need updated if used in a different repository

   ##### changes in workflow
 
   ##### changes in repository
 
   #### Link to workflow file in your GitHub repository

### Testing & Validating

  #### How to test that your workflow did its tasking

  #### How to verify that the image in DockerHub works when a container is run using the image

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
- [Copy a Zip into Dockerfile](https://stackoverflow.com/questions/65066846/dockerfile-copy-zip-and-open-it)
- [Chat GPT - Used Only when scouring the web didn't work](https://chat.openai.com/)
- [ADD vs. COPY](https://phoenixnap.com/kb/docker-add-vs-copy#:~:text=In%20the%20part%20where%20their,remote%20location%20via%20a%20URL.)
