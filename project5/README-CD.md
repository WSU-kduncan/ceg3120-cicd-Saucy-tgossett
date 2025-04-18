# Project 5 Rubric

Edited `Dockerfile` for **Project 5** -
```
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
```
- While using `ADD` in **Project 4** was cool and did technically work in order to build our own image off the current angular site design, `COPY` was implanted.

## GitHub Repository Contents

- [x] `README-CD.md` (and `README-CI.md` from P4)
- [x] `angular-site` folder with application
- [x] `Dockerfile`
- [x] GitHub action `yml` file in `.github/workflows`
- `deployment` folder with:
    - [ ] `bash` script
    - [ ] `webhook` / `hook` definition file
    - [ ] `webhook` service file

## Part 1 - Semantic Versioning

### Generating `tag`s

#### *How to See Tags in a `git` Repository*

```
git tag
```
  - Shows you all of your tags

or

```
git log
```
  - Shows you which commit the tag is linked to

#### *How to Generate a `tag` in a `git` Repository*

To create a new tag use the `git tag -a v*.*.*` command. Below is an example:
```
git tag -a v0.1.0
```
  - Tags the most recent commit with `v0.1.0`

or 

To create a new tag on an old commit (Find at the bottom of your commit within GitHub history) use the `git tag -a v*.*.* <commit-num>` command. Below is an example:
```
git tag -a v0.1.0 1caa2b1
```
  - Tags commit number `1caa2b1` with `v0.1.0`

#### *How to Push a Tag in a `git` Repository to GitHub*

```
git push origin v*.*.*
```
   - Which pushes that specific tag

or 
```
git push origin --tags
```
   - Which pushes all local tags

### CI with GitHub Actions

Below is my edited `docker-image.yml`

```
NEED TO EDIT
```

#### *Summary of What Workflow Does and When*

When the `.yml` workflow commit is pushed to the `[main]` branch it follows these steps:

***Triggering the Workflow:***
   ```
    name: docker-image-ci
    
    on:
      push:
        branches: [main]
      workflow-dispatch:
   ```
- `name` - Names your action
- `branches: [main]` - Runs the workflow as soon as changes are pushed to the main branch
- `workflow-dispatch:` - Allows you to manually trigger pipelines and enter unique inputs for each run

***Job Setup:***
   ```
    jobs:
      build-and-push:
        runs-on: ubuntu-latest
   ```
- The job `build-and-push` makes it so the `.yml` will run on the latest version of ubuntu within a virtual machine

***Steps:***

*Checkout step:*
```
-
name: Checkout
uses: actions/checkout@v4
```
- This step uses the `checkout action` to clone the repository code into the workflow's runner

*DockerHub Login:*
   ```
   -
   name: Log in to DockerHub
   uses: docker/login-action@v3
   with:
     username: ${{ secrets.DOCKERHUB_USERNAME }}
     password: ${{ secrets.DOCKERHUB_TOKEN }}
   ```
- This step logs into DockerHub using the provided secrets you created above

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
- This step builds the Docker image with the build context specified within the Dockerfile we created in `Part 1 - Docker-ize it` from **Project 4**, Adds the appropriate tag, then pushes it to DockerHub.
    - `context` - The directory where the Dockerfile is located
    - `file` - Path to the Dockerfile
    - `push` - Setting this to `true` causes the image to be pushed to DockerHub after it's successfully built
    - `tags` - Lists the `user` and the directory you want to push your completed image to

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

1. Log in to your DockerHub account
2. Verify that the image `DOCKER_USERNAME/REPO_NAME:TAG` appears in the desired repository

##### Run the Docker Container Locally:

1. Pull the image:
    - `docker pull DOCKER_USERBNAME/REPO_NAME:TAG`
2. Run the container:
    - `docker run --rm DOCKER_USERBNAME/REPO_NAME:TAG`
        - Confirm that the container starts up and the application or service in the container behaves as expected
        - Using the `--rm` flag will remove the container once you exit so everything stays clean. Remove tag if you want container to keep running once it has been closed.

## Part 2 - Deployment

1. EC2 Instance Details
    - [ ] AMI information
    - [ ] Instance type
    - [ ] Recommended volume size
    - [ ] Security Group configuration
    - [ ] Security Group configuration justification / explanation
2. Docker Setup on OS on the EC2 instance
    - [ ] How to install Docker for OS on the EC2 instance
    - [ ] Additional dependencies based on OS on the EC2 instance
    - [ ] How to confirm Docker is installed and that OS on the EC2 instance can successfully run containers
