# Project 5 CD 
## Part 1 - Semantic Versioning
### Generating tags
Tags for a git repository can be viewed by typing `git tag` into the CLI.

A new tag for a commit can be generated with the command.\
`git tag -a [tag name]`\
This command must be ran after a commit is created.\

A tag is pushed to Github with the command `git push --tags`
### Semantic Versioning Container Images with GitHub Actions
The workflow is set up to push two images to Docker, a latest version, and a tagged one.
```
name: cd

on:
  workflow_dispatch:
  push:
    tags:
      - 'v*'
  pull_request:
    branches:
      - 'master'

jobs:
  docker:
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
          images: hannahwysong/wysong-ceg3120
      -
        name: Login to DockerHub
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}
      -
        name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: ./angular-site/angular-bird/wsu-hw-ng-main
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```
This workflow is triggered when a push is made with a tag in the format v*\
Or when a pull request is made to the main branch.\
The job is created using the latest version of ubuntu.\
The Checkout action copies the latest version of the repo to the workflow.\
The Docker Meta action creates Docker image tags and stores them in ${{ steps.meta.outputs.tags }}.\
The tags are taken from the DockerHub repository "hannahwysong/wysong-ceg3120".\
The Docker login action logs into DockerHub using GitHub secrets.\
This action is not performed on pull requests.\
The build and push action pushes the image using the tags created. 

If used in a different repository, the context for the build files must be changed.\
The Docker image can also be changed if using a different docker repository.

Link to [workflow file](https://github.com/WSU-kduncan/ceg3120-cicd-hannahwysong/blob/main/.github/workflows/ci.yml) in your GitHub repository
### Testing & Validating
The workflow can first be validated by looking at GitHub.\
If the workflow ran, the image can be checked by looking at DockerHub\
Dockerhub should say when the most recent push was made to an image.

The image can be checked by pulling it from DockerHub, which can be done with the command\
`docker pull hannahwysong/wysong-ceg3120:[tag name]`\
The pulled image can be ran and checked for any changes. 

### Part 2 - Continuous Deployment 

### EC2 Instance Details

AMI information\
Instance type\
Recommended volume size\
Security Group configuration\
Security Group configuration justification / explanation

###Docker Setup on OS on the EC2 instance

How to install Docker for OS on the EC2 instance\
Additional dependencies based on OS on the EC2 instance\
How to confirm Docker is installed and that OS on the EC2 instance can successfully run containers

### Testing on EC2 Instance

How to pull container image from DockerHub repository\
How to run container from image\
Note the differences between using the -it flag and the -d flags and which you would recommend once the testing phase is complete\
How to verify that the container is successfully serving the Angular application\
validate from container side\
validate from host side\
validate from an external connection (your physical system)\
Steps to manually refresh the container application if a new image is available on DockerHub\

### Scripting Container Application Refresh

Create a bash script on your instance that will:\
pull the image from your DockerHub repository\
kill and remove the previously running container\
start a new container with the freshly pulled image\
How to test that the script successfully performs its taskings\
LINK to bash script in repository

### Configuring a webhook Listener on EC2 Instance

How to install adnanh's webhook to the EC2 instance\
How to verify successful installation\
Summary of the webhook definition file\
How to verify definition file was loaded by webhook\
How to verify webhook is receiving payloads that trigger it\
how to monitor logs from running webhook\
what to look for in docker process views\
LINK to definition file in repository

### Configuring a Payload Sender

Justification for selecting GitHub or DockerHub as the payload sender\
How to enable your selection to send payloads to the EC2 webhook listener\
Explain what triggers will send a payload to the EC2 webhook listener\
How to verify a successful payload delivery

### Configure a webhook Service on EC2 Instance

Summary of webhook service file contents\
How to enable and start the webhook service\
How to verify webhook service is capturing payloads and triggering bash script\
LINK to service file in repository

### References
- [Docker MetaData Action](https://github.com/docker/metadata-action)
