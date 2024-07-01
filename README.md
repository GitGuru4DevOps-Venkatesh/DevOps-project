# DevOps-project
Comprehensive step-by-step process for setting up a DevOps project on GCP using Ubuntu servers

Let's build a simple web application and deploy it using Terraform, Docker, Kubernetes (GKE), and other tools on GCP. I'll guide you through the process, assuming you want to deploy a Node.js application. 

### Step-by-Step Guide

### Step 1: Set Up GCP Project and VM Instances

1. **Create a GCP Project:**
   - Go to the [GCP Console](https://console.cloud.google.com/).
   - Click on the project drop-down and select "New Project".
   - Give your project a name and click "Create".

2. **Create a VM Instance:**
   - Navigate to the "Compute Engine" section and click "VM instances".
   - Click "Create Instance".
   - Choose the following settings:
     - Name: `devops-sample-instance`
     - Region: Select a region close to you.
     - Machine type: `e2-medium` (or choose as per your requirement)
     - Boot disk: Choose `Ubuntu 20.04 LTS`
   - Click "Create".

3. **Connect to Your VM Instance:**
   - Once the instance is created, click the "SSH" button to open a terminal window connected to your VM.

### Step 2: Install Necessary Tools on Your VM

1. **Update the Package List:**
   ```sh
   sudo apt update
   ```

2. **Install Docker:**
   ```sh
   sudo apt install -y docker.io
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker $USER
   ```

3. **Install Kubernetes (kubectl):**
   ```sh
   sudo apt-get update
   sudo apt-get install -y apt-transport-https ca-certificates curl
   sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
   echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
   sudo apt-get update
   sudo apt-get install -y kubectl
   ```

4. **Install Terraform:**
   ```sh
   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install -y terraform
   ```

5. **Install Ansible:**
   ```sh
   sudo apt update
   sudo apt install -y ansible
   ```

6. **Install Git:**
   ```sh
   sudo apt update
   sudo apt install -y git
   ```

### Step 3: Create a Simple Node.js Application

1. **Create a new directory for your application:**
   ```sh
   mkdir ~/my-web-app
   cd ~/my-web-app
   ```

2. **Initialize a new Node.js project:**
   ```sh
   npm init -y
   ```

3. **Install Express.js:**
   ```sh
   npm install express
   ```

4. **Create an `app.js` file with the following content:**
   ```javascript
   const express = require('express');
   const app = express();
   const port = 8080;

   app.get('/', (req, res) => {
     res.send('Hello World!');
   });

   app.listen(port, () => {
     console.log(`App listening at http://localhost:${port}`);
   });
   ```

5. **Create a Dockerfile in the project directory:**
   ```dockerfile
   FROM node:14
   WORKDIR /usr/src/app
   COPY package*.json ./
   RUN npm install
   COPY . .
   EXPOSE 8080
   CMD ["node", "app.js"]
   ```

6. **Build and run the Docker container:**
   ```sh
   docker build -t my-web-app .
   docker run -p 8080:8080 my-web-app
   ```

### Step 4: Deploy Application to Kubernetes (GKE)

1. **Create a Terraform Configuration:**
   - Create a directory for your Terraform files: `mkdir ~/terraform-setup && cd ~/terraform-setup`.
   - Create a `main.tf` file with the following content:
     ```hcl
     provider "google" {
       project = "YOUR_PROJECT_ID"
       region  = "us-central1"
     }

     resource "google_container_cluster" "primary" {
       name     = "primary-cluster"
       location = "us-central1"

       node_config {
         machine_type = "e2-medium"  # Adjust machine size if needed
       }

       initial_node_count = 2  # Adjust the number of nodes if needed
     }
     ```

2. **Initialize and Apply Terraform Configuration:**
   ```sh
   terraform init
   terraform apply
   ```

3. **Create Kubernetes Deployment and Service YAML Files:**
   - Create a `deployment.yaml` file:
     ```yaml
     apiVersion: apps/v1
     kind: Deployment
     metadata:
       name: web-app
     spec:
       replicas: 3
       selector:
         matchLabels:
           app: web-app
       template:
         metadata:
           labels:
             app: web-app
         spec:
           containers:
           - name: web-app
             image: your-docker-image
             ports:
             - containerPort: 8080
     ```

   - Create a `service.yaml` file:
     ```yaml
     apiVersion: v1
     kind: Service
     metadata:
       name: web-app-service
     spec:
       type: LoadBalancer
       selector:
         app: web-app
       ports:
         - protocol: TCP
           port: 80
           targetPort: 8080
     ```

4. **Deploy to GKE:**
   ```sh
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

### Step 5: Set Up CI/CD Pipeline

1. **Install Jenkins:**
   ```sh
   sudo apt update
   sudo apt install -y openjdk-11-jdk
   wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
   sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
   sudo apt update
   sudo apt install -y jenkins
   sudo systemctl start jenkins
   sudo systemctl enable jenkins
   ```

2. **Configure Jenkins:**
   - Access Jenkins at `http://your_instance_ip:8080`.
   - Follow the on-screen instructions to complete the setup.

3. **Create a Jenkins Pipeline:**
   - In Jenkins, create a new pipeline job.
   - Use the following `Jenkinsfile`:
     ```groovy
     pipeline {
       agent any
       stages {
         stage('Build') {
           steps {
             sh 'npm install'
           }
         }
         stage('Test') {
           steps {
             sh 'npm test'
           }
         }
         stage('Deploy') {
           steps {
             sh 'kubectl apply -f k8s/deployment.yaml'
           }
         }
       }
     }
     ```

### Step 6: Monitoring and Logging

1. **Install Prometheus and Grafana:**
   - Follow the official guides to install [Prometheus](https://prometheus.io/docs/prometheus/latest/installation/) and [Grafana](https://grafana.com/docs/grafana/latest/installation/debian/).

2. **Configure Prometheus:**
   - Edit the `prometheus.yml` file to add your Kubernetes cluster as a target.

3. **Set Up ELK Stack:**
   - Follow the official guide to install and configure the [ELK Stack](https://www.elastic.co/what-is/elk-stack).

### Step 7: Testing and Documentation

1. **Automated Testing:**
   - Write automated tests for your application and integrate them into your CI/CD pipeline.

2. **Documentation:**
   - Document each step, configuration, and setup process.

This guide provides a comprehensive step-by-step process for setting up a DevOps project on GCP using Ubuntu servers. If you have any specific questions or need further assistance, feel free to ask! 

Any errors:
```
https://chatgpt.com/share/c94826df-0d7a-4b56-8972-04d8f1318e66
```