3. Testing on EC2 Instance
    - [ ] How to pull container image from DockerHub repository
    - [ ] How to run container from image
        - [ ] Note the differences between using the `-it` flag and the `-d` flags and which you would recommend once the testing phase is complete
    - How to verify that the container is successfully serving the Angular application
        - [ ] validate from container side
        - [ ] validate from host side
        - [ ] validate from an external connection (your physical system)
    - [ ] Steps to manually refresh the container application if a new image is available on DockerHub
4. Scripting Container Application Refresh
    - Create a `bash` script on your instance that will:
        - [ ] kill and remove the previously running container
        - [ ] pull the image from your DockerHub repository
        - [ ] start a new container with the freshly pulled image
    - [ ] How to test that the script successfully performs its tasking
    - [ ] **LINK to bash script** in repository
5. Configuring a `webhook` Listener on EC2 Instance
    - [ ] How to install [adnanh's `webhook`](https://github.com/adnanh/webhook) to the EC2 instance
    - [ ] How to verify successful installation
    - [ ] Summary of the `webhook` definition file
    - [ ] How to verify definition file was loaded by `webhook`
    - [ ] How to verify `webhook` is receiving payloads that trigger it
        - [ ] how to monitor logs from running `webhook`
        - [ ] what to look for in `docker` process views
    - [ ] **LINK to definition file** in repository
6. Configuring a Payload Sender
    - [ ] Justification for selecting GitHub or DockerHub as the payload sender
    - [ ] How to enable your selection to send payloads to the EC2 `webhook` listener
    - [ ] Explain what triggers will send a payload to the EC2 `webhook` listener
    - [ ] How to verify a successful payload delivery
7. Configure a `webhook` Service on EC2 Instance
    - [ ] Summary of `webhook` service file contents
    - [ ] How to `enable` and `start` the `webhook` service
    - [ ] How to verify `webhook` service is capturing payloads and triggering bash script
    - [ ] **LINK to service file** in repository

## Part 3 - Project Description & Diagram

1. Continuous Deployment Project Overview
    - [ ] What is the goal of this project
    - [ ] What tools are used in this project and what are their roles
    - Diagram
        - [ ] cleanly presented
        - Explains the project workflow in terms of:
            - [ ] developer role
            - [ ] GitHub role(s)
            - [ ] Docker Hub role(s)
            - [ ] EC2 instance role
                - [ ] delineates `webhook` listener vs container application
    - [ ] [If applicable] What is **not working** in this project
2. Resources Section
    - [ ] included (embedded at relevant points or in stand-alone section)
    - [ ] well formatted
3. README.md in root of repository:
    - [ ] Summarizes the project contents in the repository
    - [ ] Links to `README-CI.md` and `README-CD.md` with a brief summary about what users will find in each document

## GitHub Action Workflow
2 pts / task

- [ ] Secrets defined in repository settings
- [ ] triggers on push of tag
- [ ] collects metadata using action to generate container image tags
- [ ] builds an image using your `Dockerfile`
- [ ] pushes images to your DockerHub repository

## bash script
2 pts / task

- [ ] stops / kills and removes container process running application
- [ ] pulls `latest` image from DockerHub repository
- [ ] runs container from pulled image

## webhook hook definition file
2 pts / task

- [ ] successfully defines a hook
- [ ] runs bash script when triggered
- [ ] only triggers from validated sources (secret or verification of sender)

## webhook service file
2 pts / task

- [ ] correctly formatted
- [ ] starts webhook and loads hook definition file

## Part 4 - Demonstration

1. [ ] current state of site running on server, before making a change
    - show the page in the browser
    - show the docker status
2. [ ] making a change to the project file (from your local system)
3. [ ] `commit` and `push` of the change (from your local system)
4. [ ] `tag` the `commit` and `push` the `tag` (from your local system)
5. [ ] the GitHub Action triggering, relevant logs that it worked
6. [ ] DockerHub receiving a new set of tagged images (modified time should be visible)
7. [ ] Payload sent log from DockerHub or GitHub
8. [ ] status of `webhook` running as a service on the server
9. [ ] `webhook` logs that validate container refresh has been triggered
10. [ ] post-change state of site running on server
    - show the page in the browser
    - show the docker status

***Helpful Resources:***
- [How to Tag Old Commits](https://betterstack.com/community/questions/how-to-tag-older-commit-in-git/)
- [How to delete Tags](https://docs.aws.amazon.com/codecommit/latest/userguide/how-to-delete-tag.html#:~:text=To%20delete%20the%20Git%20tag,tag%20you%20want%20to%20delete.)

