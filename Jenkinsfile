pipeline {
    agent any

    tools {
        go 'go-1.17.2'
    }

    stages {
        stage('Build') {

            input {
                message "Please enter an Erigon branch you wish to test:"
                parameters{
                    string(name: 'BRANCH', defaultValue: 'devel', description: 'Erigon branch name')
                }
            }

            steps {
                script {
                    println "----------------- Build Stage -----------------"
                }

                echo "JENKINS_URL=${env.JENKINS_URL}"

                // sh "./build.sh --branch=$BRANCH"
            }

        }

        stage('(Re)Start') { // restart erigon and rpcdaemon if they are running

            steps{
                script {
                    println "----------------- (Re)Start Stage -----------------"
                }

                sh "sudo ./restart.sh --buildid=${env.BUILD_ID} --url=${env.JENKINS_URL}" 
            }
        }

        stage('Test') {



            steps{
                script {
                    println "----------------- Test Stage -----------------"
                }
                echo "JENKINS_URL=${env.JENKINS_URL}"
                // sh "sudo ./run_tests.sh --buildid=${env.BUILD_ID}"
            }
        }

        // // - Not implemented - 
        // stage('Deploy') { // aka Release
        //     steps{
        //         sh "./deploy.sh --buildid=${env.BUILD_ID}"
        //     }
        // }


        stage('CleanUp') {
            steps {
                script {
                    println "----------------- CleanUp Stage -----------------"
                }
                sh "sudo ./clean_up.sh --buildid=${env.BUILD_ID}"
            }
        }
    }

}
