// Maven Shipyard Template v1.2.0
// ------------------------------------------------------------------------------------------------------------------------------

pipeline {
// Use Maven container to run pipeline stages
    agent {
        docker {
            image 'maven:3.6.2-jdk-13'
        }
    }
// Location for setting global environment variables
    environment {
        JENKINS_URL = "${JENKINS_URL}"
        JOB_NAME = "${JOB_NAME}"
        AWS_ACCESS_KEY_ID = credentials('aws_id')
        AWS_SECRET_ACCESS_KEY = credentials('aws_secret')
        TF_VAR_environment = 'prod'
        TF_VAR_app = 'my-maven-app'
        TF_VAR_nodetype = 'Corretto 11 running on 64bit Amazon Linux 2'
    }

    stages {
// Clear any previously compiled files, then compile and package artifact
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Terraform') {
            agent {
                docker {
                    image 'cynergeconsulting/browser-node-12'
                    alwaysPull true
                    args '-u root'
                }
            }
            steps {
                dir('terraform') {
                    sh 'ls'
                    sh 'terraform init'
                    sh 'terraform apply --var-file prod.tfvars -auto-approve'
                }
            }
        }
        stage('Deploy') {
            agent {
                docker {
                    image 'cynergeconsulting/browser-node-12'
                    alwaysPull true
                    args '-u root'
                }
            }
            steps {
                sh "eb deploy $TF_VAR_environment"
            }
        }   
    }
    post {
        cleanup {
// Clean up workspace after build
            cleanWs()
        }
    }
}
