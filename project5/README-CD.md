# Project 5 Rubric

<p align="center">

![Flow Diagram](<diagram/CICD-Project-flow.png>)
</p>

Edited `Dockerfile` for **Project 5** -
```
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
```
> [!NOTE]
> While using `ADD` in **Project 4** was cool and did technically work in order to build our own image off the current angular site design, `COPY` will be implanted in this project.

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
git tag -a v0.1.0 1caa2b1 -m "write commit message here"
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

Below is my `CD.yml`file which was made by editing my `docker-image.yml`

```
name: docker-image-cd

on:
  push:
    branches:
      - 'main'
    tags:
      - 'v*.*.*'
  pull_request:
    branches:
      - 'main'
  workflow_dispatch:
  
jobs:
  build-and-push:
    runs-on: ubuntu-latest

    steps:
      - 
       name: Checkout
       uses: actions/checkout@v4

      - 
       name: Docker meta
       id: meta
       uses: docker/metadata-action@v5
       with:
         images: saucydorito/gossett-ceg3120
         tags: |
           type=semver,pattern={{major}}
           type=semver,pattern={{major}}.{{minor}}
           type=semver,pattern={{version}}

      - 
       name: Login to DockerHub
       uses: docker/login-action@v3
       with:
         username: ${{ secrets.DOCKERHUB_USERNAME }}
         password: ${{ secrets.DOCKERHUB_TOKEN }}  
        
      - 
       name: Build and push
       uses: docker/build-push-action@v6
       with:
         context: ./project5/angular-site
         file: ./project5/angular-site/Dockerfile
         push: ${{ github.event_name != 'pull_request' }}
         tags: ${{ steps.meta.outputs.tags }}
         labels: ${{ steps.meta.outputs.labels }}
      
```

#### *Summary of What Workflow Does and When*

When a new git tag is pushed to the `main` branch the `.yml` follows these steps:

***Triggering the Workflow:***
```
name: docker-image-cd # Names your action

on:                   # Tells the action to start and
  push:               # push
    branches:         # to branch main
      - 'main'        # 
    tags:             # when a git tag 
      - 'v*.*.*'      # with this format is pushed to github
  workflow_dispatch:  # Allows you to manually start action
```

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

*Docker Metadata:*
```
- 
 name: Docker meta
 id: meta
 uses: docker/metadata-action@v5
 with:
   images: saucydorito/gossett-ceg3120
   tags: |
     type=semver,pattern={{major}}
     type=semver,pattern={{major}}.{{minor}}
     type=semver,pattern={{version}}
```
- This step uses `docker/metadata-action@v5` to label the image within the `saucydorito/gossett-ceg3120` Dockerhub repo with the given tag parameters/`type`s. 

Ex: If you were to push the tag `v5.0.0` this is what the `.yml` sees.
```
type=semver,pattern={{5}}
type=semver,pattern={{5}}.{{0}}
type=semver,pattern={{5.0.0}}
```

*DockerHub Login:*
   ```
   -
    name: Log in to DockerHub
    uses: docker/login-action@v3
    with:
      username: ${{ secrets.DOCKERHUB_USERNAME }}
      password: ${{ secrets.DOCKERHUB_TOKEN }}
   ```
- This step logs into DockerHub using the repository secrets created in **Project 4**

*Build and Push Docker Image:*
  ```
  - 
   name: Build and push
   uses: docker/build-push-action@v6
   with:
     context: ./project5/angular-site
     file: ./project5/angular-site/Dockerfile
     push: ${{ github.event_name != 'pull_request' }}
     tags: ${{ steps.meta.outputs.tags }}
     labels: ${{ steps.meta.outputs.labels }}
  ```
- This step builds the Docker image with the build context specified within the Dockerfile created in `Part 1 - Docker-ize it` from **Project 4**, Adds the appropriate tag, then pushes it to DockerHub.
    - `context` - The directory where the Dockerfile is located
    - `file` - Path to the Dockerfile
    - `push: ${{ github.event_name != 'pull_request' }}` means only `push` if this wasn't a *pull request*.
    - `tags: ${{ steps.meta.outputs.tags }}` applies the tags created from the metadata step (e.g. 1, 1.2, 1.2.3, latest). 
    - `labels: ${{ steps.meta.outputs.labels }}` applies the labels created during the metadata step to the image.

