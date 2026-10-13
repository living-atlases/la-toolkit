// Builds, checks and publishes livingatlases/la-toolkit.
//   master                  -> :dev
//   a vX.Y.Z tag on master  -> :X.Y.Z and :vX.Y.Z (the tag, pubspec.yaml and the
//                              backend's vX.Y.Z tag must agree, see docker/ci/resolve.sh),
//                              then the GitHub release with docs/release-notes/vX.Y.Z.md
// :latest never moves on its own: build with PROMOTE_VERSION=X.Y.Z to point it at an
// already published release, same digest, nothing rebuilt. Watchtower then upgrades
// every unpinned installation to it within the hour.
// Job: Pipeline from SCM, branches */master and refs/tags/v*, refspec
// +refs/heads/master:refs/remotes/origin/master +refs/tags/*:refs/tags/*
pipeline {
    agent any

    triggers {
        pollSCM('H/15 * * * *')
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '30'))
    }

    parameters {
        booleanParam(name: 'PUSH', defaultValue: true,
            description: 'Push the image to Docker Hub when every check passes.')
        string(name: 'PROMOTE_VERSION', defaultValue: '', trim: true,
            description: 'X.Y.Z: only point :latest at that published release (same digest, nothing is built). Watchtower then upgrades every unpinned installation within the hour, so not for a release that needs the operator to do anything by hand (docs/release-checklist.md).')
    }

    environment {
        IMAGE = 'livingatlases/la-toolkit'
        DOCKER_REGISTRY_CREDS = 'docker-hub-la'
        GITHUB_RELEASE_CREDS = 'github-la-toolkit-release'
        DOCKERFILE = 'docker/u22/Dockerfile'
        LOCAL_IMAGE = "la-toolkit-ci:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Promote') {
            when {
                expression { params.PROMOTE_VERSION }
            }
            steps {
                script {
                    if (!(params.PROMOTE_VERSION ==~ /[0-9]+\.[0-9]+\.[0-9]+/)) {
                        error("PROMOTE_VERSION must be X.Y.Z, not '${params.PROMOTE_VERSION}'")
                    }
                    currentBuild.displayName = "#${env.BUILD_NUMBER} latest -> ${params.PROMOTE_VERSION}"
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_REGISTRY_CREDS, usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                        sh 'echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin'
                        try {
                            sh 'docker buildx imagetools create -t "$IMAGE:latest" "$IMAGE:$PROMOTE_VERSION"'
                        } finally {
                            sh 'docker logout'
                        }
                    }
                    def digests = ['latest', params.PROMOTE_VERSION].collect { t ->
                        sh(returnStdout: true, script: "docker buildx imagetools inspect \"\$IMAGE:${t}\" --format '{{json .Manifest.Digest}}'").trim()
                    }.unique()
                    if (digests.size() != 1) {
                        error(":latest and :${params.PROMOTE_VERSION} differ: ${digests}")
                    }
                    echo "${env.IMAGE}:latest = ${env.IMAGE}:${params.PROMOTE_VERSION} = ${digests[0]}"
                }
            }
        }

        stage('Resolve') {
            when {
                expression { !params.PROMOTE_VERSION }
            }
            steps {
                script {
                    // The tags on HEAD decide dev or release; a poll of master
                    // fetches them too (refspec above).
                    sh 'git fetch --tags --force origin'
                    sh 'bash docker/ci/test-resolve.sh'
                    sh 'bash docker/ci/test-github-release.sh'
                    def resolved = sh(returnStdout: true, script: 'docker/ci/resolve.sh').trim()
                    resolved.split('\n').each { line ->
                        def kv = line.split('=', 2)
                        env."${kv[0]}" = kv.size() > 1 ? kv[1] : ''
                    }
                    env.APP_VERSION = sh(returnStdout: true, script: "sed -n 's/^version: *//p' pubspec.yaml | head -1").trim()
                    currentBuild.displayName = env.RELEASE_TAG ? "#${env.BUILD_NUMBER} ${env.RELEASE_TAG}" : "#${env.BUILD_NUMBER} dev"
                    echo "release tag: '${env.RELEASE_TAG}', app ${env.APP_VERSION}, backend ${env.BACKEND_REF} ${env.BACKEND_SHA} (${env.BACKEND_VERSION})"
                    // The GitHub release body; checked now, not after an hour of build.
                    if (env.RELEASE_TAG && !fileExists("docs/release-notes/${env.RELEASE_TAG}.md")) {
                        error("no docs/release-notes/${env.RELEASE_TAG}.md for the GitHub release")
                    }
                }
            }
        }

        stage('Test') {
            when {
                expression { !params.PROMOTE_VERSION }
            }
            parallel {
                stage('core and MCP') {
                    steps {
                        sh 'docker build --pull --target mcp-test -f "$DOCKERFILE" .'
                    }
                }
                stage('frontend') {
                    steps {
                        sh 'docker build --pull --target web-test -f "$DOCKERFILE" .'
                    }
                }
            }
        }

        stage('Build') {
            when {
                expression { !params.PROMOTE_VERSION }
            }
            steps {
                sh '''
                    docker build --pull -f "$DOCKERFILE" \
                      --build-arg BACKEND_REF="$BACKEND_REF" \
                      --build-arg BACKEND_SHA="$BACKEND_SHA" \
                      --label org.opencontainers.image.source=https://github.com/living-atlases/la-toolkit \
                      --label org.opencontainers.image.revision="$(git rev-parse HEAD)" \
                      --label org.opencontainers.image.version="${RELEASE_TAG:-dev}" \
                      --label la-toolkit.backend.revision="$BACKEND_SHA" \
                      -t "$LOCAL_IMAGE" .
                '''
            }
        }

        stage('Smoke') {
            when {
                expression { !params.PROMOTE_VERSION }
            }
            steps {
                sh 'docker/ci/smoke.sh "$LOCAL_IMAGE" "$BACKEND_VERSION"'
            }
        }

        stage('Push') {
            when {
                expression { params.PUSH && !params.PROMOTE_VERSION }
            }
            steps {
                script {
                    def tags = env.RELEASE_TAG ? [env.RELEASE_TAG.substring(1), env.RELEASE_TAG] : ['dev']
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_REGISTRY_CREDS, usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                        sh 'echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin'
                        try {
                            tags.each { t ->
                                sh "docker tag \"\$LOCAL_IMAGE\" \"\$IMAGE:${t}\" && docker push \"\$IMAGE:${t}\""
                            }
                        } finally {
                            sh 'docker logout'
                            tags.each { t -> sh "docker image rm \"\$IMAGE:${t}\" >/dev/null 2>&1 || true" }
                        }
                    }
                    // Every tag just pushed must be the same manifest.
                    def digests = tags.collect { t ->
                        sh(returnStdout: true, script: "docker buildx imagetools inspect \"\$IMAGE:${t}\" --format '{{json .Manifest.Digest}}'").trim()
                    }.unique()
                    if (digests.size() != 1) {
                        error("pushed tags ${tags} resolve to different digests: ${digests}")
                    }
                    echo "pushed ${tags.collect { "${env.IMAGE}:${it}" }.join(', ')} = ${digests[0]}"
                }
            }
        }

        // The app's upgrade banner compares against the newest GitHub release.
        stage('GitHub release') {
            when {
                expression { params.PUSH && env.RELEASE_TAG && !params.PROMOTE_VERSION }
            }
            steps {
                withCredentials([string(credentialsId: env.GITHUB_RELEASE_CREDS, variable: 'GH_TOKEN')]) {
                    sh 'docker/ci/github-release.sh "$RELEASE_TAG"'
                }
            }
        }
    }

    post {
        always {
            sh 'docker image rm "$LOCAL_IMAGE" >/dev/null 2>&1 || true'
        }
    }
}
