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

## Part 2 - Continuous Deployment 

### EC2 Instance Details

The instance uses ubuntu-noble-2404-amd64-server-20250305.\
The instance is a t2.medium.\
The instance has 30 gib storage.

The security group has inbound rules allowing:
- Inbound Rules for Home IP: 174.103.128.135/32
- Inbound Rules for Office IP: 74.129.16.101/32
- Inbound Rules for WSU IP: 130.108.0.0/16
- Inbound Rules for Http(80) connection: 0.0.0.0/0
- Inbound Rules for Port(4200) connection: 0.0.0.0/0

The inbound security ground rules are configured to be able to run the application.\
The first three rules are so I can personally connect to the instance.\
The Http connection is so that it can take requests on port 80.\
The custom port connection is so the application can take requests on the specified port.


### Docker Setup on OS on the EC2 instance

Docker was installed to the instance by running the command,\
`sudo apt-get install docker.io -y`\
After running apt-get update to update all dependencies required.\
The Docker service also had to be started with the command,\
`sudo systemctl start docker`\

The instance needed the application files, so I used tar -czvf the files.\
As well as sftp to put them onto the instance.\
NPM also had to be installed to the instance.\
Which was done with `sudo apt-get install nodejs` and `sudo npm install`.

Docker installation can be confirmed by running `docker --version`.\
Docker can be tested by pulling an image such as docker/getting-started and checking for a response.

### Testing on EC2 Instance

The image for this project can be pulled with the command:\
`docker pull hannahwysong/wysong-ceg3120:latest`\
An image can be ran with the command:\
`docker run -t -p 4200:4200 hannahwysong/wysong-ceg3120:latest`\
The -d flag can be applied to run the container in the background after testing.\
The application can be tested by using the instances public IP in place of local host in the browser.\
This can be validated from the container by curling http://localhost:4200/\
This can be validated from the host side by replacing local host with the container IP.\
For example, mine is `curl http://44.208.197.208:4200/`\
The application can be validated by searching for `http://[Instance IP]:4200` in a browser.\
The container application can be refreshed by killing the old container\
After which, the container and image are removed from the system.\
Then a new image can be pulled from DockerHub.

### Scripting Container Application Refresh

```
#!/bin/bash
# stop container 
docker stop angularapp
# remove container
docker remove angularapp
# pull fresh image
docker pull hannahwysong/wysong-ceg3120:latest
# run new container by name, with restart automatic
docker run -d -p 4200:4200 --name angularapp --restart always hannahwysong/wysong-ceg3120:latest%
```
The script can be tested by running the script.\
For example, mine was `bash container.sh`, and resulted in a new container.\
LINK to bash script in [repository](https://github.com/WSU-kduncan/ceg3120-cicd-hannahwysong/blob/main/deployment/container.sh)

### Configuring a webhook Listener on EC2 Instance

WebHooks was installed to the container with the command `sudo apt-get install webhook`\
The installation can be verified with `webhook -version`\
The hooks.json file is set up to run the script whenever a push is triggered.\
The push is made to the ceg3120-cicd-hannahwysong repository.\
The repository must contain the secret specified. Which is located on github.\
The hooks file can be verified by starting webhooks, which is done with the command,\
`/usr/bin/webhook -hooks /home/ubuntu/ceg3120-cicd-hannahwysong/deployment/hooks.json -verbose -port 4200`\
Which starts webhooks with the config file on port 4200.\
Webhooks can be tested by pushing a commit to the repository.\
Webhooks should indicate that it is serving hooks when the push is made.\
Webhook logs should be printed to the terminal if ran with the -verbose flag\
LINK to definition file in [repository](https://github.com/WSU-kduncan/ceg3120-cicd-hannahwysong/blob/main/deployment/hooks.json)

### Configuring a Payload Sender

I chose github as the payload sender since it was able to be triggered by more actions.\
Such as a workflow run, which would happen after an update to the application.\
Github webhooks are set up in the settings of a repository.\
My repository is set to send a payload whenever a push is made to it.\
This can be verfifed by watching a webhooks listener after a push.

### Configure a webhook Service on EC2 Instance

Summary of webhook service file contents\
The webhook service is first restarted after any changes using `sudo systemctl daemon-reload` \
Then it is restarted with the command `sudo systemctl start webhook`\
How to verify webhook service is capturing payloads and triggering bash script\
LINK to service file in repository

### References
- [Docker MetaData Action](https://github.com/docker/metadata-action)
- [Installing Docker on EC2](https://medium.com/@srijaanaparthy/step-by-step-guide-to-install-docker-on-ubuntu-in-aws-a39746e5a63d)
- [EC2 Security Rules for App](https://www.reddit.com/r/docker/comments/ypr9sl/cant_connect_to_ec2_container_but_can_my_my/)
- [Systemd Webhook Config file](https://medium.com/the-sysadmin/deploy-from-github-gitlab-to-server-using-webhook-d1cb6496368f)
- [Offical Systemd documentation](https://github.com/adnanh/webhook/blob/master/docs/Systemd-Activation.md)
- [Viewing service logs](https://github.com/adnanh/webhook/discussions/569)

