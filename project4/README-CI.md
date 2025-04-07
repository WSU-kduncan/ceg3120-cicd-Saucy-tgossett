# Project 4

## Repo contents ( / 4)

- `README-CI.md`
    - if your documentation does not use good organization with markdown, it may receive 0 credit.
- `angular-site` folder with Angular application
- `Dockerfile`
- GitHub action `yml` file in `.github/workflows`

## Part 1 - Docker-ize it

### CI Project Overview

#### What are we doing?

 We are containerizing an Angular web application using Docker for ease of deployment and scalability.

#### Why are we doing it?

 - Ensures consistent application behavior across environments.

 - Simplifies deployment and testing.

 - Enables efficient versioning and distribution via DockerHub.

#### Tools Used:

 - Docker: Containerization platform.

 - DockerHub: Cloud-based container image repository.

 - Angular: Frontend framework.

 - Node.js & npm: Required for building the Angular application.

 - EC2 (optional): Hosting environment.

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



  - how to build & configure a container (without building an image) that runs the `angular-site` application
  - summary of instructions stated in the repository `Dockerfile`
  - how to build an image from the repository `Dockerfile`
  - how to run a container from the image built by the repository `Dockerfile`
  - how to view the application running in the container 
    - (open a browser...go to IP and port...)
- Working with DockerHub:
  - how to create public repo in DockerHub
  - how to authenticate with DockerHub via CLI using DockerHub credentials
  - how to push container image to DockerHub
  - **Link** to your DockerHub repository for this project

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

Resources:
- [Unzipping in Terminal](https://www.reddit.com/r/techsupport/comments/rgo3mo/how_do_i_extract_zip_files_on_linux/)
- [Installing Node with homebrew](https://nodejs.org/en/download/package-manager/all)
- [Finding IP on Mac](https://www.whatismybrowser.com/detect/what-is-my-local-ip-address/#macos)
- [IP Command for Mac](https://discussions.apple.com/thread/7145789?sortBy=rank)
- [Docker not working on Mac(adding path)](https://stackoverflow.com/questions/64009138/docker-command-not-found-when-running-on-mac)
- [Docker not working on Mac(redownloading with brew)](https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos)
- [AI Overview on sharing files between Mac host and Docker containers](https://www.google.com/search?q=file+sharing+with+docker+on+mac&rlz=1C5CHFA_enUS1062US1062&oq=file+sharing+with+docker+on+mac&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQIRiPAjIHCAIQIRiPAtIBCDkwMzlqMGo3qAIAsAIA&sourceid=chrome&ie=UTF-8)
