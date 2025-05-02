# Project CI / CD
## Project Contents
### Angular Application
The application files are located in the angular-site directory.\
This also includes the Dockerfile used to build the image.
The application builds a webpage that is hosted on http://localhost:4200/
### GitHub WorkFlows
The workflow folder contains two actions: CI and CD\

### Deployment
The deployment folder has a copy of the container script.\
The script reloads the container with a build of the newest image on DockerHub.

The deployment folder also has a copy of the webhook configuration file.\

### [CI](https://github.com/WSU-kduncan/ceg3120-cicd-hannahwysong/blob/main/README-CI.md) README
### [CD](https://github.com/WSU-kduncan/ceg3120-cicd-hannahwysong/blob/main/README-CD.md) README