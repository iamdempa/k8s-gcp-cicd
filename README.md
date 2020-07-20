# k8s-aws-cicd

Provisioning a kubernetes cluster with terraform and ansible on AWS with the help of a user-defined gitlab runner and Gitlab CI/CD pipeline

# prerequisites

You need the following steps to be followed before deploying the `kubernetes` cluster

__1. A specific Gitlab Runner__

You need to have a Gitlab-runner deployed in the aws infrastructure to carry out the build jobs. 

a) Spin up an __amazon-linux 2__ (centos) `EC2` instance __(t2.micro)__ is enough to accomodate the gitlab-runner

b) Download the gitlab-runner binary

```
# For Debian/Ubuntu/Mint
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash

# For RHEL/CentOS/Fedora
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
```

then install the gitlab-runner

```
# For Debian/Ubuntu/Mint
sudo apt-get install gitlab-runner

# For RHEL/CentOS/Fedora
sudo yum install -y gitlab-runner
```

then add the runner to the __root__ privileges group 

```
//debian
sudo usermod -a -G sudo gitlab-runner

//centos
sudo usermod -a -G wheel gitlab-runner
```

then edit the `visudo` file to provide the root access with no password. type

```
sudo visudo
```

and add under the `sudoers`

```
gitlab-runner ALL=(ALL) NOPASSWD: ALL
```

then register the runner

```
sudo gitlab-runner register
```

Or you can either provision `gitlab-runner` with AWS Auto-Scaling group with Launch Configurations. Create an AWS Launch Configuration with following `user data`.

```
#!/bin/sh
sudo yum update -y
sudo amazon-linux-extras install ansible2 -y
sudo su -
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
yum update -y
yum install gitlab-runner -y
usermod -a -G wheel gitlab-runner
sh -c "echo \"gitlab-runner ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
export CI_SERVER_URL=https://gitlab.com/
export RUNNER_NAME=banuka
export REGISTRATION_TOKEN=<Enter your gitlab Token here>
export REGISTER_NON_INTERACTIVE=true
export RUNNER_EXECUTOR=shell
export RUNNER_TAG_LIST=banuka
gitlab-runner register
```
Above, the value you specify for `RUNNER_TAG_LIST` should be the name you refer in the `tags` field in your `.gitlab-ci.yml`. And provide the `REGISTRATION_TOKEN` as well. You can find this token under the __Settings__ of your repo.






