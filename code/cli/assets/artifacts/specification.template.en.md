# Requirement Specification

> **All fields are mandatory.**
> User stories per *User Stories Applied* (Mike Cohn, 2004).
> Acceptance Criteria in *Given-When-Then* — BDD (Dan North, 2006).
> Testing strategy aligned with *TDD* (Kent Beck, 2002).
> Decisions are licensed by **evidence from experiments, not by inference**.

## Metadata

| Field         | Value                              |
| ------------- | ---------------------------------- |
| ID            | REQ-{{DATE}}-XXX                   |
| System        | <!-- official catalog value -->    |
| Project       | <!-- project name -->              |
| Requester     | <!-- requester / area -->          |
| Priority      | <!-- High / Medium / Low -->       |
| QA Analyst    | <!-- Name -->                      |
| Dev Analyst   | <!-- Name -->                      |
| Date          | {{DATE}}                           |

## 1. User Stories

### US-1: <!-- descriptive title -->

**As a** <!-- user role -->,
**I want** <!-- action they want to perform -->,
**So that** <!-- benefit or value obtained -->.

#### Acceptance Criteria

<!-- The AC column holds ONLY the number (1, 2, …); the id is AC-<number>. Keep
     the separator dashes moderate — do not widen them to the text width, or the
     PDF export splits the column. -->

| AC  | Given (context)         | When (action)        | Then (expected result) |
| --- | ----------------------- | -------------------- | ---------------------- |
| 1   | <!-- precondition -->   | <!-- action -->      | <!-- expected result --> |

<!-- Duplicate the US-N block for more stories. -->

## 2. Testing Strategy

Define **which kinds of tests** are needed and **what they validate** — no function names or code.

| Type        | What it must validate                       | Related AC      |
| ----------- | ------------------------------------------- | --------------- |
| Unit        | <!-- e.g. field validation, no-dup rule --> | <!-- AC-1 -->   |
| Integration | <!-- e.g. correct DB persistence -->        | <!-- AC-2 -->   |
| E2E         | <!-- e.g. full UI flow — or N/A -->         | <!-- AC-1 -->   |

## 3. Explicit Scope

### Includes

- <!-- what this requirement DOES cover -->

### Does NOT include

- <!-- what is explicitly out of scope -->

## 4. Decisions (evidence)

> Each key decision must cite the experiment that licensed it (a throwaway probe:
> a DB query, a container run, an API call), with a re-checkable handle — not an
> assumption.

- **Decision**: <!-- the decision made -->. **Evidence**: <!-- experiment + result, with a re-checkable handle: a query, a command, `inline-code`, or a file:line -->.

## Annexes

<!-- Diagrams, mockups, technical notes, references, or any supporting material. -->
