pipeline {
    agent {
        docker {
            image 'maven:3.6.2-jdk-13'
        }
    }

    environment {
        EMAIL_RECIPIANTS = 'ljolliff@cynerge.com'
        NEXUS_USER = credentials('nexus-user')
        NEXUS_PASS = credentials('nexus-pass')
        STATUS_SUCCESS = ''
        JENKINS_URL = "${JENKINS_URL}"
        JOB_NAME = "${JOB_NAME}"
        SONAR_TOKEN = credentials('shipyard-sonarqube')
        SONAR_PROJECT = 'shipyard-project-java'
        SONAR_SOURCE = "java_webapp/src,java_webapp_polyglot/src"
        SONAR_REPORTS = 'target/surefire-reports'
        JACOCO_REPORT = "$WORKSPACE/tests/target/site/jacoco-aggregate/jacoco.xml"
        JAVA_BINARIES = "java_webapp/target,java_webapp_polyglot/target"
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Unit Testing') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit "java_webapp*/target/surefire-reports/*.xml"
                }
            }
        }
        // stage('Sonarqube Analysis') {
        //     environment {
        //         scannerHome = tool 'cynerge-sonarqube'
        //     }
        //     steps {
        //         withSonarQubeEnv('Cynerge Sonarqube') {
        //             sh "mvn -Dsonar.login=$SONAR_TOKEN -Dsonar.projectKey=$SONAR_PROJECT -Dsonar.junit.reportPaths=$SONAR_REPORTS -Dsonar.coverage.jacoco.xmlReportPaths=$JACOCO_REPORT clean verify sonar:sonar"
        //         }
        //     }
        // }
        stage('Store Maven Artifact') {
            environment { 
                MAVEN_USER = credentials('nexus-user')
                MAVEN_PASS = credentials('nexus-pass')
                NPM_REGISTRY = credentials('nexus-repo')
            }
            steps {
                sh 'env'
                sh "curl -v -u $MAVEN_USER:$MAVEN_PASS --upload-file java_webapp/target/java-webapp*.jar http://nexus-internal.testcompany.shipyard.cloud:80/repository/maven-releases/com/$JOB_NAME/myArtifact/1.0.0-RC1/myArtifact-1.0.0-RC1.jar"
            }
        }
    }
}