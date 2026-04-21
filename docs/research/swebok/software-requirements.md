---
id: software-requirements
title: "KA 1: Software Requirements"
date: 2026-04-21
status: active
tags: [swebok, requirements]
author: SOCRATES
---

# KA 1: Software Requirements

## Definition

Software requirements express the needs and constraints of a software product that contribute to the solution of a real-world problem. They are the bridge between a problem (an indeterminate situation) and a designed solution.

## Key Topics

### Requirements Fundamentals

- **Product vs. process requirements** — what the system does vs. how it is built
- **Functional vs. non-functional** — capabilities vs. constraints (performance, security, usability)
- **Emergent properties** — requirements that arise from the system as a whole, not individual components

### Requirements Elicitation

The act of discovering requirements from stakeholders and the environment. Techniques include:

- Interviews and observation
- Prototyping and scenarios
- Facilitated workshops
- **Abductive reasoning** — inferring likely explanations from observed symptoms (cf. Peirce's logic of discovery)

SWEBOK notes that elicitation is not mere gathering — it requires active interpretation of incomplete, conflicting, and evolving information.

### Requirements Analysis

Transforming elicited information into structured, analyzable form:

- Detecting conflicts and inconsistencies
- Classifying and prioritizing requirements
- Feasibility analysis
- **Conceptual modeling** — creating representations of the problem domain

### Requirements Specification

Documenting requirements in a form that is verifiable and unambiguous. Standards include IEEE 830 (SRS template). Key quality attributes of specifications: correct, unambiguous, complete, consistent, ranked, verifiable, modifiable, traceable.

### Requirements Validation

Confirming that the specification accurately represents stakeholder needs. Techniques: reviews, prototyping, model validation, acceptance tests.

## Relationship to Other KAs

- Requirements feed into **Design (KA 2)** as constraints
- **Testing (KA 4)** validates that requirements are met
- **Configuration Management (KA 6)** tracks requirement changes over time
- **Process (KA 8)** defines when and how requirements activities occur

## Key Insight

SWEBOK treats requirements as a *process*, not a *phase*. Requirements evolve throughout the project lifecycle — they are not "done" before design begins.
