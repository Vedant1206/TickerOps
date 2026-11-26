import boto3

CLUSTER = "tickerops-dev-ecs-cluster"  
SERVICE = "tickerops-dev-ecs-service"

session = boto3.Session(profile_name="tickerops", region_name="ca-central-1")

# who am I service in AWS
sts = session.client("sts")
me = sts.get_caller_identity()
print(me["Arn"])

# connects to ECS
ecs = session.client("ecs")

# tell me about this service, in this cluster"
resp = ecs.describe_services(cluster=CLUSTER, services=[SERVICE])

if not resp["services"] or resp["services"][0]["status"] != "ACTIVE":
    print("ECS: not deployed")
else:
    svc = resp["services"][0]
    print(f"ECS: {svc['runningCount']}/{svc['desiredCount']} tasks running")
    td = ecs.describe_task_definition(taskDefinition=svc["taskDefinition"])
    image = td["taskDefinition"]["containerDefinitions"][0]["image"]
    print(f"Image tag: {image.split(':')[-1]}")

elb = session.client("elbv2")

try:
    tg = elb.describe_target_groups(Names=["tickerops-dev-alb-tg"])
    tg_arn = tg["TargetGroups"][0]["TargetGroupArn"]

    health = elb.describe_target_health(TargetGroupArn=tg_arn)
    targets = health["TargetHealthDescriptions"]
    healthy = [t for t in targets if t["TargetHealth"]["State"] == "healthy"]
    print(f"Targets: {len(healthy)}/{len(targets)} healthy")

except elb.exceptions.TargetGroupNotFoundException:
    print("Targets: not deployed")
    

