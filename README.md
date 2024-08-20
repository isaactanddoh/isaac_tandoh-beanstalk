# **Beanstalk Deployment with VPC Using Infrastructure as Code**

## **Project Overview**
This project automates the deployment of an AWS Elastic Beanstalk environment along with its supporting VPC infrastructure using Infrastructure as Code (IaC). The project leverages Terraform modules and GitHub Actions for continuous deployment, enabling a seamless and scalable deployment process across different environments—development, staging, and production.

## **Directory Structure**

- **`vpc/`**:  
  Contains the configuration files required to set up the Virtual Private Cloud (VPC). These configurations define the networking components such as subnets, route tables, and security groups.

- **`env/`**:  
  Houses environment-specific configurations for:
  - `dev`
  - `stg`
  - `prod`  
  These configurations utilize the VPC and Beanstalk modules to create isolated environments tailored for each stage of deployment.

- **`beanstalk/`**:  
  Contains configuration files for deploying a sample application on AWS Elastic Beanstalk. This includes the setup of the Beanstalk environment itself, such as environment variables, instance types, and scaling policies.

- **`.github/`**:  
  This directory holds the GitHub Actions workflows that automate the deployment process. The workflows include triggers for applying and destroying the environments based on specific actions:
  - `apply`: Deploys the specified environment.
  - `destroy`: Destroys the specified environment.

## **Project Goal**
The primary goal of this project is to deploy and manage an AWS Elastic Beanstalk environment along with a custom VPC, using Terraform for Infrastructure as Code. The project ensures that the environments are modular, scalable, and easily reproducible across development, staging, and production.

## **Modules**
- **VPC Module**:  
  Defines the networking infrastructure necessary for the Beanstalk environment, including private and public subnets, route tables, and internet gateways.

- **Beanstalk Module**:  
  Configures the Elastic Beanstalk environment to host the sample application, incorporating settings like environment variables, instance types, and scaling options.

## **Continuous Deployment**
The project employs GitHub Actions for continuous deployment. The workflows automate the entire process, from applying the infrastructure to tearing it down when no longer needed. Each environment has its dedicated workflow, ensuring isolated and consistent deployments.

## **Usage Instructions**

### **Clone the Repository**
```bash
git clone https://github.com/isaactanddoh/isaac_tandoh-beanstalk.git
cd isaac_tandoh-beanstalk
```

### **Deploy an Environment**
To deploy an environment (e.g., dev environment):
```bash
# Navigate to the environment directory
cd env/dev

# Initialize and apply the Terraform configuration
terraform init
terraform apply
```

### **Destroy an Environment**
To destroy an environment:
```bash
# Navigate to the environment directory
cd env/dev

# Destroy the Terraform-managed infrastructure
terraform destroy
```

Alternatively, you can trigger the deployment or destruction via GitHub Actions.

## **Contributions**
Feel free to fork this repository, create a branch, and submit a pull request if you would like to contribute. Contributions are welcome!

## **Contact**
For any issues or inquiries, please open an [issue](https://github.com/isaactanddoh/isaac_tandoh-beanstalk/issues) on GitHub.
