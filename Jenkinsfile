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


                // sh "./build.sh --branch=$BRANCH"
                echo "Build"
            }

        }

        stage('(Re)Start') { // restart erigon and rpcdaemon if they are running

            steps{
                script {
                    println "----------------- (Re)Start Stage -----------------"
                }

                // sh "sudo ./restart.sh --buildid=${env.BUILD_ID}" 
                echo "(Re)Start"
            }
        }

        stage('Test') {



            steps{
                script {
                    println "----------------- Test Stage -----------------"
                }

                // script {
                //     // def date = new Date()
                //     // println date.format("yyMMdd_HHmmSS", TimeZone.getTimeZone('UTC'))

                //     // TODO
                //     // Do we need to record test timestamp?
                // }
                // sh "sudo ./run_tests.sh --buildid=${env.BUILD_ID}"
                echo "Test"
            }
        }

        // // - Not implemented - 
        // stage('Deploy') { // aka Release
        //     steps{
        //         sh "./deploy.sh --buildid=${env.BUILD_ID}"
        //     }
        // }
    }

}
