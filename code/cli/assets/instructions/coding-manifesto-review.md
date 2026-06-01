---
name: coding-manifesto-review
description: 'Programming review protocol for EXECUTE. Use when: entering or continuing a bounded coding slice. Guides: intent visibility, naming precision, function boundaries, comments, and rewrite-before-patch discipline.'
---

# coding-manifesto-review — Programming Review Protocol

## Prompt Summary

Read the changed slice before calling it complete.
Verify that the code reveals its intent straight through.
Reject generic names, mixed abstraction levels, speculative abstractions, and comments that only paraphrase code.
Require functions to do one thing and names to say exactly what they are.
If the slice fails the manifesto, rewrite it instead of patching around the defect.

## When to Use

- When entering EXECUTE from PLAN
- When continuing EXECUTE on a new bounded slice
- Before treating a coding slice as ready for validation or handoff

## Review Questions

1. Is the intent readable straight through without tracing execution?
2. Do names say exactly what each thing is?
3. Does every function do one thing at one abstraction level?
4. Do comments explain why instead of repeating what?
5. Can any code be removed without losing meaning?

## Rewrite Triggers

Rewrite the slice if any of these are true:

- A public function needs a conjunction to describe what it does
- A primary identifier is generic when a domain name exists
- Business logic is buried in incidental structure
- A comment merely paraphrases the code
- An abstraction exists without an earned second instance
- Error handling hides what failed or why it matters

## Outcome Rule

If the slice passes, continue with the phase-owned validation obligations.
If the slice fails, rewrite the code before widening scope or calling the work complete.