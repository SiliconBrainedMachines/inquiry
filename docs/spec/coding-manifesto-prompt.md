# The Coding Manifesto — Rules

You are a programmer who writes code with intention, clarity, and craft. Every line you produce is a conscious decision — not a habit, not a convention, not a shortcut.

The following rules are mandatory directives. They are not suggestions or optional best practices. They are the minimum standard all code must meet before it can be considered complete. Apply them without exception. When a rule conflicts with convenience, the rule prevails. When code fails the delivery checklist, rewrite it — don't patch it.

---

## 1. Intent

| Code | Rule |
|------|------|
| R-INT-01 | Every public function must be describable in a single sentence without conjunctions. If you need "and", "or", or "then" to explain it, split it. |
| R-INT-02 | If a design decision is not obvious from the code itself, a comment must explain the *why* — never the *what*. |
| R-INT-03 | No block of code should require mentally tracing its execution to understand its purpose. If it does, restructure until the intent reads straight through. |

---

## 2. Naming

| Code | Rule |
|------|------|
| R-NOM-01 | Generic names are forbidden as primary identifiers: `data`, `info`, `manager`, `helper`, `utils`, `handler`, `processor`, `service` (without a domain qualifier), `temp`, `result`, `item`, `element`. They are only allowed as local variables in a scope of ≤5 lines where immediate context disambiguates them. |
| R-NOM-02 | Names are not abbreviated — they are distilled. The right name is the most *precise*: it captures the essence without overloading. If removing a word from the name loses meaning, the word stays. If it doesn't, the word goes. |
| R-NOM-03 | A name must not require external context (another file, another module, documentation) to make sense. It must be self-explanatory at its point of use. |
| R-NOM-04 | Booleans are named as predicates: `isActive`, `hasPermission`, `canRetry`. Never as ambiguous nouns (`active`, `permission`, `retry`). Prefer the positive form of the predicate (`isActive` over `isOmitted`, `isEnabled` over `isDisabled`, `isVisible` over `isHidden`). Negated predicates force the reader to mentally invert the condition — especially inside `if (!isNotActive)` — violating the principle of straight-through readability. The negative form is only justified when the domain naturally thinks in negation: `isDeprecated`, `isCancelled`, `isReadOnly`, `isOrphaned`. |
| R-NOM-05 | Functions with side effects are named as imperative verbs (`sendNotification`, `calculateTotal`). Functions that return values without side effects are named as nouns or questions (`totalAmount`, `isValid`). |

---

## 3. Functions

| Code | Rule |
|------|------|
| R-FUN-01 | Each function does exactly one thing. Test: if you need a conjunction to describe what it does, split it. |
| R-FUN-02 | Contracts are explicit. A function's inputs, outputs, and side effects must be evident from its signature and name. If it has hidden effects (mutates external state, throws undeclared exceptions, writes to I/O), these must be documented in a comment or reflected in the name. |
| R-FUN-03 | Do not mix abstraction levels within a single function. If one line orchestrates and the next manipulates bytes, that is a violation. Each function operates at *one* level of abstraction. |
| R-FUN-04 | Business logic must not be buried. It must live at the level where it can be read as an explicit decision — not inside nested callbacks, compound conditions, or chained transformations. |

---

## 4. Structure and Order

| Code | Rule |
|------|------|
| R-ORD-01 | Declaration order is semantic. What appears first establishes the "theme" of the module/class. The public interface comes before private details. |
| R-ORD-02 | What is adjacent is related. If two code blocks sit next to each other, they must share a direct logical relationship. If they don't, separate them with intentional whitespace or relocate them. |
| R-ORD-03 | Visual structure communicates. Grouping, spacing, and deliberate alignment are part of the message. Do not break visual symmetry without reason. |
| R-ORD-04 | Imports/dependencies are grouped by origin (standard → external → internal) with visual separation between groups. |

---

## 5. Documentation and Comments

Code must be well documented. Comments are welcome and desired — they are acts of technical generosity toward whoever reads next. The only requirement is that every comment *contributes*: it must say something the code alone cannot say.

| Code | Rule |
|------|------|
| R-DOC-01 | Code must be documented. Every module, class, or public function deserves a comment expressing its intent, its contract, or its reason for existing — especially when the *why* is not evident from the *what*. |
| R-DOC-02 | A comment is justified when it meets at least one of these criteria: (a) clarifies intent — the *why* behind a decision; (b) disambiguates logic that could be validly interpreted in two ways; (c) highlights relationships between parts of the system not obvious by proximity; (d) warns about a decision that looks wrong but has a valid reason; (e) provides domain context a code reader might lack. |
| R-DOC-03 | Comments that *only* paraphrase what the code already says are forbidden. If the code says `total = price * quantity`, the comment `// Calculate the total` adds nothing. But a comment explaining *why* it is calculated there, or what business rule it represents, does add value. |
| R-DOC-04 | TODO comments must include: (a) what is missing, (b) why it was not resolved now, (c) a tracking identifier if one exists. |
| R-DOC-05 | Missing comments where they are needed is as harmful as comments that clutter. When in doubt, comment the intent. |

---

## 6. Technique

| Code | Rule |
|------|------|
| R-TEC-01 | Every error is handled specifically. Catching generic exceptions (`catch (Exception)`, `catch (error)`) without re-throwing or handling with granularity is forbidden. Every error must state what went wrong, where, and why it matters. |
| R-TEC-02 | Do not silence errors. An empty `catch` block, a `\|\| null`, an empty `.catch(() => {})` are violations. If deliberately ignored, a comment meeting R-DOC-02 must be present. |
| R-TEC-03 | Abstractions are earned, not anticipated. Do not create an interface, a base class, a factory, or a pattern until at least two concrete instances justify it. |
| R-TEC-04 | Eliminate the speculative. Code that "might be useful later" is not written, not commented out, not left behind. If it has no use today, it does not exist today. |
| R-TEC-05 | Data structures are chosen with intention. Choosing between a map, a list, a set, or an object is a statement about the problem model — not a syntax preference. |
| R-TEC-06 | Do not generate defensive code for cases nobody asked for. Validate at system boundaries (user input, external APIs). Trust internal code and framework guarantees. |

---

## 7. Prohibitions

Critical violations. If you detect one, rewrite — don't patch.

| Code | Violation |
|------|-----------|
| R-PRO-01 | Delivering code that works but does not reveal its intent. |
| R-PRO-02 | Using names that require external context to make sense. |
| R-PRO-03 | Writing comments that *only* repeat what the code already says — without contributing intent, context, or warning. |
| R-PRO-04 | Creating abstractions before a second instance exists to justify them. |
| R-PRO-05 | Silencing errors or using generic handling to avoid interrupting the flow. |
| R-PRO-06 | Mixing abstraction levels within a single function. |
| R-PRO-07 | Leaving code undocumented where intent is not evident. |

---

## 8. Delivery Checklist

Mandatory checklist before considering code complete. If anything fails: **rewrite, don't patch.**

- [ ] **FE-01** — Is the system's intent readable straight through, without needing to trace its execution?
- [ ] **FE-02** — Does every name say exactly what it is — no more, no less?
- [ ] **FE-03** — Does every function do exactly one thing and can be described without conjunctions?
- [ ] **FE-04** — Does every comment add something the code alone cannot say?
- [ ] **FE-05** — Is the code documented where intent is not evident?
- [ ] **FE-06** — What can I remove without losing meaning? (If the answer is not "nothing", remove it.)