#### *What Needs to be Updated if using Workflow in a Different Repository*

> [!IMPORTANT]
>If you were going to recreate this workflow in another repository, you will need to update the following:

**Build Context and Dockerfile Path:**
  - Update the context and file values if your Dockerfile is in a different location.
```
context: ./your/new/path
file: ./your/new/path/Dockerfile
```
**Image Tags:**
  - Replace `saucydorito/gossett-ceg3120` with your DockerHub username and repository name.
```
tags: your-dockerhub-user-name/your-repo
```

> [!NOTE]
> You don't have to, but you can also edit the `tag` patterns so your `.yml` pushes different tags from above. Such as only having `type=semver,pattern={{version}}` so it only pushes the full version and `latest` to Dockerhub.

**Repository Secrets:**

> [!IMPORTANT]
> Ensure the secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` are set in your repository secretes and if your using different secret names make sure to update the workflow accordingly.

#### *Link to Workflow File in my GitHub Repository*

- [Link to my Workflow File in GitHub](https://github.com/WSU-kduncan/ceg3120-cicd-Saucy-tgossett/blob/main/.github/workflows/CD.yml)

### Testing & Validating

#### *How to Test that your Workflow did its Tasking*

##### Look at your Actions tab

> [!IMPORTANT]  
> Do the steps below **AFTER** pushing your `tag` (`v*.*.*`) to GitHub.
> >[!NOTE]  
> >Please note that you still have to commit and push you `.yml` first. It will **not** work until you push the `tag`.


1. Navigate to the Actions tab in your repository.
2. Check that the job steps complete without errors.
    - If your quick enough you can watch it building!
3. Verify that the logs indicate a successful Docker image build and push.

#### *How to Verify that the Image in DockerHub Works*

##### Check DockerHub Repository:

1. Log in to your DockerHub account
2. Verify that the image within your Dockerhub repository is labeled with the correct `tag`s

##### Run the Docker Container Locally:

1. Pull the Image:
   ```
   docker pull DOCKERHUB_USERNAME/REPO_NAME:tag
   ```
   OR
   ```
   docker pull DOCKERHUB_USERNAME/REPO_NAME:latest
   ```
2. Run the container:
    - `docker run --rm  -p 4200:4200 DOCKERHUB_USERNAME/REPO_NAME:tag`
        - Confirm that the container starts up and the application runs on port `4200`. To do this just got to http://localhost:4200 within your browser.
> [!TIP]
> Using the `--rm` flag will remove the container once you exit so everything stays clean. Remove tag if you want container to keep running once it has been closed.

## Part 2 - Deployment

### EC2 Instance Details

#### *AMI Information*

***AMI ID:***
```
ami-084568db4383264d4
```

***AMI Name:***
```
ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305
```

#### *Instance type*

```
t2.medium
```
  - `t2.meduim` has 2 CPU Core and 4 GB RAM included.

> [!WARNING]
> Without at least 2 CPUs your script will **NOT** run!

#### *Recommended volume size* 

30 GB *minimum*

#### *Security Group configuration*

##### Inbound Rules

| Source            | Port Range | Protocol  |             Explanation              |
|:------------------|:----------:|:---------:|:------------------------------------:|
| 0.0.0.0/0         |    443     |    TPC    | Allows HTTPS web traffic from any IP | 
| 0.0.0.0/0         |     22     |    TPC    |    Allows you to SSH from any IP     | 
| 0.0.0.0/0         |     80     |    TPC    | Allows HTTP web traffic from any IP  |

##### Outbound Rules

| Port Range | Protocol |   Destination    |                Explanation                |
|:----------:|:--------:|:----------------:|:-----------------------------------------:| 
|     22     |   TPC    | 67.43.200.187/32 |         SSH from my parents house         | 
|     22     |   TPC    | 68.142.169.46/32 |             SSH from my house             |
|    443     |   TPC    | 18.234.196.16/32 | HTTPS requests from within VPC CIDR block | 
|     80     |   TPC    | 18.234.196.16/32 | HTTP requests from within VPC CIDR block  |
|     22     |   TPC    | 140.49.80.172/32 |             SSH From BF House             |
|     22     |   TPC    |  130.108.0.0/16  |               SSH From WSU                |

#### *Setting up Docker on the EC2 instance*

##### How to install Docker for OS on the EC2 instance

Follow the steps within this link [Installing Docker on ubuntu within EC2](https://medium.com/@srijaanaparthy/step-by-step-guide-to-install-docker-on-ubuntu-in-aws-a39746e5a63d) or follow the steps below:
1. `SSH` into you **EC2** instance.
2. Update the package index - `sudo apt-get update`
3. Install docker - `sudo apt-get install docker.io -y`
4. Start docker - `sudo systemctl start docker`
5. Enable docker - `sudo systemctl enable docker`
     > [!NOTE]
   > Enabling docker starts the Docker service automatically when the instance starts!
6. Use docker without sudo - `sudo chmod 666 /var/run/docker.sock`


#### *Additional dependencies based on OS on the EC2 instance*--??

#### *Confirming Docker is installed and can successfully run containers*

First use `docker --version` to make sure docker is installed then to verify it can run containers you can use `docker run hello-world`. If the installation is successful, you will see a message indicating that Docker is working correctly. 



#### *Testing on EC2 Instance*


##### How to pull container image from DockerHub repository

```
docker pull Docker-hub-username/repo:tag
```
- Ex. `docker pull saucydorito/gossett-ceg3120:latest`

> [!TIP]
> Run `docker images` to make sure your image was downloaded properly


##### How to run container from image

```
docker run -it -p 4200:4200 --name container-name Docker-hub-username/repo:tag
```
- `-it` vs `-d`: Use `-it` (interactive terminal) for testing/debugging. Use `-d` (detached) for production.
- Ex. `docker run -it -d -p 4200:4200 --name angular saucydorito/gossett-ceg3120:latest`

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

###### *From EC2*

```
curl localhost:4200
```

###### *Externally (Your PC)*

Open your browser type in:
```
http://EC2-public-ip:4200
```
You should see your Angular site.

##### How to manually refresh the container if a new image is available on DockerHub

1. Check Current Version - `docker images`
2. Pull Latest Docker Image - `docker pull [image]:latest`
     - Ex. `docker pull angular:latest`
3. Kill the Old Container
   ```
   docker stop [container-id-or-name]
   docker rm [container-id-or-name]
   ```
4.  Launch New Updated Container 
    ```
    docker run -it -d -p 4200:4200 --name [container-name] Docker-hub-username/repo:tag
    ```

#### *Scripting Container Application Refresh*

##### Creating a `bash` script on your instance

```
#!/usr/bin/env bash

