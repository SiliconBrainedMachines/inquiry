# Specification

<!-- iq:lang=en · Language of this specification and ALL its derived artifacts (issues, requirements, plans). Keep consistent. Not rendered in the PDF/DOCX. -->

<!--
  User stories: User Stories Applied (Cohn, 2004).
  Acceptance Criteria: Given-When-Then — BDD (North, 2006).
  Domain language: Domain-Driven Design (Evans, 2003).
-->

_This specification is the **business agreement** — like a project charter — between the Product Owner and the team. Write it in the **domain language (DDD)**: business and behavior, not implementation (the technical part lives in the issues)._

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
| Sources       | <!-- PPT, mockups, emails, links --> |

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
     PDF export splits the column. Each AC is also its acceptance test (tests are
     written in development). -->

| AC  | Given (context)         | When (action)        | Then (expected result) |
| --- | ----------------------- | -------------------- | ---------------------- |
| 1   | <!-- precondition -->   | <!-- action -->      | <!-- expected result --> |

<!-- Duplicate the US-N block for more stories. -->

## 3. Explicit Scope

### Includes

- <!-- what this specification DOES cover -->

### Does NOT include

- <!-- what is explicitly out of scope -->

## 4. Domain and business rules

<!-- Ubiquitous language (DDD): domain glossary, cross-cutting business rules and
     actors/permissions that apply to the stories. Business only — the
     implementation lives in the issues. -->

- **Actors / permissions:** <!-- who can do what -->
- **Glossary:** <!-- domain term: definition (each term defined once) -->
- **Rules:** <!-- cross-cutting business rule shared by the stories -->
