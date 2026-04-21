---
id: software-quality
title: "KA 10: Software Quality"
date: 2026-04-21
status: active
tags: [swebok, quality]
author: SOCRATES
---

# KA 10: Software Quality

## Definition

Software quality is the degree to which a software product satisfies stated and implied needs when used under specified conditions. KA 10 covers the concepts, techniques, and tools for ensuring and measuring quality in both the process and the product.

## Key Topics

### Software Quality Fundamentals

- **Quality as conformance** — the product meets its specification
- **Quality as fitness for use** — the product satisfies user needs (Juran)
- **Quality culture** — organizational attitude toward quality; cannot be tested in at the end
- **Cost of quality** — prevention costs, appraisal costs, failure costs (internal and external)

### Software Quality Management Processes

- **Software Quality Assurance (SQA)** — planned activities to ensure the development process produces quality results. SQA monitors the *process*, not the product
- **Verification** — "are we building the product right?" (does it conform to its specification?)
- **Validation** — "are we building the right product?" (does it satisfy user needs?)

### Practical Quality Considerations

- **Defect characterization** — classifying defects by type, severity, origin phase
- **Quality measurement** — metrics for product quality (defect density, MTBF) and process quality (review effectiveness, test coverage)
- **Statistical techniques** — control charts, Pareto analysis, root cause analysis

### Quality Standards

| Standard | Focus |
|----------|-------|
| **ISO/IEC 25010** | Product quality model (8 characteristics: functional suitability, performance efficiency, compatibility, usability, reliability, security, maintainability, portability) |
| **ISO/IEC 25023** | Quality measurement |
| **ISO/IEC 12207** | Software lifecycle processes (quality aspects) |
| **CMMI** | Process maturity as a quality indicator |

### Verification & Validation Techniques

- **Reviews** — inspections, walkthroughs, peer review
- **Static analysis** — analyzing code without executing it (linters, type checkers)
- **Dynamic analysis** — testing, profiling, runtime verification
- **Formal verification** — mathematical proof of correctness

## Relationship to Other KAs

- Applies to outputs of **all other KAs**
- **Testing (KA 4)** is a primary V&V technique
- **Process (KA 8)** is evaluated for quality via assessment
- **SCM (KA 6)** provides the infrastructure for auditing quality

## Key Insight

SWEBOK makes a fundamental distinction: **SQA monitors process quality; V&V evaluates product quality**. A project can have excellent SQA (every step followed correctly) and still produce a defective product if the process itself is wrong. Conversely, a chaotic process can occasionally produce a quality product — but not reliably. Quality requires both.
