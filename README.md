# Kubernetes Production Deployment Warfare

A hands-on, incident-driven learning path for Kubernetes deployment strategies, GitOps, Argo CD, and production operations.

The goal is not to memorize YAML. The goal is to build the mental models, operational judgment, and evidence-based reasoning expected of strong Senior, Staff, and Principal Platform Engineers.

## Learning loop

1. Understand the production problem and vocabulary.
2. Visualize architecture and control/data flows.
3. Predict behavior before running commands.
4. Implement in a reproducible local environment.
5. Observe Kubernetes and application evidence.
6. Break safely and diagnose failures.
7. Defend design choices and trade-offs.
8. Document evidence so others can reproduce it.

No quiz answer is revealed before the learner commits to a choice.

## Running scenario

We will evolve a production-like payment platform containing an API, cache, two database instances/roles, and a three-broker Kafka cluster. We will study how rollouts interact with dependencies under stress. The local kind lab is a simulation; it does not reproduce production availability, storage durability, or real failure domains.

## Prerequisites

- Windows PowerShell
- Docker usable by kind
- kubectl and kind
- GitHub account
- Basic command-line familiarity

The first mission uses the existing kind cluster named kind-prod-sim. Adapt commands if your cluster differs.

## Mission roadmap

| Mission | Focus | Status |
|---|---|---|
| 001 | Install and inspect Argo CD | In progress |
| 002 | Connect Git and deploy the first application | Planned |
| 003 | Desired state, live state, drift and self-healing | Planned |
| 004 | RollingUpdate mechanics and availability budgets | Planned |
| 005 | Recreate strategy and outage trade-offs | Planned |
| 006 | Blue/green delivery | Planned |
| 007 | Canary delivery and progressive analysis | Planned |
| 008 | Stateful dependencies, disruption and rollout coordination | Planned |
| 009 | Incident simulations and Principal-level design reviews | Planned |

## Repository layout

- docs/: shared concepts and architecture
- missions/: step-by-step labs
- payflow/: evolving sample workload
- failure-scenarios/: controlled incident exercises
- observability/: metrics, logs and diagnosis
- cleanup/: resource cleanup procedures

## Safety and security

- Never commit passwords, tokens, kubeconfigs, private keys, or unredacted terminal output.
- Use disposable namespaces and non-production data.
- Review resource requests and limits before applying manifests to a laptop cluster.
- Verify the active context before destructive commands.
- A namespace is an organizational and policy boundary, not a complete security boundary.
- Argo CD installation includes cluster-scoped resources; placing namespaced workloads in argocd does not confine every permission to that namespace.

## Start here

[Mission 001 — Install and inspect Argo CD](missions/001-argocd-installation/README.md)

## What expertise means here

Completing the missions does not automatically make someone a Principal Engineer. The course develops repeatable skills: explaining controller behavior, forecasting rollout impact, reasoning about dependency capacity, handling failures safely, measuring outcomes, and communicating trade-offs with evidence.