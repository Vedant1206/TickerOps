# Step 1: setup
import boto3
import random
import time

CLUSTER = "tickerops-dev-ecs-cluster"
SERVICE = "tickerops-dev-ecs-service"
TARGET_GROUP = "tickerops-dev-alb-tg"

session = boto3.Session(profile_name="tickerops", region_name="ca-central-1")
ecs = session.client("ecs")
elb = session.client("elbv2")


# Step 2: health check (running, wanted, healthy)
def get_health():
    svc = ecs.describe_services(cluster=CLUSTER, services=[SERVICE])["services"][0]

    tg_arn = elb.describe_target_groups(Names=[TARGET_GROUP])["TargetGroups"][0]["TargetGroupArn"]
    targets = elb.describe_target_health(TargetGroupArn=tg_arn)["TargetHealthDescriptions"]
    healthy = [t for t in targets if t["TargetHealth"]["State"] == "healthy"]

    return svc["runningCount"], svc["desiredCount"], len(healthy)


# Step 3: safety checks (deployed? healthy? applied?)
try:
    running, desired, healthy = get_health()
except (IndexError, elb.exceptions.TargetGroupNotFoundException):
    print("Not deployed: nothing to test")
    raise SystemExit

print(f"Before: {running}/{desired} running, {healthy} healthy")

if running != desired or healthy != desired:
    print("Service is not healthy: not stopping anything")
    raise SystemExit

answer = input("Type yes to stop a random task: ")
if answer != "yes":
    print("Cancelled")
    raise SystemExit


# Step 4: stop a random task, start the timer
tasks = ecs.list_tasks(cluster=CLUSTER, serviceName=SERVICE, desiredStatus="RUNNING")["taskArns"]
victim = random.choice(tasks)

ecs.stop_task(cluster=CLUSTER, task=victim, reason="chaos test")
start = time.time()
print(f"Stopped task {victim.split('/')[-1]}")


# Step 5: wait until healthy again
while True:
    running, desired, healthy = get_health()
    if healthy < desired:
        print(f"{int(time.time() - start)}s: dip seen, {healthy} healthy")
        break
    time.sleep(2)

while True:
    running, desired, healthy = get_health()
    elapsed = int(time.time() - start)
    print(f"{elapsed}s: {running}/{desired} running, {healthy} healthy")
    if running == desired and healthy == desired:
        break
    if elapsed > 300:
        print("Still not healthy after 5 min: check the console")
        raise SystemExit
    time.sleep(5)


# Step 6: print the recovery time
print(f"✅ Recovered in {int(time.time() - start)} seconds")

