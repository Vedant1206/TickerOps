# Chaos tests – M5

Environment: `envs/dev` in ca-central-1. 2 Fargate tasks (nginx, 0.25 vCPU / 512 MB) behind an ALB in 2 AZs, autoscaling 2–4 tasks on CPU (target 50%), 3 CloudWatch alarms → SNS email.

Date: 2026-11-07. Times are local (EST).

## Summary

| # | Test | What I did | What I expected | What happened | Time to recover |
|---|---|---|---|---|---|
| 1 | Stop a task | Stopped 1 of 2 tasks in the ECS console | ECS replaces it, site stays up | New task started 1 s after the old one began draining, registered in the target group after 20 s, service steady after 29 s. Site stayed up the whole time | ~30 s |
| 2 | Load test | `ab -t 300 -c 100` against the ALB for 5 min | CPU > 50% → scale out to 3–4 tasks | ~221,000 requests (~735/s). Peak CPU 11.9%. 4 × 5xx. No scaling: it wasn't needed | n/a |
| 3 | Break the health check | Changed the target group health check path from `/` to `/broken` in the console | Targets unhealthy → alarm email | Both targets unhealthy (404). Alarm email after ~4 min. Site stayed up (ALB fails open). ECS kept replacing tasks that failed the same check | Needed a fix (see drift drill) |
| 4 | Drift drill | Ran `terraform plan` with the console change still in place, then `terraform apply` | Plan shows the drift, apply fixes it | Plan showed only `path "/broken" -> "/"` (0 add, 1 change, 0 destroy). Apply took 1 s. Alarm went ALARM → OK 8 min after it fired | ~4 min after apply |
| 5 | Zero tasks | Set desired tasks to 0 in the console, then `ab -t 180 -c 5` | ALB returns 503 → 5xx alarm | 16,950 of 16,950 requests got 503 from the ALB itself (`Server: awselb/2.0`). 5xx alarm email after ~5 min. Unhealthy-hosts alarm stayed quiet. Autoscaling did not bring tasks back | Manual fix (desired tasks → 2) |

## Details

### 1. Stop a task

ECS service events:

```
21:10:58  deregistered 1 targets, began draining connections on 1 task
21:10:59  has started 1 tasks
21:11:18  registered 1 targets in the target group
21:11:27  has reached a steady state
```

The dashboard didn't show the dip at first: the widgets average over 5 minutes and CloudWatch data arrives 1–3 minutes late. It later showed Healthy Hosts dropping to 1.8 (5-minute average).

### 2. Load test

| Metric | Value |
|---|---|
| Requests | 133,556 + 87,360 in two 5-minute periods |
| Throughput | ~735 requests/s |
| Peak CPU (1-min max) | 11.9% |
| Average CPU on the dashboard | ~4.5% |
| 5xx errors | 4 (below the alarm threshold of 5/min) |
| Tasks | stayed at 2 |

nginx serving a static page is very cheap, so the autoscaling target (50% CPU) was never reached. Expect this to change when the real app replaces nginx in M3.

Found a dashboard bug: the Requests widget showed "1" instead of ~133k because widgets use `Average` by default. Counts need `stat = "Sum"`.

### 3. Broken health check

```
22:40  health check path changed to /broken
       targets → unhealthy, reason: health checks failed with code 404
22:43  ECS starts stopping and replacing tasks that fail ELB health checks
22:44  ALARM: tickerops-dev-unhealthy-hosts
```

- **ALB fail open:** when every target is unhealthy, the ALB sends traffic to all of them anyway. nginx was fine, so users saw no errors.
- **Restart loop:** ECS replaced the "unhealthy" tasks, but the new tasks failed the same check. Replacing tasks can't fix a broken health check.

### 4. Drift drill

```
~ health_check {
    ~ path = "/broken" -> "/"
}
Plan: 0 to add, 1 to change, 0 to destroy.
```

```
22:44  ALARM email
~22:48 terraform apply (1 changed, 1 s)
22:49  first healthy datapoint
22:52  OK email
```

The ECS service did not appear in the plan, even though tasks had been replaced: `lifecycle { ignore_changes = [desired_count] }` works as intended.

### 5. Zero tasks

5xx count per minute (`HTTPCode_ELB_5XX_Count`, all of them 503):

```
22:58  2,752
22:59  5,572
23:00  5,535
23:02:50  ALARM: tickerops-dev-alb-5xx-errors
```

- The unhealthy-hosts alarm stayed quiet: zero tasks means zero *unhealthy* tasks. It went to INSUFFICIENT_DATA instead, because there were no targets to report on.
- **Autoscaling did not recover** even though `min_capacity = 2`. Target tracking only acts when its CPU alarms fire, and zero tasks report no CPU.
- **Terraform did not see it either.** `terraform plan` showed no changes because `desired_count` is in `ignore_changes`.
- Fixed by setting desired tasks back to 2 in the console. Service steady, site HTTP 200.

## Lessons

1. **Each alarm covers a different failure.** Unhealthy hosts catches broken tasks; ALB 5xx catches users seeing errors (including no tasks at all). Neither covers the other.
2. **Detection takes 4–5 minutes** with 60-second periods × 2 evaluation periods plus CloudWatch's wait for late data.
3. **`ignore_changes` is a trade-off.** It stops Terraform fighting the autoscaler, but Terraform can't detect or fix that setting any more.
4. **Autoscaling is not a safety net for 0 tasks.** Protection has to come from IAM (only the pipeline changes prod), CloudTrail + EventBridge alerts on `UpdateService`, and an alarm on running task count.
5. **Pick the right statistic.** `Sum` for counts, `Average`/`Maximum` for CPU.

## Follow-ups

- [ ] Dashboard: `stat = "Sum"` on the Requests widget
- [ ] Alarm on running task count < 2 (needs Container Insights)
- [ ] Re-run the load test against the real app in M3 to see scale-out
