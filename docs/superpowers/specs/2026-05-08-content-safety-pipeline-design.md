# Content Safety Pipeline Design

**Date:** 2026-05-08

## Goal

Create a maintainable personal skill for reviewing Xiaohongshu copy through a fixed browser-based safety pipeline. The skill must orchestrate two existing web tools instead of letting the model freely rewrite risky phrases. When content passes final review, the skill should also attempt to write the approved copy into a Xiaohongshu image-note draft for later human review.

## Scope

This MVP covers:

1. Accepting raw Xiaohongshu copy from the user.
2. Opening `RedBook-Fixer` through `web-access`.
3. Submitting the raw copy to `RedBook-Fixer`.
4. Extracting the site-produced fixed copy.
5. Opening `零克查词` through `web-access`.
6. Submitting the fixed copy for final review.
7. Returning copy-ready text first, followed by a short Chinese summary and a structured result appendix.
8. If final review passes, opening the Xiaohongshu image-note creator, uploading a fixed image, and writing the approved copy into the draft body.
9. Writing one JSON execution log file for each run.

This MVP does not cover:

1. Automatic retry loops back into `RedBook-Fixer`.
2. Freeform AI rewriting.
3. Script-based selector execution.
4. Multi-platform content review beyond Xiaohongshu.
5. Auto-publishing to Xiaohongshu.

## Architecture

The skill is intentionally split into one orchestration layer and three site adapter references.

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
12. If risk remains, return `status=fail` and skip Xiaohongshu drafting.
13. If no risk is found, return `status=pass` and continue into the Xiaohongshu draft branch.
14. Read `references/site-adapters/xiaohongshu-image-draft.md`.
15. Open the Xiaohongshu image-note creator.
16. Upload `/Users/huapingyu/Myself/pingyu.jpg`.
17. Enter the image-note editor and write `final_text` into the body field.
18. If the draft branch succeeds, return `draft_status=created`.
19. If the draft branch fails, keep `status=pass` and return `draft_status=failed`.
20. Build the final result object.
21. Write one JSON execution log under `logs/content-safety-pipeline/YYYY/MM/`.
22. If log writing succeeds, return `log_status=written`.
23. If log writing fails, keep the business result and return `log_status=failed`.
24. If the pipeline cannot complete before content safety reaches `pass`, return `status=error`.

## State Machine

The MVP has three linked state machines.

### 1. Content Safety State Machine

1. `received`
2. `fixing`
3. `fixed`
4. `reviewing`
5. `passed`
6. `failed`

`failed` is refined through `failure_reason`:

1. `manual_review_required`
2. `pipeline_error`

### 2. Xiaohongshu Draft State Machine

1. `draft_skipped`
2. `draft_opening`
3. `draft_uploading`
4. `draft_editing`
5. `draft_created`
6. `draft_failed`

The draft state machine is allowed to start only after content safety reaches `passed`.

### 3. Execution Logging State Machine

1. `log_pending`
2. `log_writing`
3. `log_written`
4. `log_failed`

## Output Contract

The skill must always return:

1. A copy-ready primary output block
2. A short Chinese summary
3. A machine-readable JSON appendix

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
  "advice": "结论与建议",
  "draft_status": "created | failed | skipped",
  "draft_url": "",
  "draft_note": "",
  "log_status": "written | failed",
  "log_path": "",
  "log_note": ""
}
```

Field rules:

1. `status=pass`
   `final_text` must equal `redbook_fixed_text`.
2. `status=fail`
   `failure_reason` must equal `manual_review_required` and `draft_status` must equal `skipped`.
3. `status=error`
   `failure_reason` must equal `pipeline_error`.
4. `advice` must be either `可发布`, `可发布，但写入小红书草稿失败`, or `仍有风险词，建议人工处理`.
5. `draft_status=created`
   `draft_url` should be recorded when available.
6. `draft_status=failed`
   `draft_note` should briefly explain why the draft branch failed.
7. `log_status=written`
   `log_path` should record the saved file path.
8. `log_status=failed`
   `log_note` should briefly explain why the log file was not written.

Presentation rules:

1. `status=pass`
   The first visible output must be `final_text` only, so the user can copy it directly.
2. `status=pass` and `draft_status=created`
   The summary should say `可发布，已写入小红书图文草稿`.
3. `status=pass` and `draft_status=failed`
   The summary should say `可发布，但写入小红书草稿失败`.
4. `status=fail`
   The first visible output should be `redbook_fixed_text`, followed by a short warning that manual handling is still required.
5. `status=error`
   The skill should prioritize the error explanation and keep JSON as appendix output.
6. The JSON appendix must come after the user-facing copy block and summary.
7. The short summary may mention that the execution log was archived.

## Hard Constraints

1. The model must not freely rewrite the copy.
2. The model must use only the text produced by `RedBook-Fixer` as the candidate publishable text.
3. If `零克查词` still flags risk, the skill must stop and return manual review guidance.
4. If selectors or extraction fail before content safety passes, the skill must return `pipeline_error` instead of guessing.
5. All website access and page operations must go through `web-access`.
6. The Xiaohongshu draft branch must never auto-publish.
7. The Xiaohongshu draft branch must use `/Users/huapingyu/Myself/pingyu.jpg` as the fixed image for this MVP.
8. Even if drafting succeeds, the skill must still output the copy-ready text first for human review.
9. Every run must attempt to write one JSON execution log file.
10. A log-writing failure must not erase a verified business result.

## File Layout

```text
content-safety-pipeline/
├── SKILL.md
├── templates/
│   └── execution-log-template.json
└── references/
    ├── execution-logging.md
    └── site-adapters/
        ├── redbook-fixer.md
        ├── lingkechaci.md
        └── xiaohongshu-image-draft.md
```

## Validation Plan

The MVP is acceptable when it can handle:

1. A sample copy that gets fixed by `RedBook-Fixer`, passes `零克查词`, and is written into a Xiaohongshu draft.
2. A sample copy that gets fixed by `RedBook-Fixer`, passes `零克查词`, but fails in the Xiaohongshu draft branch while preserving `status=pass`.
3. A sample copy that still fails `零克查词` and skips the Xiaohongshu draft branch.
4. A broken-page scenario where a required selector is missing before content safety passes.
