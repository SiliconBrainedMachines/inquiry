---
id: software-engineering-management
title: "KA 7: Software Engineering Management"
date: 2026-04-21
status: active
tags: [swebok, management]
author: SOCRATES
---

# KA 7: Software Engineering Management

## Definition

Software Engineering Management involves the planning, coordination, measurement, monitoring, and control of software engineering activities. It applies management principles to ensure that software is delivered effectively and predictably.

## Key Topics

### Initiation and Scope Definition

- **Determination of scope** — defining what the project will and will not do
- **Feasibility analysis** — technical, operational, economic
- **Process for review and revision** — scope changes must be controlled, not ad hoc

### Software Project Planning

- **Process planning** — selecting and tailoring the development process
- **Effort, schedule, and cost estimation** — COCOMO, function points, expert judgment
- **Resource allocation** — people, tools, infrastructure
- **Risk management** — identification, analysis, mitigation, monitoring
- **Quality management planning** — defining quality objectives and how to measure them

### Software Project Enactment

- **Implementation of plans** — executing what was planned
- **Software acquisition and supplier management** — managing external dependencies
- **Monitoring and controlling** — tracking progress against plans, taking corrective action
- **Reporting** — status reports, metrics dashboards

### Review and Evaluation

- **Determining satisfaction of requirements** — did we build what was asked?
- **Reviewing and evaluating performance** — was the process effective?
- **Post-mortem / retrospective** — what was learned? What should change?

### Software Engineering Measurement

- **Process measurement** — cycle time, defect injection rate, review effectiveness
- **Product measurement** — code complexity, test coverage, defect density
- **Measurement programs** — GQM (Goal-Question-Metric) framework

## Relationship to Other KAs

- Governs activities across **all other KAs**
- **Process (KA 8)** defines the framework; Management enacts it
- **Quality (KA 10)** provides measurement criteria
- **Configuration Management (KA 6)** provides status data for monitoring

## Key Insight

SWEBOK separates *process* (KA 8 — the abstract model) from *management* (KA 7 — the enactment of that model in a specific project). A process says "there shall be a review phase." Management says "the review happens Thursday, Alice leads it, and we measure defect escape rate." The process is reusable; the management is instance-specific.
