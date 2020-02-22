# pfr-jenkins-prototype

## Table of Contents  
* [Introduction](#introduction)<a name="introduction"/>
* [Workflow](#workflow)<a name="workflow"/>
* [Freestyle Jobs](#freestyle-jobs)<a name="freestyle-jobs"/>
* [Hooks vs Polling](#hooks-vs-polling)<a name="hooks-vs-polling"/>
* [Generating Jobs](#generating-jobs)<a name="generating-jobs"/>

### Introduction

This is a basic, small scale prototype of a possible Jenkins server implementation for the PFR summer project.

The Jenkins server will monitor the following test repo for changes: https://github.com/JBris/a-jenkins-test-repo

After detecting a change, any relevant information will be passed to the following repo: https://github.com/JBris/another-jenkins-repo

The latter repo will simulate the system's file mutator component. The Jenkins server will handle the repo monitoring and middleware/abstraction layer for the system. It will also handle the testing and reporting components. So Jenkins will do the heavy lifting.

### Workflow

Every repo/project of interest will have their own tailored freestyle job. Each freestyle job will monitor their respective repo and, assuming the correct conditions are met, will trigger a downstream pipeline job. This downstream pipeline job will handle the file mutation logic and anything else that needs to occur.  

### Freestyle Jobs

Outside of upstream--downstream freestyle jobs, I haven't found a simple way to monitor a repo outside of PFR's ownership, such as the checkm repo (which also has no Jenkinsfile), while updating another repo within PFR's ownership, such as the checkm-srf repo. This would probably require a custom plugin. This is one alternative: https://support.cloudbees.com/hc/en-us/articles/205028534-How-do-I-configure-SCM-Polling-in-a-Pipeline-Template-

The advantage of freestyle jobs is flexibility. As the name would suggest, they are modular, freeform "freestyle" jobs that can easily be configured by job creators. This can be useful when dealing with edge cases, such as self-hosted projects that don't employ version control.

The downside is that, unlike Pipelines, jobs aren't treated as code. Rather than using a single Jenkinsfile file, a blob of XML files must be maintained. This reduces reproducibility and portability.    

### Hooks vs Polling

Generally speaking, it is preferable to use hooks over polling as the former tends to be more performant and resource efficient.  

However, traditional Github/Bitbucket webhooks can't be used as PFR doesn't have admin/write access to many of the repos of interest. One option would be to manually subscribe to repos of interest, monitor GihHub notifications, and trigger builds on new releases or commits; see https://jenkins.io/doc/pipeline/steps/pipeline-githubnotify-step/. This would probably require some extra work.

The SCM polling plugin is adequate for Git-based projects. The URLTrigger plugin (https://wiki.jenkins.io/display/JENKINS/URLTrigger+Plugin) can be used to monitor self-hosted projects - note that the results of the URL check are stored in memory, and not written to file, so a new build might be triggered whenever memory is flushed. A naive implementation would be to monitor the latest releases of a project using GitHub API: https://api.github.com/repos/jbris/a-jenkins-test-repo/releases/latest and https://api.github.com/repos/jbris/a-jenkins-test-repo/tags

### Generating Jobs

As there are presumably hundreds of pieces of software to be monitored, it would be pretty tedious to create these jobs manually. The Job DSL plugin (https://wiki.jenkins.io/display/JENKINS/Job+DSL+Plugin) can be use do simplify the process. To accomplish this:

* Create a freestyle job which will act as the job seed
* Add a buildstep to 'Process Job DSLs'
* Call the job seed using Jenkin's API (https://wiki.jenkins.io/display/JENKINS/Remote+access+API), passing the parameters needed to generate the job as form arguments

```
job("${PROJECT_NAME}") {

    scm {
        git("${PROJECT_REPO_URL}")
    }
    triggers {
        scm('H/15 * * * *')
    }
    steps {
        maven('-e clean test')
    }
} 

```

To call the job using a POST request: 

`http://JENKINS/job/JOB/buildWithParameters?token=TOKEN&PROJECT_NAME=foo&VERSION=1.2.3`

or

`http://JENKINS/job/JOB/build?token=TOKEN`

In the form body

`json: {"parameter": [{"name":"PROJECT_NAME", "value":"foo"}, "{"name":"VERSION", "value":"1.2.3"}" ]}`

You may need to disable CSRF protection too.



