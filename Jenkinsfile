@Library('jenkins-shared-libs-oop')
import org.jbris.EnvVars
import org.jbris.Git
import org.jbris.Hook
import org.jbris.Email
import org.jbris.File
import org.jbris.Template
import org.jbris.Bats

def envVars = new EnvVars(this)
def git = new Git(this)
def hook = new Hook(this)
def email = new Email(this)
def file = new File(this)
def template = new Template(this)
def bats = new Bats(this)

pipeline {
   agent any

    stages {
        stage('announce-test') {
            steps {
                script {
                    sh 'echo "Jenkins Pipeline"'
                    def commitHash = git.getLatestCommit() 
                    sh "Testing for ${commitHash}"
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

    post {
        always {
            script {
                if (fileExists("${WORKSPACE}/test_results.xml")) {
                    archiveArtifacts artifacts: "${WORKSPACE}/test_results.xml", fingerprint: true
                } 
                bats.publishResults("${WORKSPACE}/test_results.tap")           
                email.sendResults("${DEFAULT_RECIPIENTS}")
            }
            deleteDir() 
        }
    }
}