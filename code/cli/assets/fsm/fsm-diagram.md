# APE FSM — Transition Diagram

> Auto-generated from `transition_contract.yaml`. Only **allowed** transitions shown.

```mermaid
stateDiagram-v2
    [*] --> IDLE

    IDLE --> ANALYZE : start_analyze
    IDLE --> IDLE : block

    ANALYZE --> ANALYZE : start_analyze
    ANALYZE --> PLAN : complete_analysis
    ANALYZE --> IDLE : block

    PLAN --> ANALYZE : start_analyze
    PLAN --> EXECUTE : approve_plan
    PLAN --> EXECUTE : go_execute
    PLAN --> IDLE : block

    EXECUTE --> ANALYZE : start_analyze
    EXECUTE --> END : finish_execute
    EXECUTE --> EXECUTE : go_execute
    END --> EVOLUTION : pr_ready
    END --> IDLE : pr_ready_no_evolution

    EVOLUTION --> IDLE : finish_evolution

    note right of IDLE
        Triage + infrastructure
        No prechecks required
    end note

    note right of ANALYZE
        Prechecks for → PLAN:
        issue_selected_or_created
        diagnosis_exists
    end note

    note right of PLAN
        Prechecks for → EXECUTE:
        issue_selected
        feature_branch_selected
        plan_approved
    end note

    note right of EXECUTE
        Prechecks for → END:
        issue_selected
        feature_branch_selected
    end note

    note right of END
        Prechecks for → EVOLUTION / IDLE:
        issue_selected
        feature_branch_selected
    end note

    note right of EVOLUTION
        Prechecks for → IDLE:
        retrospective_recorded
    end note
```
