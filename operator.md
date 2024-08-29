## AWS VPC

Amazon Virtual Private Cloud (VPC) allows you to provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of your IP address range, creation of subnets, and configuration of route tables and network gateways.

### Design
This VPC is designed to match [AWS's recommended VPC configuration](https://docs.aws.amazon.com/quickstart/latest/vpc/architecture.html). This is the most flexible configuration and should cover almost all use cases. This configuration allocates:
* ½ of the IP space to private subnets
* ¼ of the IP space to public subnets
* ⅛ of the IP space to internal subnets
* ⅛ of the IP space reserved as spare capacity

VPCs are composed of one or more subnets, which are allocations of IP addresses with the VPC. These subnets can have separate routing tables which determine what resources the subnet has access to. Some subnets may use a route table which gives access to the internet (via an [Internet Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html)), which provides internet access into and out of the subnet. This is ideal for web based services, but it would be dangerous to host a database containing sensitive data in a subnet that is internet reachable. Instead you would host a private database in a subnet with very limited routing rules to restrict access.

This bundle offers 3 classes of subnets:
* public
* private
* internal

#### Public Subnets
Public subnets allow internet traffic to flow into and out of the subnet. This subnet should only be used for resources that need to be directly reachable from the internet, such as load balancers.

#### Private Subnets
Private subnets are not reachable from the internet, but allow services within the subnet to establish connections out to the internet. By restricting access from the internet, resources within this subnet are provided an additional layer of security. It is common to run webservers in private subnets with a load balancer running in a public subnet routing traffic to the webservers.

#### Internal Subnets
Internal subnets have no access to or from the internet. This makes the subnet very secure, but limited in usability since services are unable to reach any internet resources, including software updates. This subnet is commonly used for strictly internal resources, such as databases (managed databases, such as AWS RDS, receive updates from AWS and thus do not need internet access to stay up to date).

### Availability Zones
AWS regions are separated into multiple [availability zones](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/), which are separate data-centers with redundant power, networking and connectivity. In the context of AWS VPC, subnets must be associated with only a single availability zone. It is a [best practice](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html) to use multiple availability zones to provide redundancy and fault-toleration for services running in the VPC in the event of an zonal outage. For this reason, this VPC bundle creates subnets in as many availability zones as the selected region supports, up to a maximum of 4 (currently only `us-east-1` has more than 4 regions).

### Design Decisions

- **Network Segmentation**: Public, private and internal subnets are created to cover a range of use-cases while maintaining security
- **Availability Zone Spread**: Each subnet type within the VPC will be provisioned across at least 3 availability zones for high availability in the event of a data center outage
- **NAT Gateway High Availability**: If selected, NAT gateways will be created for each availability zone with independent route tables for each private subnet providing robust high availability
- **Spare Capacity**: A small range of addresses is left unallocated in case of future growth or changing requirements
- **Flow Logs**: VPC Flow Logs are enabled by default to maintain an auditing trail of all network communication
- **Security Group Management**: IAM and Security Groups are built into each Massdriver bundle to ensure policy of least privilege is maintained

### Runbook

#### Checking VPC Subnet CIDR Blocks

If you need to verify the CIDR blocks assigned to your VPC subnets, you can use the AWS CLI:

```sh
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<your-vpc-id>"
```

This command will provide a list of subnets along with their CIDR blocks associated with your VPC.

#### Verifying Route Table Configuration

For issues related to routing within the VPC, you can check the route table settings:

```sh
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<your-vpc-id>"
```

Ensure that the routes are correctly configured for public, private, and internal subnets as required.

#### Diagnosing NAT Gateway Issues

If your private instances are unable to access the internet, you might want to check the status of NAT Gateways:

```sh
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<your-vpc-id>"
```

Ensure that the NAT gateways are in the `available` state.

#### Monitoring IP Address Utilization

To check the IP address utilization in your VPC, you can use CloudWatch metrics:

```sh
aws cloudwatch get-metric-statistics --metric-name NetworkAddressUsage --namespace AWS/EC2 --statistics Maximum --period 86400 --start-time <start-time> --end-time <end-time>
```

This will provide insights into the available IP addresses in your VPC.

#### Investigating Security Group Rules

If there's a connectivity issue, it might be due to restrictive security group rules. You can review them as follows:

```sh
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<your-vpc-id>"
```

Ensure that the required inbound and outbound rules are correctly configured for your security groups.

#### Ensuring Flow Logs Configuration

To make sure that your VPC flow logs are properly configured and active:

```sh
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=<your-vpc-id>"
```

Check that the flow logs are set up to capture traffic data as per the application's requirements.

#### CloudWatch Log Insights for Flow Logs

You can use AWS CloudWatch Log Insights to query VPC flow logs for deeper troubleshooting:

```sh
aws logs start-query --log-group-name "<log-group-name>" --start-time <start-time> --end-time <end-time> --query-string "fields @timestamp, srcAddr, dstAddr, action, bytes | sort @timestamp desc"
```

This command helps in analyzing the log data to identify sources and destinations of traffic, data transfer size, and actions (accepted/rejected).
