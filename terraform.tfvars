project_name = "possible-origin-236919"
region = "us-west2"
zone = "us-west2-a"
bucket_name = "tf_backend_gcp_banuka_jana_jayarathna"
storage_class = "REGIONAL"

public_key_path = "/root/.ssh/id_rsa.pub"
gitlabnew_login_key_path = "/root/.ssh/gitlabnew.pub"
private_key_path = "/root/.ssh/id_rsa"
minions_count = "2"
machine_image = "ubuntu-1804-bionic-v20200317"
machine_type = "e2-medium"

# master 
master_cidr = "10.0.0.0/21"
master_subnet_region = "us-west2"
master_zone = "us-west2-a"

# minion 
minion_cidr = "10.0.8.0/21"
minion_subnet_region = "us-west2"
minion_zone = "us-west2-b"


