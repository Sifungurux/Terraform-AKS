-----

## Introduction: 

**Azure Kubernetes Service (AKS)** manages your hosted Kubernetes environment.
AKS allows you to deploy and manage containerized applications without container orchestration expertise. AKS also enables you to do many common maintenance operations without taking your app offline. These operations include provisioning, upgrading, and scaling resources on demand.

Using the Azure Portal you can create a cluster with few clicks, but it usually a better idea to keep the configuration for your cluster - and basically all infra - under source control.

If you accidentally delete your cluster or decide to provision a copy in another region, you can  easily replicate the same configuration.

And if you're working as part of a team, source control gives you peace of mind. You know precisely why changes occurred and who made them.

> 💡By using **Terraform** to provision AKS Kubernetes clusters you can begin to both automate, but also now that you have captured it as a codified form, you can check it into version control and you get versioning.
