@Library('jenkins-shared-libs-oop')
import org.jbris.Git
import org.jbris.Email
import org.jbris.Bats

def git = new Git(this)
def email = new Email(this)
def bats = new Bats(this)

pipeline {
   agent any

    stages {
        stage('announce-test') {
            steps {
                script {
                    sh 'echo "Jenkins Pipeline"'
                    git.getLatestCommit()
                }
            }
        }

        stage('test') {
            steps {
                script {
                    bats.test("${WORKSPACE}/tests/tests.bats", "${WORKSPACE}/test_results.tap")   
                }
            }
        }
    }
    
    post {
        always {
            script {
                if (fileExists("test_results.xml")) {
                    archiveArtifacts artifacts: "test_results.xml", fingerprint: true
                } 
                bats.publishResults("test_results.tap")           
                email.sendResults("\${DEFAULT_RECIPIENTS}")
            }
            deleteDir() 
        }
    }
}