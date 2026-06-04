pipeline {
agent any

environment {
    DOCKERHUB_USERNAME = 'gopalsharma1010'
    IMAGE_NAME         = 'devops-node-app'
    IMAGE_TAG          = "${BUILD_NUMBER}"

    AWS_REGION         = 'ap-south-1'
    AMI_ID             = 'ami-07a00cf47dbbc844c'
    EC2_KEY_NAME       = 'devops-project-key'
    SSH_ALLOWED_CIDR   = '192.168.49.1/32'
}

stages {

    stage('Checkout Code') {
        steps {
            checkout scm
        }
    }

    stage('Validate Node App') {
        steps {
            dir('app') {
                sh '''
                    npm install
                    node -c server.js
                '''
            }
        }
    }

    stage('Build Docker Image') {
        steps {
            dir('app') {
                sh '''
                    pwd
                    ls -la

                    docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG .
                    docker tag $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
                '''
            }
        }
    }

    stage('Login to DockerHub') {
        steps {
            withCredentials([
                usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )
            ]) {
                sh '''
                    echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                '''
            }
        }
    }

    stage('Push Docker Image') {
        steps {
            sh '''
                docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:latest
            '''
        }
    }

    stage('Terraform Init') {
        steps {
            dir('terraform') {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh 'terraform init'
                }
            }
        }
    }

    stage('Terraform Plan') {
        steps {
            dir('terraform') {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        terraform plan \
                          -var="aws_region=$AWS_REGION" \
                          -var="ami_id=$AMI_ID" \
                          -var="ec2_key_name=$EC2_KEY_NAME" \
                          -var="ssh_allowed_cidr=$SSH_ALLOWED_CIDR" \
                          -var="docker_image=$DOCKERHUB_USERNAME/$IMAGE_NAME" \
                          -var="docker_tag=$IMAGE_TAG"
                    '''
                }
            }
        }
    }

    stage('Terraform Apply') {
        steps {
            dir('terraform') {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        terraform apply -auto-approve \
                          -var="aws_region=$AWS_REGION" \
                          -var="ami_id=$AMI_ID" \
                          -var="ec2_key_name=$EC2_KEY_NAME" \
                          -var="ssh_allowed_cidr=$SSH_ALLOWED_CIDR" \
                          -var="docker_image=$DOCKERHUB_USERNAME/$IMAGE_NAME" \
                          -var="docker_tag=$IMAGE_TAG"

                        terraform output
                    '''
                }
            }
        }
    }
}

post {
    success {
        echo 'Pipeline completed successfully. Application should be running on EC2.'
    }

    failure {
        echo 'Pipeline failed. Check console logs for the failed stage.'
    }

    always {
        sh 'docker logout || true'
    }
}

}
