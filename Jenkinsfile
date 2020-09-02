// Maven Shipyard Template v1.2.0
// ------------------------------------------------------------------------------------------------------------------------------

// Embeddable badge configuration. Under normal circumstances there is no need to change these values
def shipyardBuildBadge = addEmbeddableBadgeConfiguration(id: "shipyard-build", subject: "Shipyard Build")

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
        SONAR_REPORTS = 'target/surefire-reports'
        JACOCO_REPORT = "$WORKSPACE/tests/target/site/jacoco-aggregate/jacoco.xml"
        PA11Y_SOURCE = './**/src/**/**/**.html'
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
        stage('Pa11y') {
            agent {
                docker {
                    image 'cynergeconsulting/browser-node-12'
                    alwaysPull true
                    args '-u root'
                }
            }

            steps {
                sh 'rm -rf test-results || echo "directory does not exist"'
                sh 'mkdir test-results'
                sh 'chmod -R 777 test-results/'
                sh "pa11y-ci -T 5 ${env.PA11Y_SOURCE} --json > test-results/pa11y-ci-results.json"
                dir('test-results') {
                    sh 'pa11y-ci-reporter-html'
                }
            }
            post {
                success {
                    // Do NOT delete the empty line underneath below curl command. It is necessary for script logic
                    dir('test-results') {
                        sh "curl -v --user '${NEXUS_USER}:${NEXUS_PASS}' --upload-file \"{\$(echo *.html | tr ' ' ',')}\" https://nexus-internal.testcompany.shipyard.cloud/repository/raw/Pa11y/${JOB_NAME}/${BRANCH_NAME}/${BUILD_NUMBER}/"

                    }
                }
            }
        }

        stage('Sonarqube Analysis') {
            environment {
                scannerHome = tool 'cynerge-sonarqube'
            }
            steps {
                withSonarQubeEnv('Cynerge Sonarqube') {
                    sh "mvn -Dsonar.login=$SONAR_TOKEN -Dsonar.projectKey=$SONAR_PROJECT -Dsonar.junit.reportPaths=$SONAR_REPORTS -Dsonar.coverage.jacoco.xmlReportPaths=$JACOCO_REPORT clean verify sonar:sonar"
                }
            }
        }
        stage('Store Maven Artifact') {
            environment { 
                MAVEN_USER = credentials('nexus-user')
                MAVEN_PASS = credentials('nexus-pass')
                MAVEN_REPO = credentials('nexus-maven-repo')

            }
            steps {
                sh 'env'
                sh "curl -v -u $MAVEN_USER:$MAVEN_PASS --upload-file java_webapp/target/java-webapp*.jar $MAVEN_REPO"
            }
        }
    }
    post {
// Send an email containing build status and other helpful info to appropriate recipiants

        success {
            script {
                env.STATUS_SUCCESS = 'Job Complete!'
                env.JENKINS_URL = "${JENKINS_URL}"
                env.JOB_NAME = "${JOB_NAME}"
                env.BUILD_STATUS = 'Success'
            sh 'printenv'
            emailext body: '''${SCRIPT, template="email_report.template"}''',
            mimeType: 'text/html',
            subject: 'Build # $BUILD_NUMBER - $BUILD_STATUS!',
            to: "${EMAIL_RECIPIANTS}"

            }
        }
        failure {
            script {
                env.STATUS_SUCCESS = 'Job Complete!'
                env.JENKINS_URL = "${JENKINS_URL}"
                env.JOB_NAME = "${JOB_NAME}"
                env.BUILD_STATUS = 'Failure'
            sh 'printenv'

            emailext body: '''${SCRIPT, template="email_report.template"}''',
            mimeType: 'text/html',
            subject: 'Build # $BUILD_NUMBER - $BUILD_STATUS!',
            to: "${EMAIL_RECIPIANTS}"

            }
        }
    
        cleanup {
// Clean up workspace after build
            cleanWs()
// Update build badge with passing or failing status
            script {
                shipyardBuildBadge.setStatus('running')
                try {
                    shipyardBuildBadge.setStatus('passing')
                } 
                catch (Exception err) {
                    shipyardBuildBadge.setStatus('failing')
                    shipyardBuildBadge.setColor('red')
                    error 'Build failed'
                }
            }
        }
    }
}
