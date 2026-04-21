---
id: software-configuration-management
title: "KA 6: Software Configuration Management"
date: 2026-04-21
status: active
tags: [swebok, scm]
author: SOCRATES
---

# KA 6: Software Configuration Management

## Definition

Software Configuration Management (SCM) is the discipline of identifying, organizing, and controlling modifications to the software being built. It ensures that changes are introduced systematically and that the integrity of the product is maintained at every point.

IEEE 828 is the standard for SCM planning.

## Key Topics

### Management of the SCM Process

- **Organizational context** — SCM interacts with project management, quality assurance, and development
- **Constraints and guidance** — policies, procedures, standards that govern how changes flow
- **SCM plan** — the document describing what is controlled, how changes are approved, and who is responsible

### Software Configuration Identification

The act of defining what constitutes a **Configuration Item (CI)**:

- Source code files, documents, test suites, build scripts, configuration files
- **Baselines** — approved snapshots of the configuration at a point in time (e.g., "v1.0 release baseline")
- **Naming and versioning** — each CI must be uniquely identifiable

### Software Configuration Control

The process of managing changes to identified CIs:

- **Change request** — a documented proposal to modify a CI (GitHub issue = change request)
- **Change evaluation** — assessing impact, cost, and risk
- **Change approval** — authority to approve (maintainer, Change Control Board, CODEOWNERS)
- **Change implementation** — the actual modification (branch, commit, PR)
- **Change verification** — confirming the change does what it should (CI/CD, tests, review)

### Software Configuration Status Accounting

Tracking and reporting the status of CIs and change requests:

- What is the current version of each CI?
- What changes are pending, approved, or rejected?
- What is the history of changes to a given CI?

### Software Configuration Auditing

Verifying that the product conforms to its specification and that the configuration management process was followed:

- **Functional Configuration Audit (FCA)** — does the product match its requirements?
- **Physical Configuration Audit (PCA)** — does the delivered product match the approved design documentation?

### Software Release Management

The process of building, packaging, and distributing software:

- **Build reproducibility** — given the same inputs, produce the same output
- **Release identification** — version numbers, tags, changelogs
- **Distribution** — install scripts, package registries, artifact stores

## Relationship to Other KAs

- Tracks changes to artifacts from **all other KAs**
- **Process (KA 8)** defines when SCM activities occur
- **Quality (KA 10)** relies on SCM to ensure auditability
- **Management (KA 7)** uses SCM status for project visibility

## Key Insight

SCM is not "using Git." Version control is one tool within SCM. The full discipline includes change control (who approves), status accounting (what changed), auditing (does the product match the plan), and release management (how to deliver). A project that uses Git but has no change control process is doing version control without SCM.
