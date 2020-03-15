

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
    + A helm chart in folder hello has been created to deploy the microservice
    + Since it is debugged in docker desktop for Mac, the default storage class "hostpaht" is used to create the PVC which is used to mount to /tmp folder in the pod

 - Use MESSAGES env variable to configure the message displayed by the server
    + In the deployment.yaml, environment variable MESSAGE(From the code, the environment variable name is MESSAGE instead of MESSAGES) has been set, and value has been extracted as parameter which can be configured in values.yaml according to differnt environemnt
  
 - Make sure that the health of the microservice is monitored from Kubernetes perspective
    + livenessProbe and readinessProbe have been set in deployment.yaml, so that kubernetes controller can monitor the pod in case need to kill and recreate the pod, or add/remove the pod from service
   
 - Security wise, try to follow the best practices securing all the resources in Kubernetes when possible
    + By default, the pod of the microservice bind to a default service account (default) which has no permission to list Kubernetes resources, so it is safe enough
    + If the process in pod needs to access kubernetes api server, in the helm chart, we can create roles or cluster roles with exact namespaced or non-namespaced resource permisions, create a service account for the pod, and bind the roles to this service account, then add this service account to the pod spec in deployment.yaml
  
 - Create a K8S resource for scale up and down the microservice based on the CPU load
    + hpa.yaml has been added in the helm to scale up and down the pod based on CPU load from the resource metrics API implemented by metrics-server.
    + Please be note that current HPA uses autoscaling/v1 api which only support scale on single resource metric: CPU utilization, because the latest kubernetes on my docker desktop for Mac is 1.14. To support multiple resource metrics, or use cutom metrics or external metrics, the kubernetes version must be 1.16 or later, besides some monitor system with metrics api adaper also needs to be configured
  
 - Create a Jenkins pipeline for deploying the microservice.
    + Jenkinsfile is added in the root path of repository
    + Follow the readme of https://github.com/mikejianzhang/cicd-environment, you can setup the test CI/CD environment to build and deploy the microservice in local kubernetes (docker desktop for Mac)
  
 - Describe how to retrieve metrics from the microservice like CPU usage, memory usage...
    + The resource metrics api (core metrics api) implemented by metrics-server (which also collect the information from advisor in kubelet) already provide the CPU and memory statistics for node and pod, so use "kubectl top node", "kubect top pod", you can get the CPU and memory usage of the pod of microservice
    + In order to get the application related metrics, the microservice must provide the api endpoint xxxx/metrics, so that it can be captured by Prometheus and searched and displayed in Grafana
    + There are also custome resoruce metrics api and external resource metrics, so that you can install other vendors implmentaion of these apis to gather more metrics.
  
 - Describe how to retrieve the logs from the microservice and how to store in a central location
    + TBD
