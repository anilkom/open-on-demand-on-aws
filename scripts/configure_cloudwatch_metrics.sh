# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

mkdir /tmp/software
cd /tmp/software
sudo apt install wget -y -q
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo apt install -f ./amazon-cloudwatch-agent.deb -y -q

touch /opt/aws/amazon-cloudwatch-agent/bin/config.json
cat << EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
        "agent": {
                "metrics_collection_interval": 60,
                "run_as_user": "root"
        },
        "logs": {
                "logs_collected": {
                        "files": {
                                "collect_list": [
                                        {
                                                "file_path": "/var/log/slurm/slurmd.log",
                                                "log_group_name": "\${AWS::StackName}",
                                                "log_stream_name": "{instance_id}/slurmd.log"
                                        },
                                        {
                                                "file_path": "/var/log/slurm/slurmdbd.log",
                                                "log_group_name": "\${AWS::StackName}",
                                                "log_stream_name": "{instance_id}/slurmdbd.log"
                                        },
                                        {
                                                "file_path": "/var/log/slurm/slurmctld.log",
                                                "log_group_name": "\${AWS::StackName}",
                                                "log_stream_name": "{instance_id}/slurmctld.log"
                                        },
                                        {
                                                "file_path": "/var/log/ondemand-nginx/**",
                                                "log_group_name": "\${AWS::StackName}",
                                                "log_stream_name": "{instance_id}/ondemand-nginx"
                                        },
                                        {
                                                "file_path": "/var/log/ondemand-nginx/**",
                                                "log_group_name": "\${AWS::StackName}",
                                                "log_stream_name": "ondemand-httpd/{instance_id}"
                                        }
                                ]
                        }
                }
        },
        "metrics": {
                "append_dimensions": {
                        "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
                        "InstanceId": "\${aws:InstanceId}"
                },
                "metrics_collected": {
                        "cpu": {
                                "measurement": [
                                        "cpu_usage_idle",
                                        "cpu_usage_iowait",
                                        "cpu_usage_user",
                                        "cpu_usage_system"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ],
                                "totalcpu": false
                        },
                        "disk": {
                                "measurement": [
                                        "used_percent",
                                        "inodes_free"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "diskio": {
                                "measurement": [
                                        "io_time"
                                ],
                                "metrics_collection_interval": 60,
                                "resources": [
                                        "*"
                                ]
                        },
                        "mem": {
                                "measurement": [
                                        "mem_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        },
                        "swap": {
                                "measurement": [
                                        "swap_used_percent"
                                ],
                                "metrics_collection_interval": 60
                        }
                }
        }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json