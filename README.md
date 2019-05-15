### Azure-IaC
Infrastructure as Code for Azure IaaS

#### Naming Convention prefix/suffix
|Resources             |Prefix|
|----------------------|------|
| Resource Group Name  | RG   |
| NetworkSecurityGroup | NSG  |
| Virtual Network      | VNet |
| Virtual NIC          | VNic |
| Public Ip address    | Pip  |
| Subnet               | Sub  |
| Traffic Manager      | TM   |
| Load Balancer        | LB   |
| Application Gateway  | AG   |
| App Service          | App  |
| Key Vault            | KV   |
| Sql Server           | SQL  |
| Sql Database         | SDb  |
| Storage Account      | stor |
| Virtual Machine      | VM   |
| Virtual Data Disk    | VDD  |
| OS Disk              | OSD  |
| Azure Subscription   | Subs |
| Availablity Set      | Avst |


**Note**: Storage Account Name - lowercase only, can't have dash or dot.  

__Deploy-AzManagedDiskVM.ps1__ Deploy Virtual Machine in Azure IaaS environment using the configuration template psd1 file. Along with the VM, this also deploys a Virutal Network with a subnet, a Virtual NIC for the VM and assign a Public IP address to the VM. 

                                        