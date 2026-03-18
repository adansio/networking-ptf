# Adán Morales | Infrastructure Architect
**10+ yrs Critical Infrastructure (Chilean Government and Telcos) | AWS Networking | Remote USD**


# 🚀 Networking Portfolio
Screenshots Live Lab

## 🌉 AWS VPN Hybrid 
### Site-to-Site VPN Production-Ready
![VPN Config](vpn-hybrid_screens/Screenshot2-vpn-dashboard.png)

![Tunnel Details](vpn-hybrid_screens/Screenshot3-vpn-detail.png) 
**Site-to-Site VPN + Terraform | 7x24 Production Ready**

### Route Propagation Active
![Route Propagation](vpn-hybrid_screens/Screenshot4-route-propagation.png)


## 💻 Terraform IaC - Production Deployed
```bash
$ terraform plan  # 3 resources ready
...
Plan: 3 to add, 0 to change, 0 to destroy.
```

```bash
$ terraform apply  
```
![Terraform Apply](vpn-s2s-terraform/Screenshot-apply.png)
![Terraform Apply-end](vpn-s2s-terraform/Screenshot-apply-end.png)
![Terraform code: vpn-hybrid.tf](vpn-s2s-terraform/vpn-hybrid.tf)



## 🏢 Multi-VPC

### Transit Gateway Multi-VPC (Scale)
![TGW Live](tgw-multi-vpc_screens/Screenshot-dashboard.png)
**Hub-and-spoke architecture** | Cisco ACI → AWS scale | 1000+ VPCs ready


## 🌐 AWS Route53 - Enterprise DNS
![Hosted Zone](route53-dns-screens/Screenshot-hostedZone-regA.png)
**onPrem public/private DNS -> AWS Route53 migration**

- Hosted Zone: onpremdomain.net (4 NS records)
- A Record: www → Production IP
- Government DNS compliance standards

![DNS Live](route53-dns-screens/Screenshot-dig.png)
**DNS Resolution LIVE:** `dig @AWS NS → OK`


## ⚖️  NLB High Availability Production
![NLB Healthy](NLB_screens/Screenshot-nlb-ready.png)
 **Internet-facing** Multi-AZ ap-southeast-2a/b  
 **2x t2.micro** + Security Group enterprise

![NLB service](NLB_screens/Screenshot-bknd.png)
 **2/2 healthy targets** TCP:80 (99.99% SLA)

![NLB rr1](NLB_screens/Screenshot-nlb-serv1.png)
![NLB rr2](NLB_screens/Screenshot-nlb-serv2.png)
 **Web round-robin LIVE:** Server1 ↔ Server2

## ☸️  EKS Cluster Production 
![Cluster creation](EKS-production/create-cluster.sh)

![Cluster scalation](EKS-production/scale-cluster.sh)
```bash
chmod +x *-cluster.sh
./create-cluster.sh
```
![Cluster scalation](EKS-production/Screenshot-create.png)
**ko-samui-nodes** 🏗️ 1x t3.small READY (-> scaling 2x)

```bash
./scale-cluster.sh
```

![EKS Cluster](EKS-production/Screenshot-CLI-outputs.png)
**samui-portfolio** Kubernetes 1.34 ACTIVE  

![EKS aws](EKS-production/Screenshot-aws-console.png)

## ☁️  EKS APPS + HPA SCALING
### Manual deploy and static scaling
![EKS Deploy](nginxApp-NLB/Screenshot-manual-scale.png) 
**nginx manual deploy + scaling:** NLB internet-facing with Nginx backend

### Auto-scaling + .yml deploy
![nginx-deploy.yml](nginxApp-NLB/nginx-deploy.yml)
```bash
kubectl apply -f nginx-deploy.yml
```

**Lab scaling**: setting cpu-burner 
![cpu-burner.yml](nginxApp-NLB/cpu-burner.yml)

```bash
kubectl apply -f cpu-burner.yml
```
![HPA Scaling](nginxApp-NLB/Screenshot-auto-scale.png) 
**HPA 50% cpu utilization** -> autoscaling

![itworks](nginxApp-NLB/Screenshot-stillworking.png)
**Web still working** 
