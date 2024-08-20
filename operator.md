## AWS VPC

Amazon Virtual Private Cloud (VPC) allows you to provision a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. You have complete control over your virtual networking environment, including selection of your IP address range, creation of subnets, and configuration of route tables and network gateways.

### Design Decisions

- **Subnet Customization**: The VPC is designed to accommodate three types of subnets: public, private, and internal. This segmentation allows for a flexible network design that can cater to different types of workloads and their security needs.
- **High Availability**: NAT gateways and subnets are distributed across multiple availability zones to ensure high availability and fault tolerance.
- **Flow Logs**: VPC flow logs are enabled to capture information about the IP traffic going to and from network interfaces in your VPC, which are stored in Amazon CloudWatch.
- **Automated Alarms**: CloudWatch alarms are set up to monitor IP address utilization and NAT gateway port allocation errors. This helps in proactive monitoring and troubleshooting.
- **Security**: Default security groups are configured to ensure that security policies are in place right from the creation of the VPC.
- **CIDR Allocation**: The VPC and its subnets are configured with CIDR blocks, which can either be specified by the user or automatically allocated.

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

