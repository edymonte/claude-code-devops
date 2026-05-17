# ADR/RFD Template - Architecture Decision Records

**ADR = Architecture Decision Record**  
**RFD = Request for Discussion**

This is a structured template for documenting important architectural decisions. Use this pattern for any change that impacts infrastructure, technology, or project patterns.

---

## 📋 How to Use This Template

1. Copy this template
2. Fill each section as described
3. Submit as PR for review (Spec-First)
4. After approval, implement the solution
5. Document in `docs/adr/` with a sequential number

**Naming**: `adr-NNN-decision-title.md`  
Example: `adr-001-add-hpa-for-scaling.md`

---

## 🔴 1. PROBLEM - What is broken?

### What goes in

- **Observable symptom**: What do you see that's wrong?
- **Measurable impact**: How big is the problem? (latency +50ms, downtime 15min, etc)
- **Scope**: Which part of the system is affected?

### Protects against

What assertion do you want to guarantee going forward?  
Format: *"are we solving the right problem?"*

### Example Kube-News

```
Symptom: Single pod cannot absorb traffic spike
Impact: 30% of requests timeout during peak hours
Scope: kube-news app, does not affect postgres

Protects against: "someone improvises on top" - we want informed decision, not hotfix
```

---

## 🟢 2. PROPOSED SOLUTION - What will we do?

### What goes in

- **Technical approach at high level**: What's the big idea?
- **Concrete changes (deltas)**: Which files/components change?
- **Impact map**: Who else is affected?

### Protects against

Which risk does this solution eliminate?  
Format: *"solution without design = improvisation on the fly"*

### Example Kube-News

```
Approach: Add HPA (Horizontal Pod Autoscaler) based on CPU
Deltas:
  - Create HPA manifest (k8s-bo/hpa.yml)
  - Update deployment with resource requests
  - Configure monitoring for CPU target (70%)
Impact map: Infra needs budget for more pods; monitoring needs to track replicas

Protects against: Solution without design - avoids improvisation during deploy
```

---

## 🟠 3. ALTERNATIVES - What was considered and rejected?

### What goes in

- 2-3 viable alternatives
- Why each was rejected

### Protects against

Avoids: *"did you consider X? in review"*

### Example Kube-News

```
1. KEDA (rejected: unnecessary complexity)
2. Increase pod size (rejected: doesn't solve availability)
```

---

## 🟣 4. RISKS - What can go wrong?

### What goes in

- **Technical risks**: Bugs, performance, incompatibilities
- **Mitigations**: How will you avoid each risk?
- **Post-deploy alert signals**: When do you need rollback?

### Protects against

Surprise in production

### Example Kube-News

```
Risk: Aggressive HPA causes thrashing (rapid scale up/down cycles)
Mitigation: stabilizationWindowSeconds=300 (wait 5min before deciding)

Risk: Resource requests too low → new replicas still slow
Mitigation: Load test before deploy; validate latency at 5 replicas

Alert signal: If CPU goes above 80% or requests still timeout
```

---

## 📊 Complete Structure for Documentation

```markdown
# ADR-NNN: [Decision Title]

**Status**: Proposed / Approved / Implemented / Rejected  
**Date**: YYYY-MM-DD  
**Author**: Name  
**Reviewer**: Name  

---

## 1. PROBLEM

### What goes in
[Symptom, impact, scope]

### Protects against
[Assertion we want to guarantee]

### Example from Project
[Specific context]

---

## 2. PROPOSED SOLUTION

### What goes in
[Approach, deltas, impact map]

### Protects against
[Risk eliminated]

### Example from Project
[Specific implementation]

---

## 3. ALTERNATIVES

### What goes in
[Alternatives 1, 2, 3 with rejection justification]

### Protects against
[Common objections avoided]

### Example from Project
[Comparative analysis]

---

## 4. RISKS

### What goes in
[Technical risks + mitigations + alert signals]

### Protects against
[Production surprise]

### Example from Project
[Specific scenarios]

---

## 📝 Additional Notes

- Implementation timeline
- External dependencies
- Costs (if applicable)
- Links to related documentation

---

Each section protects against a known failure mode.
```

---

## 🎯 When to Use This Template

Use **ADR** for decisions that:
- ✅ Affect multiple components
- ✅ Need approval before implementing
- ✅ Have financial or operational impact
- ✅ Will be revisited in the future

**Don't use** for:
- ❌ Simple bug fixes
- ❌ Dependency version updates
- ❌ Internal refactorings without external impact

---

## 📁 Organization in Repository

```
docs/
├── adr/                                    # ADR directory
│   ├── adr-001-initial-k8s-setup.md
│   ├── adr-002-add-monitoring-stack.md
│   └── adr-NNN-decision-title.md
├── adr-template.md                         # This file
└── README.md
```

---

## ✏️ Complete Example: ADR for Kube-News

```markdown
# ADR-002: Add HPA for Automatic Scaling

**Status**: Proposed  
**Date**: 2026-05-17  
**Author**: DevOps Team  

## 1. PROBLEM

### What goes in
Single pod (kube-news-deployment with replicas=1) cannot absorb traffic spikes.
- Symptom: Latency increases 200ms during peaks
- Impact: 25-30% of requests timeout
- Scope: kube-news application, does not affect postgres

### Protects against
"Are we solving the right problem?" - we want to scale horizontally, not vertically.

### Example
During peak hours (18:00-20:00), 500 requests/min, but 1 pod only handles 200/min.

---

## 2. PROPOSED SOLUTION

### What goes in
Implement HPA (Horizontal Pod Autoscaler) based on CPU:
- Minimum: 1 replica
- Maximum: 5 replicas
- Target CPU: 70%

Deltas:
- Create `k8s-bo/hpa.yml`
- Update `k8s-bo/app-deployment.yml` with resource requests
- Configure Prometheus scrape at 70% CPU target

### Protects against
Solution without design = improvisation on deploy day.

---

## 3. ALTERNATIVES

1. **KEDA** (rejected: overkill for this case)
2. **Increase requests/limits** (rejected: doesn't solve, just delays)
3. **VPA** (rejected: requires pod restart)

---

## 4. RISKS

**Risk**: Scaling thrashing (rapid scale up/down cycles)
- Mitigation: stabilizationWindowSeconds=300
- Alert: CPU fluctuating 60-80% continuously

**Risk**: New replicas initialize slowly
- Mitigation: readinessProbe validated; initialDelaySeconds=10
- Alert: Latency doesn't improve even with 5 pods

---

## Implementation

Timeline: 1-2 days
Dependencies: None
Cost: ~$50/month (additional resources)
```

---

## 📚 References

- Google's [Design Docs](https://www.industrialempathy.com/posts/design-docs-at-google/) (similar approach)
- Kubernetes [HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- Industry-standard RFC Template

---

**Created**: 2026-05-17  
**Usage**: Foundation for architectural decisions in Kube-News project
