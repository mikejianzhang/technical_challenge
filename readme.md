

# Technical Devops Challenge

This repo contains a small "Hello World" webserver which simulates a small microservice

## Tasks


 - Create a docker image for the microservice. The smaller the image, the better.  
    + Docker's reserved minimal image "scratch" is choosen to create the final image  
    + A two-stage builds are used to make sure only the required files are included into the final image
    + For go project, disable the c compiler too, only build binary for linux(amd64), and remove any temp symbols

 - From security perspective, make sure that the generated docker image has a small attack surface  
    + Use "scratch" as the base image which nearly has nothing in it reduce the attack points
    + Create a non-priviledged user without login shell and home directory to run the process instead of root user
    + During build stage, reference base image by sha256 digest to make sure the base image was not hacked
    + Expose port greater than 1024, so that it doesn't need root priviledge to open
  
 - Create all required resources in Kubernetes to expose the microservice to the public. Make sure that the microservice has access to a volume mounted in /tmp for storing temp data.
 - Use MESSAGES env variable to configure the message displayed by the server
 - Make sure that the health of the microservice is monitored from Kubernetes perspective
 - Security wise, try to follow the best practices securing all the resources in Kubernetes when possible
 - Create a K8S resource for scale up and down the microservice based on the CPU load
 - Create a Jenkins pipeline for deploying the microservice.
 - Describe how to retrieve metrics from the microservice like CPU usage, memory usage...
 - Describe how to retrieve the logs from the microservice and how to store in a central location
