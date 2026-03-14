# Adán Morales | Infrastructure Architect
**10+ years Critical Infrastructure (Chilean Government and Telcos) | AWS Networking | Remote USD**


# networking-ptf
🚀 Networking Portfolio


## AWS VPN Hybrid 

**Site-to-Site VPN + Terraform | 7x24 Production Ready**

###  Screenshots Live Lab
#### Site-to-Site VPN Production-Ready
![VPN Config](vpn-hybrid_screens/Screenshot2-vpn-dashboard.png)

![Tunnel Details](vpn-hybrid_screens/Screenshot3-vpn-detail.png) 

#### Route Propagation Active
![Route Propagation](vpn-hybrid_screens/Screenshot4-route-propagation.png)

### 💻 Terraform Automation
```bash
terraform plan  # 4 resources ready
```

### Terraform IaC - Production Deployed
```bash
$ terraform apply  
```
![Terraform Apply](vpn-s2s-terraform_screens/Screenshot-apply.png)
![Terraform Apply-end](vpn-s2s-terraform_screens/Screenshot-apply-end.png)



## Multi-VPC

**Hub-and-spoke architecture** | Cisco ACI → AWS scale | 1000+ VPCs ready

#### Transit Gateway Multi-VPC (Scale)
![TGW Live](tgw-multi-vpc_screens/Screenshot-dashboard.png)



## 🌐 AWS Route53 - Enterprise DNS
![Hosted Zone](route53-dns-screens/Screenshot-hostedZone-regA.png)
**onPrem public/private DNS -> AWS Route53 migration**

- Hosted Zone: onpremdomain.net (4 NS records)
- A Record: www → Production IP
- Government DNS compliance standards

![DNS Live](route53-dns-screens/Screenshot-dig.png)
**DNS Resolution LIVE:** `dig @AWS NS → OK`


## ⚖️ NLB High Availability Production
![NLB Healthy](NLB_screens/Screenshot-nlb-ready.png)
 **Internet-facing** Multi-AZ ap-southeast-2a/b
 **2x t2.micro** + Security Group enterprise

![NLB service](NLB_screens/Screenshot-bknd.png)
 **2/2 healthy targets** TCP:80 (99.99% SLA)

![NLB rr1](NLB_screens/Screenshot-nlb-serv1.png)
![NLB rr2](NLB_screens/Screenshot-nlb-serv2.png)
 **Web round-robin LIVE:** Server1 ↔ Server2
