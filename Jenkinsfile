// =============================================================================
// Job: hello
// Author: mikejianzhang
// =============================================================================

pipeline {
    agent {
        label 'slave-k8s'
    }
    environment {
        MAJOR_VERSION = "8"
        MINOR_VERSION = "0"
        DOCKER_REGISTRY_INTERNAL_NAME = "docker-registry:5000"
        DOCKER_REGISTRY_INGRESS_NAME = "docker-registry.local"
    }
    options {
        ansiColor('xterm')
    }
    stages {
        stage('Build docker image') { 
            steps { 
                sh '''#!/bin/bash -il
                    set -ex
                    echo "Build docker images"
                    ./build.sh ${DOCKER_REGISTRY_INTERNAL_NAME}/hello:${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER}

                    if [ $? -ne 0 ]
                    then
                        echo "Failed to build docker image!"
                        exit 1
                    fi
                '''
            }
        }
        stage('Build chart package') { 
            steps { 
                sh '''#!/bin/bash -il
                    set -ex
                    echo "Build chart package"
                    helm package hello/ --version ${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER}

                    if [ $? -ne 0 ]
                    then
                        echo "Failed to build chart package!"
                        exit 1
                    fi
                '''
            }
        }
        stage('Push docker image') { 
            steps { 
                sh '''#!/bin/bash -il
                    set -ex
                    echo "Publish docker image"
                    docker push ${DOCKER_REGISTRY_INTERNAL_NAME}/hello:${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER}

                    if [ $? -ne 0 ]
                    then
                        echo "Failed to pubsh docker image!"
                        exit 1
                    fi
                '''
            }
        }
        stage('Deploy application') {
            steps {
                sh '''#!/bin/bash -il
                    set -ex
                    echo "Deploy application"
                    helm upgrade hello hello-${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER}.tgz -i --create-namespace --namespace default \
                        --set-string image.repository=${DOCKER_REGISTRY_INGRESS_NAME}/hello,image.tag=${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER} \

                    if [ $? -ne 0 ]
                    then
                        echo "Failed to deploy application!"
                        exit 1
                    fi
                '''
            }
        }
        stage('Set build description') { 
            steps { 
                    script{
                        def currentDesc = "hello:${MAJOR_VERSION}.${MINOR_VERSION}.${BUILD_NUMBER}<br>"
                        currentBuild.description = currentDesc
                    }
            }
        }
    }
    post{
        always{
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
        }
        success{
            notifySuccessful()
        }
        unstable{
            notifyUnstable()
        }
        failure{
            notifyFailed()
        }
    }
}

def notifySuccessful() {
  emailext (
      subject: "SUCCESSFUL: Job '${BUILD_DISPLAY_NAME}'",
      body: """<p>SUCCESSFUL: Job '${BUILD_DISPLAY_NAME}':</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${BUILD_DISPLAY_NAME}</a>"</p>""",
      recipientProviders: [culprits()]
    )
}

def notifyUnstable() {
  emailext (
      subject: "UNSTABLE: Job '${BUILD_DISPLAY_NAME}'",
      body: """<p>UNSTABLE: Job '${BUILD_DISPLAY_NAME}':</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${BUILD_DISPLAY_NAME}</a>"</p>""",
      recipientProviders: [culprits()]
    )
}

def notifyFailed() {
  emailext (
      subject: "FAILED: Job '${BUILD_DISPLAY_NAME}'",
      body: """<p>FAILED: Job '${BUILD_DISPLAY_NAME}':</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${BUILD_DISPLAY_NAME}</a>"</p>""",
      recipientProviders: [culprits()]
    )
}