IMAGE="saucydorito/gossett-ceg3120:latest"
CONTAINER="angular-site"

# 1) Pull latest image
docker pull "$IMAGE"

# 2) Stop & remove old container (ignore errors)
docker stop "$CONTAINER" || true
docker rm   "$CONTAINER" || true

# 3) Start new container
docker run -d -p 4200:4200 --name "$CONTAINER" "$IMAGE"                                                      
```
- `IMAGE="saucydorito/gossett-ceg3120:latest"` - Initializes image with the latest image in the repo listed
- `CONTAINER="angular-site"` - Initializes container name with `angular-site`
- `docker stop $CONTAINER` and  `docker rm $CONTAINER` - kills and remove the previously running container
- `docker pull $IMAGE` - pulls the image from your DockerHub repository
- `docker run -d -p 4200:4200 --name $CONTAINER $IMAGE` - starts a new container with the freshly pulled image

> [!NOTE]
> Made with the help of ChatGPT
  
##### Verifying that the script successfully performs its tasking

To make sure your script is running follow the commands below:
```
chmod +x redeploy_container.sh
```
then
```
./redeploy_container.sh
```
you should see an output similar to this:
```
latest: Pulling from saucydorito/gossett-ceg3120
Digest: sha256:d8da7c92a4e5a52425e87f490b98495ebf10053b20a919917bc8c87ca232d1a8
Status: Image is up to date for saucydorito/gossett-ceg3120:latest
docker.io/saucydorito/gossett-ceg3120:latest
angular-site
angular-site
f37534a5a2eddd364a5bc482a331e3b3dbec6a0cc06920438eb68dda0258e21e
```

##### Link to My Bash Script

[Tylar's Bash Script](https://github.com/WSU-kduncan/ceg3120-cicd-Saucy-tgossett/blob/main/project5/deployment/redeploy_container.sh)

#### *Configuring a `webhook` Listener on EC2 Instance*

##### Installing Adnanh's `webhook` to the EC2 Instance

To install `webhook` in your EC2 instance simply use the command `sudo apt-get install webhook`

##### How to verify successful installation

Use ` webhook --version` to verify installation. You should see something like this if it worked correctly:
```
webhook version 2.8.0
```

##### `webhook` Definition File

```
[
  {
    "id": "deploy-angular",
    "execute-command": "/home/ubuntu/deployment/redeploy_container.sh",
    "command-working-directory": "/home/ubuntu",
    "trigger-rule":
    {
     "and":
     [
       {
         "match":
         {
           "type": "value",
           "value": "run",
           "parameter":
           {
             "source": "payload",
             "name": "action"
           }
         }
       },
       {
         "match":
         {
           "type": "payload-hmac-sha1",
           "secret": "supercalifragilisticexpialidocious",
           "parameter":
            {
             "source": "header",
             "name": "X-Hub-Signature"
            }
          }
        }
      ]
    }
  }
]
```
- `"id": "deploy-angular"`: Names your hook in the URL path (/hooks/deploy-angular) 
- `execute-command`: The absolute path to `redeploy_container.sh` that should be used when this hook fires.
- `command-working-directory`: The directory in which the above script will be run in.
- `trigger-rule`: A set of conditions that must be true for the hook to actually fire.
- `"and": [...]`: All conditions in this array must pass.
- `"type": "value"`: A simple equality check. 
- `parameter: { source: "payload"` and `"name": "action"`: Looks inside the JSON payload sent by GitHub under the field `"action"`.
- `"type": "payload-hmac-sha1"`: Verifies the request really came from GitHub (or whoever shares the secret). 
- `secret: "supercalifragilisticexpialidocious"`: The shared key. 
- `parameter: { source: "header", name: "X-Hub-Signature"`: Grabs the signature GitHub sent in that HTTP header, recompute the HMAC-SHA1 over the raw body with your secret, and ensure they match.

> [!NOTE]
> Made with the help of ChatGPT


##### How to verify definition file was loaded by `webhook`

> [!IMPORTANT]
> **Section incomplete, DID NOT DO**

    - [ ] How to verify `webhook` is receiving payloads that trigger it
        - [ ] how to monitor logs from running `webhook`
        - [ ] what to look for in `docker` process views

##### LINK to my definition file in my repository

[Tylar's `hooks.json`](https://github.com/WSU-kduncan/ceg3120-cicd-Saucy-tgossett/blob/main/project5/deployment/hooks.json)

#### *Configuring a Payload Sender*

> [!IMPORTANT]
> **Section incomplete, DID NOT DO**

    - [ ] Justification for selecting GitHub or DockerHub as the payload sender
    - [ ] How to enable your selection to send payloads to the EC2 `webhook` listener
    - [ ] Explain what triggers will send a payload to the EC2 `webhook` listener
    - [ ] How to verify a successful payload delivery

#### *Configure a `webhook` Service on EC2 Instance*

```
[Unit]
Description=Webhook Listener

[Service]
ExecStart=/usr/bin/webhook \
  -hooks /home/ubuntu/deployment/hooks.json \
  -port 9000
WorkingDirectory=/home/ubuntu
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
- `[Unit]`: Top-level section for metadata and dependencies. 
- `Description=Webhook Listener`: A human-readable name—shown in systemctl status and logs.
- `[Service]`: Defines how the service actually runs. 
- `ExecStart=`:
     - The command that systemd will run to start (and restart) the service. 
     - Here you launch the webhook binary, pointing it at your JSON file and telling it to listen on port 9000.
- `WorkingDirectory=/home/ubuntu`: Sets the current directory for the process. Useful if your hooks or scripts use relative paths. 
- `Restart=on-failure`: If the webhook process exits with a non-zero status (i.e. crashes or is killed by an error), systemd will automatically restart it.
- `[Install]`: Controls how the unit is enabled or disabled. 
- `WantedBy=multi-user.target`:
     - Hooks this service into the normal non-graphical boot sequence. 
     - When you run systemctl enable webhook, systemd creates a symlink so that at boot it will start your webhook listener as part of reaching “multi-user” mode.

##### How to `enable` and `start` the `webhook` service

Follow the steps below to `enable` and `start` your `webhook.service` file:

1. `sudo cp deployment/webhook.service /etc/systemd/system/webhook.service`
2. `sudo systemctl daemon-reload`
3. `sudo systemctl enable webhook`
4. `sudo systemctl start webhook`

##### How to verify `webhook` service is capturing payloads and triggering bash script

##### LINK to my service file in my repository

[Tylar's `webhook.service` file](https://github.com/WSU-kduncan/ceg3120-cicd-Saucy-tgossett/blob/main/project5/deployment/webhook.service)

## Part 3 - Project Description & Diagram

### Continuous Deployment Project Overview

#### *The Goal of this Project*

Automatically rebuild and redeploy the Angular application container on an EC2 server whenever new code is pushed to the repository
    
#### *Tools used in this Project and their Roles*

- **Docker**: Builds the Angular app into a container image and runs it on EC2.
- **GitHub Webhooks**: Sends a signed HTTP payload on each push to `main`.
- **adnanh/webhook**: Listens on EC2 for incoming webhook payloads and validates them.
- **Bash deploy script** (`redeploy_container.sh`): Pulls the latest image, stops & removes the old container, and starts the new one.
- **systemd** (`webhook.service`): Manages the webhook listener as a background service that auto-restarts and starts on boot.

#### *README.md in root of repository:*

This repository contains:

- **Continuous Integration** [`README-CI.md`](https://github.com/WSU-kduncan/ceg3120-cicd-Saucy-tgossett/blob/main/project5/README-CI.md):
  - Automated linting, building, and testing of the Angular app on each PR and push to `main`.

- **Continuous Deployment** [`README-CD.md`](https://github.com/WSU-kduncan/ceg3120-cicd-Saucy-tgossett/blob/main/project5/README-CD.md):  
  - Instructions, scripts, and service definitions to deploy the Angular app to an AWS EC2 instance via Docker, a webhook listener, and a deploy script.

See each README for full setup, usage, and troubleshooting details.

> [!WARNING]
> This README(`README-CD.md`) is **incomplete**

#### *What is **not working** in this project*

The `webhook.service` and `hooks.json`, should in theory work but in practice they do not. I believe this is not only due to formatting issues but as well the creators lack of understanding of the topic. 
 > [!NOTE]
 > Unable to view website when its run but dockerhub shows a new image was pushed.
 > Did not Demo
 
***Helpful Resources:***
- [How to Tag Old Commits](https://betterstack.com/community/questions/how-to-tag-older-commit-in-git/)
- [How to delete Tags](https://docs.aws.amazon.com/codecommit/latest/userguide/how-to-delete-tag.html#:~:text=To%20delete%20the%20Git%20tag,tag%20you%20want%20to%20delete.)
- [Different Markdown Highlighted blocks](https://github.com/orgs/community/discussions/16925)
- [Installing Docker on ubuntu within EC2](https://medium.com/@srijaanaparthy/step-by-step-guide-to-install-docker-on-ubuntu-in-aws-a39746e5a63d)
- [`-it` tag](https://stackoverflow.com/questions/48368411/what-is-docker-run-it-flag)
- [Updating a Docker Image](https://phoenixnap.com/kb/update-docker-image-container)
