project_name = "possible-origin-236919"
region = "asia-south1"
zone = "asia-south1-a"
bucket_name = "tf_backend_gcp_banuka_jana_jayarathna"
storage_class = "REGIONAL"

public_key_path = "/root/.ssh/id_rsa.pub"
gitlabnew_login_key_path = "/root/.ssh/gitlabnew.pub"
private_key_path = "/root/.ssh/id_rsa"
minions_count = "2"
machine_image = "ubuntu-1804-bionic-v20200317"
machine_type = "e2-medium"


master_region = "asia-south1"
master_zone = "asia-south1-a"

minion_region = "asia-south1"
minion_zone = "asia-south1-a"

master_cidr = "10.0.0.0/21"
minion_cidr = "10.0.8.0/21"