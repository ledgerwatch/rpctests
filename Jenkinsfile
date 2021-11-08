pipeline {
    agent any

    tools {
        go 'go-1.17.2'
    }


    parameters{
        choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')
    }


    stages {

        stage('Stop Erigon and RPCdaemon') {


            steps {
                script {
                    println "----------------- Stop Erigon and RPCdaemon -----------------"
                }
                // sh "./start_stop.sh"
                echo "Choice: ${params.CHOICE}"
            }
        }

        stage('Build') {

            steps {
                script {
                    println "----------------- Build Stage -----------------"
                }
                // sh "./build.sh --branch=$BRANCH"
                echo "Choice: ${params.CHOICE}"
            }

        }

        stage('(Re)Start') { // restart erigon and rpcdaemon if they are running

            steps{
                script {
                    println "----------------- (Re)Start Stage -----------------"
                }
                echo "Choice: ${params.CHOICE}"
                // sh "sudo ./restart.sh --url=${env.JENKINS_URL}" 
            }
        }

    }

}
