# IaC Deployment Pipeline

This CI/CD pipeline is used to automate the deployment, destruction, and versioning of Infrastructure as Code (IaC) using **Terraform** and **Terragrunt**. The pipeline includes various stages, such as validating configuration, planning, applying changes, manual approval for UAT and PRD, and conditional infrastructure destruction. Additionally, it supports version bumping and release generation based on input.

## Pipeline Stages

### 1. **Triggering the Pipeline**

The pipeline can be triggered in two ways:

- **Manual Trigger (`workflow_dispatch`)**: This allows you to manually trigger the pipeline and provide input parameters, including:
  - `environment`: Choose the environment to deploy (dev, uat, prd).
  - `destroy`: A choice to determine if the infrastructure should be destroyed (`yes` or `no`).
  - `version_type`: Specify which version of the repository to bump (major, minor, patch).

- **Push to `main` Branch (`push`)**: This will automatically trigger the pipeline when there is a push to the `main` branch.

### 2. **Environment Variables**

The pipeline defines the following environment variables:
- `TF_VERSION`: Specifies the version of Terraform to use (`1.5.0`).
- `TERRAGRUNT_VERSION`: Specifies the version of Terragrunt to use (`v0.45.0`).

### 3. **Job: Validate Terraform**

This job is responsible for validating the Terraform configuration before any changes are made. 

- **Steps**:
  - Checkout the repository.
  - Set up the Terraform version.
  - Validate the configuration for the selected environment using `terragrunt validate`.

### 4. **Job: Plan Infrastructure**

This job generates the Terraform plan for the environment to ensure there are no unexpected changes when applying infrastructure changes.

- **Steps**:
  - Checkout the repository.
  - Set up the Terraform version.
  - Generate the Terraform plan using `terragrunt plan` for the selected environment.

### 5. **Job: Apply Changes to Environment**

This job applies the infrastructure changes to the selected environment (DEV, UAT, PRD).

- **Steps**:
  - Checkout the repository.
  - Set up the Terraform version.
  - Apply the infrastructure changes using `terragrunt apply --auto-approve`.

### 6. **Job: Deploy to UAT (Manual Approval)**

This job deploys the changes to the UAT environment. It requires **manual approval** before proceeding.

- **Trigger**: The deployment to UAT will only happen if the environment is set to `dev` (as defined by the `if: github.event.inputs.environment == 'dev'` condition).
- **Manual Approval**: The `trstringer/manual-approval@v1` action is used to request manual approval from specified users (`trstringer`, `acdunnigan`).
- **Steps**:
  - Wait for approval.
  - Checkout the repository.
  - Set up the Terraform version.
  - Apply the infrastructure changes to UAT using `terragrunt apply`.

### 7. **Job: Deploy to PRD (Manual Approval)**

This job deploys the changes to the PRD environment and also requires **manual approval** before proceeding.

- **Trigger**: The deployment to PRD will only happen if the environment is set to `uat` (as defined by `if: github.event.inputs.environment == 'uat'`).
- **Manual Approval**: The action `trstringer/manual-approval@v1` is used again to request manual approval from specified users.
- **Steps**:
  - Wait for approval.
  - Checkout the repository.
  - Set up the Terraform version.
  - Apply the infrastructure changes to PRD using `terragrunt apply`.

### 8. **Job: Destroy Infrastructure (Conditional)**

This job destroys the infrastructure, but it only triggers if the `destroy` input is set to `yes`.

- **Trigger**: If the `destroy` input is set to `yes`, the pipeline will proceed to destroy the infrastructure for the selected environment.
- **Steps**:
  - Checkout the repository.
  - Set up the Terraform version.
  - Destroy the infrastructure using `terragrunt destroy --auto-approve`.

### 9. **Job: Release Infrastructure and Publish Git Release**

This job is responsible for version bumping and publishing a Git release after the infrastructure has been successfully deployed to PRD. This happens **only after the `deploy-to-prd` job** is successful and if `destroy` is not selected.

- **Trigger**: This job will only run if the environment is set to `prd` and `destroy` is set to `no` (as defined by the condition `if: github.event.inputs.environment == 'prd' && github.event.inputs.destroy == 'no'`).
- **Steps**:
  - Checkout the repository.
  - Set up Git configuration (user name and email).
  - Bump the version using a script (`bumpup_version.sh`) based on the input (`major`, `minor`, or `patch`).
  - Push the new tags and changes to the Git repository.

---

### Summary of the Pipeline Flow

1. **Start**: Manually trigger or push to `main` branch.
2. **Validation**: Validate Terraform configuration.
3. **Plan**: Generate a Terraform plan to preview changes.
4. **Apply**: Apply the infrastructure changes to the selected environment.
5. **Deploy to UAT/PRD**: Depending on the environment, deploy the changes. Requires manual approval for UAT and PRD.
6. **Destroy**: Optionally destroy the infrastructure if specified by the user.
7. **Release**: If the environment is PRD and no destruction is requested, bump the version and publish a Git release.

### Notes:
- The `destroy` input is **conditional**. If you don’t want to destroy the infrastructure, the pipeline will skip the destruction steps.
- **Manual approval** is required to proceed with UAT and PRD deployments to ensure stability and proper validation before production changes.
- **Version bumping** happens at the end of the pipeline to ensure the repository reflects the changes made after a successful deployment.

This pipeline is designed to allow flexibility and control over deployments, versioning, and infrastructure changes. It uses **Terraform** and **Terragrunt** for IaC management and GitHub Actions for CI/CD automation.
