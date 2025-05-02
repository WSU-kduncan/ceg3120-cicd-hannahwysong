# Project CI / CD
## Project Contents
### Angular Application
The application files are located in the angular-site directory.\
This also includes the Dockerfile used to build the image.\
The application builds a webpage that is hosted on http://localhost:4200/
### GitHub WorkFlows
The workflow folder contains two actions: CI and CD

The CI workflow logs into DockerHub in order to create a new image.\
The image is named after the tag it was pushed with, along with a latest image.

The CD workflow does the same, but also sends a payload to webhooks.\
The payload contains the secret, and a refrence to main.
### Deployment
The deployment folder has a copy of the container script.\
The script reloads the container with a build of the newest image on DockerHub.

The deployment folder also has a copy of the webhook configuration file.\
The hooks file will run the script when triggered.\
The hook will trigger successfully whenever it recieves information from a repo with the secret.

The deployment folder also has a copy of the webhooks service file.\
This starts webhooks as a service when the instance is started.
### [CI](https://github.com/WSU-kduncan/ceg3120-cicd-hannahwysong/blob/main/README-CI.md) README
Contains the process of creating the Dockerfile to create the image.\
As well as configuring the GitHub action to create a new image based on changes.
### [CD](https://github.com/WSU-kduncan/ceg3120-cicd-hannahwysong/blob/main/README-CD.md) README
Contains the process of configuring webhooks to restart a container when triggered.\
The webhook is triggered by the GitHub action, which happens when changes are made.