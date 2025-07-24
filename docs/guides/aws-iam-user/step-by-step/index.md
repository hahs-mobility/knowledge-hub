---
icon: material/cursor-default-click-outline
---
# AWS Account and IAM Setup Guide

Here's a `step-by-step` guide to creating an account in `AWS`, creating an IAM role, creating an IAM user, and then adding that user to the role:

## Create an `AWS` Account

1. Go to the `AWS` website:
      * Open a web browser and go to [AWS](https://console.aws.amazon.com).
2. Click on `Create a Free Account`:
      * This is located in the upper-right corner of the `AWS` homepage.
3. Provide Your Email Address:
      * You'll be prompted to provide an `email address`, `account name (organization name)`, and a `password` for your `AWS` account.
4. Enter Payment Information:
      * `AWS` will ask for a valid credit card. You won't be charged unless you use paid services.
5. Verify Your Identity:
      * This step may include entering a phone number for verification and completing `CAPTCHA`.
6. Select a Support Plan:
      * Choose the free basic support plan unless you need more advanced features.
7. Complete the Sign-Up Process:
      * Once you've entered all the details, you'll need to confirm your information and sign in using your new `AWS credentials`.

Once your account is created and verified, you'll be logged into the `AWS Management Console`.

## Create an IAM Role

An IAM role is a set of permissions that you can assign to users or services.

1. Sign in to `AWS` Console:
      * Go to the `AWS Management Console` and log in using your `AWS credentials`.
2. Navigate to `IAM`:
      * In the top search bar, type `IAM` and select the `IAM service`.
3. Create a New Role:
      * In the left-hand navigation pane, click Roles.
      * Click the Create role button.
4. Select `Trusted Entity`: Choose the type of trusted entity.
      * If you want to create a role for an `AWS service` (e.g., `EC2`, `Lambda`), select `AWS service`.
5. Choose the Use Case for the Role:
      * For example, if you're creating a role for `EC2 instances`, select `EC2`.
6. Set Permissions:
      * Choose the permissions you want to attach to this role. For example, if you want to grant full access to EC2, select AmazonEC2FullAccess.
7. Add Tags (Optional):
      * Tags can help you categorize and identify the role.
8. Review and Create:
      * Enter a role name and review the permissions and settings.
      * Click Create role.

Now you have an IAM role that can be assumed by a user or AWS service.

## Create an IAM User

!!! note "IAM"

    An IAM user is an individual identity within AWS with specific permissions.

1. Navigate to IAM:
      * If you're not already in the `IAM section`, go back to the `AWS Management Console` and search for `IAM`.
2. Create a New User:
      * In the IAM dashboard, click Users on the left.
      * Click the Add user button.
3. Set User Details:
      * Enter a username.
      * Choose the type of access the user will have:
         * Programmatic access (for API/CLI access).
         * AWS Management Console access (for web access).
      * Set a password if you chose AWS Management Console access.
4. Set Permissions:
      * Choose Attach policies directly if you want to assign specific permissions. For example, choose AdministratorAccess for full access.
      * Alternatively, you can assign the user to a group or copy permissions from another user.
5. Review and Create: Review the user settings and click Create user.

Once the user is created, make sure to save the access credentials (Access Key ID, Secret Access Key, and password for console access) provided on the next page.

## Add the IAM User to the IAM Role

Now that you have created the role and user, you need to allow the IAM user to assume the IAM role.

1. Navigate to `IAM Console`:
      * In the `AWS Console`, go to the `IAM section`.
2. Attach Role to User:
      * Click Users on the left sidebar.
      * Select the user you just created.
      * In the `Permissions tab`, click `Add permissions`.
3. Grant Permission to Assume Role:
      * Click Attach policies directly.
      * Search for the `IAMPolicy` that allows users to assume a role, or create your own policy (e.g., `IAMReadOnlyAccess` or `AdministratorAccess`).
4. Add Custom Permissions (if necessary):
      * If you are using a custom policy, ensure it allows `sts:AssumeRole` for the role you created before.
5. Review and Add:
      * After attaching the permissions, click `Review` and then `Add permissions`.

## Optional: Create a Custom Policy to Assume the Role

If you need a more specific policy (e.g., to allow the user to assume only a certain role), follow these steps:

1. Create a New Policy:
      * Go to `IAM > Policies > Create policy`.
      * Under the `JSON` tab, paste a policy like the one below (substitute with your role `ARN`):

      ``` json title="Example IAM Policy for assume a role"
      {
      "Version": "2012-10-17",
      "Statement": [
         {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME"
         }
      ]
      }
      ```

2. Attach the Custom Policy to the User:
      * Follow the steps to attach this new policy to the user as shown in the previous section.

## Test the User's Access

1. Log in as the User:
      * Using the IAM user credentials (either console login or programmatic), sign in.

2. Test Role Assumption:
      * If you created an IAM role to be assumed, test by having the user assume the role.
      * You can do this through the `AWS Management Console` or by using the `AWS CLI`.

## Adding Custom S3 and KMS Access Policy

If you want to give the user specific access to `S3 buckets` and `KMS keys`, follow these steps to create and attach a custom policy:

1. Navigate to IAM Console: Go to the `AWS Management Console` and search for `IAM`.
2. Create a `New Policy`:
   - In the left sidebar, click on `Policies`.
   - Click `Create policy`.
   - Select the `JSON` tab.
   - Delete the default policy and paste the following policy (update as needed):

``` json title="Example IAM Policy for access resources"
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "S3Access",
			"Effect": "Allow",
			"Action": [
				"s3:*"
			],
			"Resource": [
				"arn:aws:s3:::s3-example-bucket",
				"arn:aws:s3:::s3-example-bucket/*"
			]
		},
		{
			"Sid": "KMSAccess",
			"Effect": "Allow",
			"Action": [
				"kms:ReEncrypt*",
				"kms:GenerateDataKey*",
				"kms:Encrypt",
				"kms:DescribeKey",
				"kms:Decrypt"
			],
			"Resource": "arn:aws:kms:eu-central-1:000000000000:key/xxxxxxx-xxxxxxx-xxxxxxx-xxxxxxx"
		}
	]
}
```

3. Review Policy:
   - Click `Next: Tags` (add tags if needed).
   - Click `Next: Review`.
   - Name the policy (e.g., `S3AndKMSAccessPolicy`).
   - Add a description such as `Grants access to specific S3 bucket and KMS key`.
   - Click `Create policy`.

4. Attach Policy to User:
   - In the left sidebar, click on `Users`.
   - Select the user you created earlier.
   - Click the `Add permissions` button.
   - Select `Attach policies directly`.
   - Search for your newly created policy by name and select it.
   - Click `Next: Review` and then `Add permissions`.


