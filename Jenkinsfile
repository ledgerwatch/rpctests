pipeline {
    agent any

    tools {
        go 'go-1.17.2'
    }

    parameters{
        choice(name: 'OPTION', choices: [
            'stop only', 
            'restart no pull',
            'restart with pull',
            'restart with new branch'], 
            description: 'What can I do for you?')
    }

    stages {

        stage('Stop Erigon and RPCdaemon') {

            when {
                expression {
                    "${params.OPTION}" == 'stop only' 
                }
            }

            steps {
                script {
                    println "----------------- ${params.OPTION} -----------------"
                }
                sh "sudo ./stop.sh"
            }
        }

        stage('Restart with new branch') {

            when {
                expression {
                    "${params.OPTION}" == 'restart with new branch'
                }
            }

            input {
                message "Please enter an Erigon branch you wish to test:"
                parameters{
                    string(name: 'BRANCH', defaultValue: 'stable', description: 'Erigon branch name')
                }
            }

            steps {
                script {
                    println "----------------- ${params.OPTION} -----------------"
                }
                sh "./build.sh --branch=$BRANCH"
                sh "sudo ./restart.sh --url=${env.JENKINS_URL}" 
            }

        }

        stage('(Re)Start') { // restart erigon and rpcdaemon if they are running

            when {
                expression {
                    "${params.OPTION}" == "restart no pull" || 
                        "${params.OPTION}" == "restart with pull"
                }
            }

            steps{
                script {
                    println "----------------- ${params.OPTION}  -----------------"

                    if ("${params.OPTION}" == "restart no pull") {
                        env.PULL = 0
                    } else {
                        env.PULL = 1
                    }

                }

                echo "Choice: ${params.OPTION}, PULL: ${env.PULL}"
                // sh "sudo ./restart.sh --url=${env.JENKINS_URL} --pull=${env.PULL}"
                sh "./build.sh --branch=nobranch --pull=${env.PULL}"
                sh "sudo ./restart.sh --url=${env.JENKINS_URL}" 
            }
        }

    }

}
