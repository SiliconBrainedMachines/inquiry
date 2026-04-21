---
id: software-design
title: "KA 2: Software Design"
date: 2026-04-21
status: active
tags: [swebok, design]
author: SOCRATES
---

# KA 2: Software Design

## Definition

Software design is the process of defining the architecture, components, interfaces, and other characteristics of a system to satisfy specified requirements. It transforms *what* the system must do into *how* it will do it.

## Key Topics

### Design Fundamentals

- **General design concepts** — abstraction, coupling, cohesion, decomposition, encapsulation
- **Design as a wicked problem** — Rittel & Webber (1973): design problems cannot be definitively formulated; each solution attempt changes the understanding of the problem
- **Sufficiency, completeness, and primitiveness** — a design should be sufficient to satisfy requirements, complete in covering all aspects, and primitive (not decomposable into simpler designs)

### Key Design Concepts

- **Separation of concerns** — dividing a system so each part addresses a single concern
- **Information hiding** — Parnas (1972): modules should hide design decisions likely to change
- **Coupling and cohesion** — minimizing inter-module dependencies, maximizing intra-module relatedness

### Software Architecture

The set of structures needed to reason about the system:

- **Architectural styles** — layered, pipe-and-filter, event-driven, state-machine, microservices
- **Architecture as decisions** — architecture is the set of design decisions that are hard to change
- **Views** — logical, process, development, physical (Kruchten 4+1)

### Detailed Design

- **Design patterns** — reusable solutions to recurring problems (GoF, POSA)
- **State machines** — modeling behavior through states and transitions
- **Interface design** — contracts between components

### Design Quality Analysis

- **Design reviews** — inspections, walkthroughs
- **Metrics** — coupling metrics, complexity (cyclomatic), cohesion measures
- **Formal methods** — mathematical verification of design properties

## Relationship to Other KAs

- Receives input from **Requirements (KA 1)**
- Feeds into **Construction (KA 3)** as implementation guidance
- **Quality (KA 10)** provides evaluation criteria for designs
- **Models and Methods (KA 9)** provides modeling notations

## Key Insight

SWEBOK distinguishes *architectural design* (macro structure) from *detailed design* (micro structure). Architecture constrains construction; detailed design guides it. A state machine is an architectural pattern when it defines system behavior, and a detailed design artifact when it specifies component transitions.
