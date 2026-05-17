# Philo SophIA — Failure Taxonomy as Inverted Index

**Source:** Original analysis by ccisnerdev, exploring problems of AI communication and their relationship to philosophical traditions.

---

## Overview

A formal taxonomy of human-LLM communication failures (6 categories, 25 failure types) maps directly to philosophical disciplines. This taxonomy serves as the book's **inverted index** — the technical reader enters through the problem, discovers the philosopher, and obtains the tool.

## Mapping: AI Failures → Philosophical Disciplines

| Failure Category | Philosophical Discipline | Key Philosophers |
|-----------------|------------------------|-----------------|
| I. Prompt formulation (subespecification, vagueness, overload, hidden presuppositions) | Rhetoric & Dialectic | Aristotle, Socrates |
| II. Semantic (ambiguity, polysemy, referential indetermination, category error) | Philosophy of Language | Wittgenstein, Frege, Ryle |
| III. Pragmatic (intention-literality mismatch, spurious inference, excessive accommodation) | Pragmatics & Hermeneutics | Austin, Searle, Grice, Gadamer |
| IV. Logical (invalid inference, fallacies, contradictions, unjustified abductive leaps) | Formal Logic | Aristotle (Sophistical Refutations) |
| V. Epistemic (hallucination, overconfidence, premature closure, plausibility without verification) | Epistemology | Socrates, Hume, Plato (doxa vs episteme) |
| VI. Philosophical-conceptual (reification, simulation vs comprehension, ontological indetermination) | Ontology & Philosophy of Mind | Whitehead, Searle, Carnap |

## Implication for Book Structure

Each chapter opens with a documented technical failure of AI, then reveals the philosopher who studied it centuries earlier. The full taxonomy can serve as an appendix for quick reference.

## Detailed Taxonomy

### I. Prompt Formulation Failures

1. **Subespecification** — Query lacks sufficient constraints, context, domain, objective, or output criteria. Effect: model fills gaps with plausible inferences, increasing hallucination risk.
2. **Directive vagueness** — Instruction expresses diffuse intent without delimiting scope, technical level, format, depth, or success criteria. Effect: generic, misaligned, or overly interpretive responses.
3. **Objective overload** — Single prompt contains multiple tasks, abstraction levels, or non-hierarchized goals. Effect: loss of focus, omissions, internal contradictions.
4. **Hidden presupposition** — Question incorporates unverified or conceptually defective premises. Effect: model may accept the erroneous frame and reason on false foundations.

### II. Semantic Failures

5. **Lexical ambiguity** — A term admits multiple meanings. Effect: arbitrary or contextually incorrect meaning selection.
6. **Referential indetermination** — Unclear what entity a pronoun, name, event, period, or concept refers to. Effect: incorrect referent substitution and off-target response.
7. **Technical-everyday polysemy** — Specialized and ordinary senses of the same word are mixed. Effect: pseudo-explanations correct on surface but semantically inadequate.
8. **Conceptual vagueness** — Concepts used lack sharp boundaries or explicit operational criteria. Effect: apparently reasonable but not rigorously evaluable responses.
9. **Category error** — Properties of one conceptual class attributed to an incompatible one. Effect: semantically malformed but verbally fluent reasoning.

### III. Pragmatic Failures

10. **Intention-literality mismatch** — Model responds to the literal form of the prompt but not the user's actual purpose. Effect: locally correct, globally defective response.
11. **Spurious pragmatic inference** — Model "assumes" context, intention, or constraints not made explicit. Effect: interpretive overfill and conversational drift.
12. **Implicit context dependency** — Interaction requires shared knowledge not explicit in the conversation. Effect: unstable or erroneous interpretation between turns.
13. **Excessive user-frame accommodation** — Model adopts the user's conceptual framing without sufficient friction. Effect: reinforcement of errors, biases, or defective premises. (Connects to sycophancy and conversational alignment failures.)

### IV. Logical and Inferential Failures

14. **Invalid inference** — Conclusion does not follow from premises, though the text appears coherent.
15. **Reproduced fallacy** — Model replicates or fails to detect: hasty generalization, false dilemma, circularity, false cause, non sequitur, improper appeal to authority, composition/division.
16. **Latent contradiction** — Response contains internal incompatibilities undetected during generation.
17. **Unjustified abductive leap** — Model chooses the linguistically most plausible explanation without sufficient evidence. Effect: persuasive but unjustified response.

### V. Epistemic Failures

18. **Hallucination** — Production of unsupported, invented, or incorrectly inferred content presented with appearance of validity. Subtypes: factual (invents facts), bibliographic (invents sources/citations), procedural (invents steps, APIs, functions, norms), contextual (responds as if possessing context not given).
19. **Epistemic overconfidence** — Model expresses high certainty without sufficient basis.
20. **Premature uncertainty closure** — Instead of making ambiguity or information insufficiency explicit, the model decides on an interpretation.
21. **Plausibility without verification** — Response optimized to sound reasonable, not to be validated. (Structural in LLMs: generation based on probabilistic sequence continuation, not native access to truth.)

### VI. Philosophical-Conceptual Failures

22. **Semantic reification** — A linguistic abstraction is treated as if it were an ontologically clear entity.
23. **Confusion between simulation and comprehension** — Verbal fluency is interpreted as strong semantic understanding.
24. **Ontological indetermination** — Question presupposes entities, categories, or distinctions that are not well-defined.
25. **Pseudo-question** — Formulation appears interrogative but lacks clear truth conditions or resolution conditions.

## Structural Cause in LLMs

These failures do not stem solely from bad prompts. They also derive from structural properties of LLMs:

- Model statistical regularities of language, not guaranteed formal meaning
- Prioritize plausible continuations
- Lack robust semantic or referential grounding by default
- Operate with finite context and imperfect history compression
- Can exhibit apparent reasoning without robust logical validity
- Are typically optimized for conversational utility, not strict abstention under uncertainty
