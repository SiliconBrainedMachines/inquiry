# Specification

<!-- iq:lang=en · Language of this specification and ALL its derived artifacts (issues, requirements, plans). Keep consistent. Not rendered in the PDF/DOCX. -->

<!--
  All fields are mandatory.
  User stories: User Stories Applied (Cohn, 2004).
  Acceptance Criteria: Given-When-Then — BDD (North, 2006).
  Testing strategy: TDD (Beck, 2002).
  Decisions: licensed by evidence from experiments, not by inference.
-->

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
| Issued        | {{DATE}}                           |

## Context and ground rules

<!-- First-class content (not an "aside"): a glossary of domain terms,
     assumptions and cross-cutting rules that apply to every user story.
     Optional but recommended — it avoids repeating context inside each AC. -->

- <!-- Term, assumption, or cross-cutting rule -->

## 1. Commitment date

<!-- The committed delivery date, in ISO YYYY-MM-DD. Mandatory: the gate
     enforces it. May grow into a mini-schedule (milestones + dates). -->

| Milestone           | Date (YYYY-MM-DD)    |
| ------------------- | -------------------- |
| Committed delivery  | <!-- YYYY-MM-DD -->  |

## 2. User Stories

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

## 3. Testing Strategy

<!-- Define WHICH kinds of tests are needed and WHAT they validate — no function
     names or code. -->

| Type        | What it must validate                       | Related AC      |
| ----------- | ------------------------------------------- | --------------- |
| Unit        | <!-- e.g. field validation, no-dup rule --> | <!-- AC-1 -->   |
| Integration | <!-- e.g. correct DB persistence -->        | <!-- AC-2 -->   |
| E2E         | <!-- e.g. full UI flow — or N/A -->         | <!-- AC-1 -->   |

## 4. Explicit Scope

### Includes

- <!-- what this specification DOES cover -->

### Does NOT include

- <!-- what is explicitly out of scope -->

## 5. Decisions (evidence)

<!-- Each key decision must cite the experiment that licensed it (a throwaway
     probe: a DB query, a container run, an API call), with a re-checkable
     handle — not an assumption. -->

- **Decision**: <!-- the decision made -->. **Evidence**: <!-- experiment + result, with a re-checkable handle: a query, a command, `inline-code`, or a file:line -->.

## Annexes

<!-- Diagrams, mockups, technical notes, references, or any supporting material. -->
