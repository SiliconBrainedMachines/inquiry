---
id: software-construction
title: "KA 3: Software Construction"
date: 2026-04-21
status: active
tags: [swebok, construction]
author: SOCRATES
---

# KA 3: Software Construction

## Definition

Software construction is the detailed creation of working software through coding, verification, unit testing, integration testing, and debugging. It is the central activity that produces the artifact — the executable system.

## Key Topics

### Construction Fundamentals

- **Minimizing complexity** — the primary technical imperative (McConnell). Code should be written for humans to read, not just machines to execute
- **Anticipating change** — designing code so that likely changes are localized
- **Constructing for verification** — writing code that can be tested (testability as a construction concern, not just a testing concern)

### Managing Construction

- **Construction planning** — ordering the implementation of components
- **Construction measurement** — lines of code, complexity, defect density
- **Construction models** — iterative, incremental, test-driven

### Practical Considerations

- **Construction design** — micro-level design decisions made during coding (variable naming, loop structure, error handling)
- **Construction languages** — choice of language affects construction constraints
- **Coding standards** — team conventions for style, naming, documentation
- **Integration** — combining components into a working system. Approaches: big-bang, incremental, continuous

### Construction Technologies

- **API design and use** — programming against interfaces
- **State-based construction** — using state machines to drive implementation logic
- **Error handling** — defensive programming, assertions, exception strategies
- **Code reuse** — libraries, frameworks, generics

## Relationship to Other KAs

- Implements decisions from **Design (KA 2)**
- Produces artifacts verified by **Testing (KA 4)**
- Artifacts tracked by **Configuration Management (KA 6)**
- Quality standards from **Quality (KA 10)** apply during construction

## Key Insight

SWEBOK positions construction as *not just coding*. It includes the construction design decisions, the verification during construction (unit tests, assertions), and the integration strategy. A developer making a commit is simultaneously constructing, designing at the micro level, and verifying.
