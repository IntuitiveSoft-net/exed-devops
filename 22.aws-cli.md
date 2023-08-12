# AWS CLI on Linux

The AWS Command Line Interface (AWS CLI) is an open source tool that enables you to interact with AWS services using commands in your command-line shell. With minimal configuration, the AWS CLI enables you to start running commands that implement functionality equivalent to that provided by the browser-based AWS Management Console from the command prompt in your terminal program. Terraform will use the configuration file of the AWS CLI to retrieve the access key when performing calls to AWS API.

1. Install AWS CLI 

```bash 
sudo apt install unzip
```

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

```bash 
unzip awscliv2.zip
```

```bash 
sudo ./aws/install
```

2. Test you AWS CLI installation

```bash
aws --version
```

You should have a result similar to:

```bash
aws-cli/2.6.2 Python/3.9.11 Linux/5.11.0-1022-aws exe/x86_64.ubuntu.20 prompt/off
```

3. Configure AWS CLI
```
aws configure
```
```bash
AWS Access Key ID [None]: <YOUR_ACCESS_KEY>
AWS Secret Access Key [None]: <YOUR_SECRET>
Default region name [None]: us-west-1
Default output format [None]: json
```

You can test the AWS CLI.

[AWS Documentation : AWS CLI usage](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-using.html)
```
aws ec2 describe-vpcs --filters Name=tag:lab-id,Values=pod1 
```
Example output
```json
{
  "Vpcs": [
    {
      "CidrBlock": "192.168.0.0/16",
      "DhcpOptionsId": "dopt-02cb9007f1d29d0fc",
      "State": "available",
      "VpcId": "vpc-REDACTED",
      "OwnerId": "REDACTED",
      "InstanceTenancy": "default",
      "CidrBlockAssociationSet": [
        {
          "AssociationId": "vpc-cidr-assoc-0e933f3263a8b89b7",
          "CidrBlock": "192.168.0.0/16",
          "CidrBlockState": {
            "State": "associated"
  [...]
```

---