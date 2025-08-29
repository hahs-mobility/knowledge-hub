---
icon: material/cursor-default-click-outline
---
# AWS Privatelink Connection Setup Guide

!!! info

      - You want to access a service in another `AWS account` or third-party that is exposed via `AWS PrivateLink`.

      - The service provider gives you a Service Name and a Private DNS Name (for example, api.partner.com).

      - For this connection to work, both endpoints need to be in the same `AWS Region`, for cross-region please follow this [documentation](https://aws.amazon.com/pt/blogs/networking-and-content-delivery/introducing-cross-region-connectivity-for-aws-privatelink/)

## Obtain Service Information

Contact the service provider and request:

- Service Name
      - example: `com.amazonaws.vpce.us-east-1.vpce-svc-f9330539c752b7993`
- Service Private DNS Name
      - example: `api.partner.com`

## Visual connection flow

``` mermaid
flowchart TD
    A["Your VPC resources<br/>(EC2, Lambda, ECS, etc.)"]
    B["VPC Endpoint<br/>(Interface Endpoint)"]
    C["AWS Private Network"]
    D["Service Provider's VPC"]
    E["Service<br/>at api.partner.com"]

    A --> B
    B --> C
    C --> D
    D --> E

```

## Create a VPC Endpoint
1. Sign in to `AWS` Console:
      * Go to the `AWS Management Console` and log in using your `AWS credentials`.
2. Navigate to `VPC`:
      * In the top search bar, type `VPC` and select the `Endpoints`.
3. Create a New Enpoint:
      * Click the `Create Enpoint` button.
4. Configure Endpoint Details.
      * Service Type: `Select 'PrivateLink Ready partner services'`.
      * Service Name: `Enter the service name provided above`.
      * Verify: `Click Verify to make sure AWS can resolve the service`.
5. Specify VPC:
      * Select the `VPC` where your workloads that need to access the service are running.
6. Select Subnets:
      * Choose at least one `subnet` per `Availability Zone` you want the endpoint to be available in.
7. Set Security Groups:
      * Assign a Security Group to the endpoint’s `ENIs`.
         * See section "[How to Create a Security Group Restricting Traffic from Your VPC](#how-to-create-a-security-group-restricting-traffic-from-your-vpc)" below for a best practice!
8. Configure Policy (Optional):
      * Set the endpoint policy (default is full access).
         * You can use this to restrict which `IAM principals` and resources in your account are allowed to use this endpoint.

9. Enable Private DNS Name
      * If the service provider supports Private DNS, enable this option.
         * Now, resources in your VPC will transparently access the service at `api.partner.com` via `PrivateLink`.

10. Create the Endpoint
      * Review and click `Create endpoint`.

## Endpoint Acceptance

!!! warning

      If the endpoint is in Pending acceptance state, let the service provider know, it might need be manually approved.


## Testing and Validation

Once the endpoint status is Available, you can use it.

1. Test DNS resolution within your VPC (from an EC2 instance, for example):

      ```bash title="Query dns record"
      dig api.partner.com
      ```

      It should resolve to the private IP address(es) of your VPC endpoint's ENIs.

2. Test service access from inside your VPC:

      ```bash title="Test service access"
      curl https://api.partner.com/
      ```

## How to Create a Security Group Restricting Traffic from Your VPC

1. To ensure only resources in your VPC can use the endpoint:

      * Identify Your `VPC CIDR`
        * In the AWS Console, navigate to `VPC` > `Your VPCs`.
      * Find your VPC and copy its IPv4 CIDR Block
        * example: `10.0.0.0/16`.

2. Create a New Security Group

      * Go to `VPC` > `Security Groups`.
      * Click `Create Security Group`.
        * Name: `privatelink-endpoint-sg`
        * Description: `Allow from my VPC`.
        * VPC: `Select your VPC`

3. Add Inbound Rule(s)

      * Set an inbound rule to allow expected traffic from your VPC only:

!!! Configuration

      We will assume here that remote service is running on port `443`

      | Type  | Protocol | Port Range | Source      | Description    |
      |-------|----------|------------|-------------|----------------|
      | HTTPS | TCP      | 443        | 10.0.0.0/16 | Allow VPC only |

4.  Attach Security Group to the Endpoint

      * When creating or editing your VPC Endpoint, choose `privatelink-endpoint-sg` as the Security Group.


