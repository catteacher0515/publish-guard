---
name: content-safety-pipeline
description: Use when reviewing Xiaohongshu copy through a fixed browser-based safety pipeline that must use site-provided detection and repair tools instead of freeform AI rewriting
---

# Content Safety Pipeline

## Overview

This skill orchestrates a fixed Xiaohongshu copy review pipeline.

It does not rewrite copy freely. It routes the copy through two site tools:

1. `RedBook-Fixer` for site-provided detection, replacement, and auto-fix
2. `零克查词` for final review

If final review passes, it may also write the approved copy into a Xiaohongshu image-note draft.

All browser work must be delegated to `web-access`.

## When To Use

Use this skill when:

1. The user provides raw Xiaohongshu copy that still needs platform safety review.
2. The review must follow a fixed browser pipeline instead of freeform AI editing.
3. The result must return copy-ready text first, with structured JSON kept as appendix output.
4. A passing result may need to be written into a Xiaohongshu image-note draft for later human review.

Do not use this skill when:

1. The user wants creative rewriting.
2. The user wants a general-purpose moderation framework for many platforms.
3. The required websites are unavailable and the user wants an offline fallback.

## Required Composition

This skill is orchestration-only.

Before performing any web action:

1. Load `web-access`.
2. Follow `web-access` guidance for browser setup and execution.

Before each site stage:

1. Read `references/site-adapters/redbook-fixer.md` before using `RedBook-Fixer`.
2. Read `references/site-adapters/lingkechaci.md` before using `零克查词`.
3. Read `references/site-adapters/xiaohongshu-image-draft.md` before using the Xiaohongshu draft branch.

## Workflow

1. Receive the user's raw Xiaohongshu copy as `input_text`.
2. Load `web-access` and use it for all website access and page interaction.
3. Read `references/site-adapters/redbook-fixer.md`.
4. Open `RedBook-Fixer`.
5. Input `input_text` into the page.
6. Trigger the site's own detection, replacement, and auto-fix behavior.
7. Extract the fixed copy as `redbook_fixed_text`.
8. If extraction fails, return `status=error` with `failure_reason=pipeline_error`.
9. Read `references/site-adapters/lingkechaci.md`.
10. Open `零克查词`.
11. Submit `redbook_fixed_text` for final review.
12. Extract the review result.
13. If the site reports remaining risk, return `status=fail` with `failure_reason=manual_review_required` and `draft_status=skipped`.
14. If the site reports no risk, set `status=pass` and `final_text=redbook_fixed_text`.
15. If `status=pass`, read `references/site-adapters/xiaohongshu-image-draft.md` and attempt the Xiaohongshu image-note draft branch.
16. In the draft branch, upload `/Users/huapingyu/Myself/pingyu.jpg`, enter the image-note editor, and write `final_text` into the body field.
17. If the draft branch succeeds, return `draft_status=created`.
18. If the draft branch fails, keep `status=pass`, return `draft_status=failed`, and capture the reason in `draft_note`.
19. If page structure, submission, or extraction fails before content safety reaches `pass`, return `status=error` with `failure_reason=pipeline_error` and `draft_status=skipped`.

## Output Contract

Always return:

1. A copy-ready primary output block
2. A short Chinese summary
3. A machine-readable JSON appendix

Use this JSON shape:

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
  "draft_note": ""
}
```

Field rules:

1. If `status=pass`, then `failure_reason=null` and `final_text` must equal `redbook_fixed_text`.
2. If `status=fail`, then `failure_reason=manual_review_required` and `draft_status=skipped`.
3. If `status=error`, then `failure_reason=pipeline_error` and `draft_status=skipped` unless a post-pass draft branch failed.
4. `advice` must be either `可发布`, `可发布，但写入小红书草稿失败`, or `仍有风险词，建议人工处理`.
5. If `draft_status=created`, `draft_url` should be recorded when available.
6. If `draft_status=failed`, `draft_note` must explain the failure briefly.

Presentation rules:

1. If `status=pass`, the first output block must contain only `final_text`, so the user can copy it directly.
2. If `status=pass` and `draft_status=created`, the second output block should be a short summary such as `可发布，已写入小红书图文草稿`.
3. If `status=pass` and `draft_status=failed`, the second output block should be `可发布，但写入小红书草稿失败`.
4. If `status=fail`, the first output block should contain `redbook_fixed_text` as the best available draft, followed by a short manual-review warning.
5. If `status=error`, do not output a copy-ready draft block unless a verified `redbook_fixed_text` already exists and is clearly labeled as unapproved.
6. The JSON object must appear after the human-facing output, not before it.

## Status Model

Track the content safety pipeline through these states:

1. `received`
2. `fixing`
3. `fixed`
4. `reviewing`
5. `passed`
6. `failed`

Map content failure through:

1. `manual_review_required`
2. `pipeline_error`

Track the draft branch through these states:

1. `draft_skipped`
2. `draft_opening`
3. `draft_uploading`
4. `draft_editing`
5. `draft_created`
6. `draft_failed`

## Hard Constraints

1. Do not freely rewrite the user's copy.
2. Do not invent a repaired version if `RedBook-Fixer` fails.
3. Do not loop back into `RedBook-Fixer` after a failing `零克查词` result.
4. Do not guess at results when selectors, buttons, or output nodes cannot be verified.
5. Use only `RedBook-Fixer` output as the candidate publishable text.
6. Keep the final human summary short and factual.
7. Optimize the first visible output for direct copy and paste by the user.
8. The Xiaohongshu draft branch may run only after content safety returns `status=pass`.
9. The Xiaohongshu draft branch must never auto-publish.
10. The draft branch must use `/Users/huapingyu/Myself/pingyu.jpg` as the fixed image for this MVP.
11. Even if the draft branch succeeds, still output the copy-ready text first for human review.

## Failure Handling

Return `status=fail` when:

1. `零克查词` explicitly indicates remaining risk.

Return `status=error` when:

1. A required page cannot be opened before content safety reaches `pass`.
2. A required page-ready signal is missing before content safety reaches `pass`.
3. Text cannot be entered reliably before content safety reaches `pass`.
4. A required action cannot be triggered before content safety reaches `pass`.
5. Output cannot be extracted reliably before content safety reaches `pass`.
6. The page structure appears to have changed and the adapter no longer matches before content safety reaches `pass`.

Return `draft_status=failed` when:

1. Xiaohongshu is not logged in.
2. The fixed image cannot be uploaded.
3. The editor page does not become writable after image upload.
4. The body field cannot be found or written.
5. The draft page structure appears to have changed after content safety already passed.

## Validation Notes

This MVP is documentation-first plus live adapter verification.

The next execution phase should validate:

1. One sample that passes final review and creates a draft successfully.
2. One sample that passes final review but fails in the draft branch.
3. One sample that still fails final review and skips the draft branch.
4. One broken-path scenario to confirm `pipeline_error` before content safety passes.
