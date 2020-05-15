# High Performance CentOS 7 AMI

The stock RHEL and CentOS AMIs are highly unoptimized and typically out of date.  This project aims to create a high-performance CentOS 7 image that is unencumbered of product codes or other restrictions. It now also includes a recent Linux kernel and Docker.

In informal testing (building Chef server clusters) we've been able to cut deploy times by 50%.

These images are built by Chef's Customer Success team for the benefit of our customers.  For that reason, all images include the latest ChefDK :)

Credit to the DCOS team, this project is based on their [CentOS 7 cloud image](https://github.com/dcos/dcos/tree/master/cloud_images/centos7)


# Usage

## Building your own image

Simply set your `AWS_*` environment variables and run packer.  The easiest way to do this is to set up your profiles via `aws configure` and then export the correct `AWS_PROFILE` variable.
```
export AWS_PROFILE='myprofile'
packer build packer.json
```

## Consuming existing AMIs

### From Terraform
```
data "aws_ami" "centos" {
  most_recent = true
  owners = ["446539779517"] # Chef success

  filter {
    name   = "name"
    values = ["chef-highperf-centos7-*"]
  }
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.centos.id}"
  instance_type = "t2.micro"
}
```

### Latest AMIs
The latest AMIs were Published on 2020/05/15

```
ap-northeast-1: ami-04833e296a9bfc41a
ap-northeast-2: ami-0558a6ce45a3f78ee
ap-south-1: ami-01c18a17b3e07b5e3
ap-southeast-1: ami-047e8076f4d853432
ap-southeast-2: ami-0be404d991a0766d0
ca-central-1: ami-0f9fa62621b3dfeac
eu-central-1: ami-0e69c5560246b894f
eu-north-1: ami-06f5c1e1ce3cdc148
eu-west-1: ami-063589b5075ca9460
eu-west-2: ami-033bcf62a7728d3e4
eu-west-3: ami-025ba482c73ecb3cd
sa-east-1: ami-0541b6e29d80e230a
us-east-1: ami-08b2fc6637575c7c8
us-east-2: ami-0a8d30e9659472c2f
us-west-1: ami-0f6e519fe18711e88
us-west-2: ami-0d83d024236b1d7e8
```

Changelog:
* CentOS 7.8 (kernel kernel-3.10.0-1127.el7)
* Chef Workstation 0.18.3 / Puppet Agent 6.15.0/ Amazon SSM Agent 2.3.1205.0

----

### Previous AMIs
See [the CHANGELOG](./CHANGELOG.md)

## Contributors
* Irving Popovetsky (@irvingpop) - Maintainer
* Gavin Staniforth (@gsdevme)
* John Jelinek IV (@johnjelinek)
* Josh Sooter (@jsooter)
* Siebrand Mazeland (@siebrand)
