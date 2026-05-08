# Content Safety Pipeline Design

**Date:** 2026-05-08

## Goal

Create a maintainable personal skill for reviewing Xiaohongshu copy through a fixed browser-based safety pipeline. The skill must orchestrate two existing web tools instead of letting the model freely rewrite risky phrases.

## Scope

This MVP covers:

1. Accepting raw Xiaohongshu copy from the user.
2. Opening `RedBook-Fixer` through `web-access`.
3. Submitting the raw copy to `RedBook-Fixer`.
4. Extracting the site-produced fixed copy.
5. Opening `零克查词` through `web-access`.
6. Submitting the fixed copy for final review.
7. Returning a structured result plus a short Chinese summary.

This MVP does not cover:

1. Automatic retry loops back into `RedBook-Fixer`.
2. Freeform AI rewriting.
3. Script-based selector execution.
4. Multi-platform content review beyond Xiaohongshu.

## Architecture

The skill is intentionally split into one orchestration layer and two site adapter references.

### 1. Orchestration Layer

`SKILL.md` owns:

1. Trigger conditions
2. Workflow order
3. Input and output contract
4. Failure branches
5. Hard constraints

It must not embed site-specific selectors or extraction details.

### 2. Site Adapter Layer

Each site gets its own adapter file under `references/site-adapters/`.

The adapter files own:

1. Entry URL
2. Page-ready signal
3. Input selector and input method
4. Trigger action
5. Output extraction rule
6. Success signals
7. Known traps

This makes future site maintenance local instead of forcing main skill rewrites.

## Workflow

1. Receive the user's raw Xiaohongshu copy.
2. Load `web-access` and use it for all browser activity.
3. Read `references/site-adapters/redbook-fixer.md`.
4. Open `RedBook-Fixer`.
5. Input the raw copy.
6. Trigger the site's own detection, replacement, and auto-fix flow.
7. Extract the fixed copy.
8. Read `references/site-adapters/lingkechaci.md`.
9. Open `零克查词`.
10. Submit the fixed copy.
11. Read the final review result.
12. If no risk is found, return `status=pass`.
13. If risk remains, return `status=fail` with manual handling advice.
14. If the pipeline cannot complete because of site or extraction failure, return `status=error`.

## State Machine

The MVP state machine has six states:

1. `received`
2. `fixing`
3. `fixed`
4. `reviewing`
5. `passed`
6. `failed`

`failed` is refined through `failure_reason`:

1. `manual_review_required`
2. `pipeline_error`

## Output Contract

The skill must always return:

1. A machine-readable JSON object
2. A short Chinese summary

The JSON contract for the MVP is:

```json
{
  "status": "pass | fail | error",
  "failure_reason": "manual_review_required | pipeline_error | null",
  "input_text": "原始文案",
  "redbook_fixed_text": "RedBook-Fixer 修复后文案",
  "lingke_review": {
    "has_risk": true,
    "risk_words": [],
    "risk_level": "",
    "raw_result": ""
  },
  "final_text": "可发布版本或待人工处理版本",
  "advice": "结论与建议"
}
```

Field rules:

1. `status=pass`
   `final_text` must equal `redbook_fixed_text`.
2. `status=fail`
   `failure_reason` must equal `manual_review_required`.
3. `status=error`
   `failure_reason` must equal `pipeline_error`.
4. `advice` must be either `可发布` or `仍有风险词，建议人工处理`.

## Hard Constraints

1. The model must not freely rewrite the copy.
2. The model must use only the text produced by `RedBook-Fixer` as the candidate publishable text.
3. If `零克查词` still flags risk, the skill must stop and return manual review guidance.
4. If selectors or extraction fail, the skill must return `pipeline_error` instead of guessing.
5. All website access and page operations must go through `web-access`.

## File Layout

```text
content-safety-pipeline/
├── SKILL.md
└── references/
    └── site-adapters/
        ├── redbook-fixer.md
        └── lingkechaci.md
```

## Validation Plan

The MVP is acceptable when it can handle:

1. A sample copy that gets fixed by `RedBook-Fixer` and passes `零克查词`
2. A sample copy that still fails `零克查词`
3. A broken-page scenario where a required selector is missing
