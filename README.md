# EC2macConnector

EC2macConnector is a CLI tool that helps connect to EC2 mac instances easily.

## Installation

You can build EC2macConnector yourself for the required architecture (`arm64`, `x86_64` or both):

```
swift build -c release --arch arm64 --arch x86_64
```

and copy the executable to a folder in your `$PATH` such as `/usr/local/bin/`.

> **Note**
> 
> Once built, the executable can be found in the `.build` folder, usually at `.build/apple/Products/Release`. 

Alternatively, you can download a release from the [list of releases](https://github.com/albertodebortoli/EC2macConnector/releases).


## Requirements

### Permissions

Both commands require AWS credentials either set as environment variables (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) or configured in `~/.aws/credentials` via the [AWS CLI](https://aws.amazon.com/cli/). Environment variables take precedence.

The user must be granted the following permissions:

- `ec2:DescribeInstances`
- `secretsmanager:ListSecrets`
- `secretsmanager:GetSecretValue`

### EC2 instances

The EC2 mac instances must have the `EC2macConnector:FleetIndex` tag set to the index of the instance in the fleet. Indexes should start at 1.
Instances that don't have the said tag will be ignored.


### Secrets and key pairs formats

EC2macConnector assumes that the private key for each instance key pair is stored in SecretsManagers. The name of the key pair could and should be different from the secret ID.
For example, the instance key pair should include an incremental number also part of the corresponding secret ID.

Consider that the number of mac instances in an AWS account is limited and it's convenient to refer to them using an index starting at 1.
It's good practice for the secret ID to also include a nonce as secrets with the same name cannot be recreated before the deletion period has elapsed, allowing quick provisioning-decommissioning cycles.

For the above reasons, EC2macConnector assumes the following formats are used:

- instance key pairs: `<keypair_prefix>_<index_of_instance_in_fleet>` e.g. `mac_instance_key_pair_5`
- secret IDs: `<secrets_prefix>_<index_of_instance_in_fleet>_<nonce>` e.g. `private_key_mac_metal_5_dx9Wna73B`


## Usage

EC2macConnector comes with 2 commands:

- `configure`: configure the tool by creating connect script and vncloc files for running EC2 mac instances.
- `connect`: connect to EC2 mac instances over SSH or VNC.

### Examples

#### Configure

```
ec2macConnector configure \
  --region eu-west-1 \
  --secrets-prefix private_key_mac_metal
```

Optionally use the `--verbose` flag to inspect where the private keys and configuration files have been stored.

#### Connect

Connect to instance with index 5 over SSH:

```
ec2macConnector connect 5 --region eu-west-1
```

Connect to instance with index 5 over VNC:

```
ec2macConnector connect 5 --region eu-west-1 --vnc
```

> **Note**
> 
> Connecting over VNC requires an SSH session to be established first.
