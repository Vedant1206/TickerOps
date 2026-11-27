import boto3

session = boto3.Session(profile_name="tickerops", region_name="ca-central-1")

ec2 = session.client("ec2")

nats = ec2.describe_nat_gateways(
    Filter=[{"Name": "state", "Values": ["available", "pending"]}]
)["NatGateways"]
print(f"NAT gateways: {len(nats)}")

elb = session.client("elbv2")
albs = elb.describe_load_balancers()["LoadBalancers"]
print(f"Load balancers: {len(albs)}")

eips = ec2.describe_addresses()["Addresses"]
print(f"Elastic IPs: {len(eips)}")

ecs = session.client("ecs")
clusters = ecs.list_clusters()["clusterArns"]
print(f"ECS clusters: {len(clusters)}")

ecr = session.client("ecr")
repos = ecr.describe_repositories()["repositories"]
print(f"ECR repos: {len(repos)}")

vpcs = ec2.describe_vpcs(
    Filters=[{"Name": "tag:Name", "Values": ["tickerops*"]}]
)["Vpcs"]
print(f"TickerOps VPCs: {len(vpcs)}")

total = len(nats) + len(albs) + len(eips) + len(clusters) + len(repos) + len(vpcs)

if total == 0:
    print("✅ All clear: nothing left that costs money")
else:
    print(f"❌ {total} resources still running: destroy them")