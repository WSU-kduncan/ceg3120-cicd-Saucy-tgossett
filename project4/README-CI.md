# Project 4

## Part 1 - Docker-ize it

### CI Project Overview

#### *What are We Doing? Why?*

This project containerizes a simple Angular web application (angular-site) using Docker. The goal is to learn the fundamentals of
containerization, container image creation, and pushing an image to a public DockerHub repository. Using containers streamlines
development and deployment. Which ensures consistency across different platforms.

#### *Tools Used:*

- Docker
- DockerHub
- Angular CLI
- Node.js (npm)
- GitHub
- node:18-bullseye

### Containerizing your Application:

#### *How to Install Docker + Dependencies on MACOS*

1. Open [Docker Desktop](https://docs.docker.com/desktop/).
2. Once inside scroll to the bottom of the page, you should see a `Install Docker Desktop` cube.
3. In that cube three different systems will be listed - Mac, Windows, and Linux. Click **Mac**.
4. Choose your chip:
    - `Docker Desktop for Mac with Apple silicon`.
    - `Docker Desktop for Mac with Intel chip` (Macs from 2019 and earlier).
5. Download the correct version.
6. Once that download is finished drag the `Docker.dmg` file onto your desktop.
7. Open your terminal.
8. Run these commands:
    ```
     $ sudo hdiutil attach Docker.dmg
     $ sudo /Volumes/Docker/Docker.app/Contents/MacOS/install
     $ sudo hdiutil detach /Volumes/Docker
    ```
9. Docker Desktop is now installed to your applications folder.

#### *Confirming Docker is Installed*

To confirm if docker has been installed correctly and test that Docker can run containers successfully use the code below:
  ```
  docker --version
  docker run hello-world
  ```

#### *Trouble Shooting*

If you're having a problem with Docker working after you've installed it on macOS (most commonly occurs a day or so after it was
initially installed) first make sure `Docker Desktop` is open and working. You should see the docker whale at the top of your screen to
the left of your batteries' percentage. If it still isn't working follow the steps within these links, [Docker not working on Mac(adding path)](https://stackoverflow.com/questions/64009138/docker-command-not-found-when-running-on-mac) and [Docker not working on Mac(re-downloading with brew)](https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos).

#### *Manually Setting Up a Container*

> ***IMPORTANT***
>
> You must be in the directory with your `angular-bird.zip` in it!

##### Step 1: Start a Container Using a Node Base Image

```
docker run -it -p 8080:4200 --name manual-container -v ${PWD}:/angular-site node:18-bullseye bash
```
Explanation of Flags:
- `-it` - Opens interactive terminal access inside the container.
- `-p 8080:4200` - Maps port 8080 of the container to port 4200 on your host.
- `--name manual-ng-container` - Names the container for easier reference.
- `-v ${PWD}:/angular-site` - Mounts the current host directory (containing your Angular app `.zip`) into /angular-site inside the container.
- `node:18-bullseye` - The base image with node:18-bullseye.

##### Step 2: Install Dependencies Inside the Container

Once inside the container:
```
apt update
apt install -y unzip
apt install -y npm
npm install -g @angular/cli
cd angular-site
```

Unzips `angular-bird.zip`:
```
unzip angular-bird.zip
rm -r angular-bird.zip
```

Navigates to your Angular project folder:
```
cd wsu-hw-ng-main
```

Installs the project dependencies:
```
npm install
```

##### Step 3: Run the Angular Application

```
ng serve --host 0.0.0.0
```

##### Verifying the Application

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

Open your browser type in:
```
http://localhost:8080
```
You should see your Angular site ( You will type in `8080` because we mapped our container to `8080:4200`).

#### *Dockerfile & Building Images*

##### Dockerfile Basics

Instructions:
- `FROM` - Selects base image.
    - e.g, `Ubuntu` or in this case `node:18-bullseye`
- `WORKDIR` - Sets working directory in the container.
- `COPY` - Copies files into the container.
- `ADD` - Copies files from a specified source location into the container.
- `RUN` - Installs Angular CLI and dependencies.
- `EXPOSE` - Documents port 4200 (optional).
- `CMD` - Starts the Angular app.

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

> In this example `ADD` was used instead of `COPY` so `angular-bird.zip` could be copied from a specified location without already having to be unzipped. Its best practice to use `COPY` unless you specifically need the archive-extracting or URL-downloading features of `ADD`. Head to [ADD vs. COPY](https://phoenixnap.com/kb/docker-add-vscopy#:~:text=In%20the%20part%20where%20their,remote%20location%20via%20a%20URL.) to learn more.

##### Building the Image

```
 docker build -t image-name .
```
- `-t` - Is tagging your image.
- `.` - Refers to the current directory (where the Dockerfile is located).

##### Run a Container from the Image

```
docker run 4200:4200 --name container-name image-name bash
```
- `4200:4200` - Is port mapping between your host and the container.
- `image-name` - Tells the container what image to use.
-  `--name` - Gives the container a name of your choosing.

##### Verifying the Application

###### *From Container Side*

There are two ways you can verify your container is running without leaving your terminal:
- `docker ps -a`  to list containers and check the Status column (e.g., Up X minutes).
- `docker log container-name` which will out-print something like this if its working:
```
** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **


✔ Compiled successfully.
✔ Browser application bundle generation complete.

5 unchanged chunks

Build at: 2025-04-08T03:21:15.805Z - Hash: c79711fd8a99397d - Time: 833ms

✔ Compiled successfully.

```

###### *From Host Side*

Open your browser type in:
```
http://localhost:4200
```
You should see your Angular site.

#### *Working with DockerHub*

##### Create Public Repo in DockerHub
1. Log into [DockerHub](https://hub.docker.com).
2. Click `Repositories` → `Create Repository`.
3. Repository name: `YOURLASTNAME-ceg3120`.
4. Visibility: `Public`.
5. Click `Create`.

##### Creating a Personal Access Token (PAT)
1. Go to your `DockerHub` → `Account Settings` → `Personal Access Tokens`.
2. Click `Generate new token`.
3. Name your token.
4. Change access permissions to `Read/Write`.
5. Copy the token (you will not see it again).

##### Authenticate with DockerHub via CLI

```
docker login -u your-dockerhub-username
```
When promoted copy over your personal access token (PAT).

##### Push Image to DockerHub

1. Tag your image
      ```
      docker tag image-name your-dockerhub-username/YOURLASTNAME-CEG3120:tag-name
      ```
2. Push your image `Dockerhub`
      ```
      docker push your-dockerhub-username/YOURLASTNAME-CEG3120:tag-name
      ```

##### Link to my DockerHub Repository

- [Saucydorito's CEG3120 Docker hub](https://hub.docker.com/repository/docker/saucydorito/gossett-ceg3120/general)

## Part 2 - GitHub Actions and DockerHub

### Configuring GitHub Secrets:

#### *Creating a DockerHub PAT*

We have already done this above please reference [Creating a Personal Access Token (PAT)](#Creating-a-Personal-Access-Token-(PAT)) if you need a reminder!

#### *How to set repository Secrets for use by GitHub Actions*

1. In your GitHub repository, go to `Settings` →  `Secrets and variables` →  `Actions`
2. Add the following secrets in your `Repository secrets`:
    - `DOCKERHUB_USERNAME`:
        - This secret holds your DockerHub username.
    - `DOCKER_TOKEN`:
        - This secret holds the DockerHub access token that you created in [Creating a Personal Access Token (PAT)](#Creating-a-Personal-Access-Token-(PAT)).

### CI with GitHub Actions:

Below is my `docker-image.yml`:

```
name: docker-image-ci

on:
  push:
    branches: [main]
    workflow-dispatch:
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      -
        name: Checkout
        uses: actions/checkout@v4
      -
        name: Log in to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      -
        name: Build Docker image
        uses: docker/build-push-action@v6
        with:
          context: ./project4/angular-site
          file: ./project4/angular-site/Dockerfile
          push: true
          tags: saucydorito/gossett-ceg3120:angular-site
```

#### *Summary of What your Workflow Does and When*

When the `.yml` workflow commit is pushed to the `[main]` branch it follows these steps:

***Triggering the Workflow:***
   ```
    name: docker-image-ci
    
    on:
      push:
        branches: [main]
      workflow-dispatch:
   ```
- `name` - Names your action.
- `branches: [main]` - Runs the workflow as soon as changes are pushed to the main branch.
- `workflow-dispatch:` - Allows you to manually trigger pipelines and enter unique inputs for each run.

***Job Setup:***
   ```
    jobs:
      build-and-push:
        runs-on: ubuntu-latest
   ```
- The job `build-and-push` makes it so the `.yml` will run on the latest version of ubuntu within a virtual machine.

***Steps:***

*Checkout step:*
```
-
name: Checkout
uses: actions/checkout@v4
```
- This step uses the `checkout action` to clone the repository code into the workflow's runner.

*DockerHub Login:*
   ```
   -
   name: Log in to DockerHub
   uses: docker/login-action@v3
   with:
     username: ${{ secrets.DOCKERHUB_USERNAME }}
     password: ${{ secrets.DOCKERHUB_TOKEN }}
   ```
- This step logs into DockerHub using the provided secrets you created above.

*Build and Push Docker Image:*
  ```
  -
  name: Build Docker image
  uses: docker/build-push-action@v6
  with:
    context: ./project4/angular-site
    file: ./project4/angular-site/Dockerfile
    push: true
    tags: saucydorito/gossett-ceg3120-angular-site:latest
  ```
- This step builds the Docker image with the build context specified within the Dockerfile you created in [Part 1 - Docker-ize it](#Part-1---Docker-ize-it), then pushes it to DockerHub.
    - `context` - The directory where the Dockerfile is located.
    - `file` - Path to the Dockerfile.
    - `push` - Setting this to `true` causes the image to be pushed to DockerHub after it's successfully built.
    - `tags` - Lists the `user` and the directory you want to push your completed image to.

#### *What Needs to be Updated if using Workflow in a Different Repository*

If you were going to recreate this workflow in another repository, you will need to update the following:

1. **Build Context and Dockerfile Path:**
    - Update the context and file values if your Dockerfile is in a different location.
```
context: ./your/new/path
file: ./your/new/path/Dockerfile
```
2. **Image Tags:**
    - Replace `saucydorito/gossett-ceg3120-angular-site:latest` with your DockerHub repository name and desired tag.
```
tags: yourdockerhubusername/your-repo:latest
```
3. **Repository Secrets:**
    - Ensure the secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are set in your repository and if your using different secret names make sure to update the workflow accordingly.

#### *Link to Workflow File in my GitHub Repository*

- [Link to my Workflow File in GitHub](https://github.com/WSU-kduncan/ceg3120-cicd-Saucy-tgossett/blob/main/.github/workflows/docker-image.yml)

### Testing & Validating

#### *How to Test that your Workflow did its Tasking*

##### Monitor the Run:

1. Navigate to the Actions tab in your repository.
2. Check that the job steps complete without errors.
    - If your quick enough you can watch it building!
3. Verify that the logs indicate a successful Docker image build and push.

#### *How to Verify that the Image in DockerHub Works*

##### Check DockerHub Repository:

1. Log in to your DockerHub account.
2. Verify that the image `DOCKER_USERNAME/REPO_NAME:TAG` appears in the desired repository.

##### Run the Docker Container Locally:

1. Pull the image:
    - `docker pull DOCKER_USERBNAME/REPO_NAME:TAG`
2. Run the container:
    - `docker run --rm DOCKER_USERBNAME/REPO_NAME:TAG`
        - Confirm that the container starts up and the application or service in the container behaves as expected.
        - Using the `--rm` flag will remove the container once you exit so everything stays clean. Remove tag if you want container to keep running once it has been closed.

## Part 3 - Diagram ( / 2)

- Logically diagrammed steps for this project's continuous integration workflow


***Helpful Resources:***
- [Unzipping in Terminal](https://www.reddit.com/r/techsupport/comments/rgo3mo/how_do_i_extract_zip_files_on_linux/)
- [Installing Node with homebrew](https://nodejs.org/en/download/package-manager/all)
- [Finding IP on Mac](https://www.whatismybrowser.com/detect/what-is-my-local-ip-address/#macos)
- [IP Command for Mac](https://discussions.apple.com/thread/7145789?sortBy=rank)
- [Docker not working on Mac(adding path)](https://stackoverflow.com/questions/64009138/docker-command-not-found-when-running-on-mac)
- [Docker not working on Mac(re-downloading with brew)](https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos)
- [How to share files between Mac host and Docker containers](https://docs.docker.com/desktop/settings-and-maintenance/settings/#file-sharing)
- [`docker ps -a` not updating - run log show](https://discussions.apple.com/thread/8312866?sortBy=rank)
- [Docker buildx](https://stackoverflow.com/questions/75739545/docker-buildx-error-buildkit-is-enabled-but-the-buildx-component-is-missing-or)
- [config.json - Invalid character '"' after object key:value pair](https://stackoverflow.com/questions/60417430/jfrog-artifactory-invalid-character-after-object-keyvalue-pair)
- [Building a Dockerfile](https://docs.docker.com/get-started/workshop/09_image_best/)
- [Copy a Zip into Dockerfile](https://stackoverflow.com/questions/65066846/dockerfile-copy-zip-and-open-it)
- [ChatGPT - Used Only when Scouring the Web didn't Work](https://chat.openai.com/)
- [ADD vs. COPY](https://phoenixnap.com/kb/docker-add-vs-copy#:~:text=In%20the%20part%20where%20their,remote%20location%20via%20a%20URL.)
- [What is `workflow_dispatch`](https://docs.prismacloud.io/en/enterprise-edition/policy-reference/build-integrity-policies/github-actions-policies/github-actions-contain-workflow-dispatch-input-parameters)
- [What is the actions/checkout action?](https://spacelift.io/blog/github-actions-checkout)
