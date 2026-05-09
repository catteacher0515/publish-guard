# Execution Logging

This reference defines how every `content-safety-pipeline` run must be archived.

## Goal

Write one JSON log file per run so the user can later review:

1. The original copy
2. The fixed copy from `RedBook-Fixer`
3. The final review result from `零克查词`
4. The Xiaohongshu draft result
5. The final user-facing conclusion

## Log Location

Use the repository-local path:

```text
logs/content-safety-pipeline/YYYY/MM/
```

Example:

```text
logs/content-safety-pipeline/2026/05/
```

## File Naming

Use one file per run:

```text
YYYY-MM-DDTHH-mm-ss-status.json
```

Example:

```text
2026-05-09T12-30-45-pass.json
2026-05-09T12-44-10-fail.json
2026-05-09T12-50-03-error.json
```

Use local machine time.

## Required Log Fields

The written JSON file must include:

```json
{
  "logged_at": "2026-05-09T12:30:45+08:00",
  "skill_name": "content-safety-pipeline",
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

## Write Rules

1. Build the final result object first.
2. Create the year and month directory if missing.
3. Write pretty-printed JSON for readability.
4. Record the actual saved relative path in `log_path`.
5. Set `log_status=written` only after the file is successfully written.
6. If writing fails, keep the business result unchanged and set `log_status=failed`.

## Practical Notes

1. Do not block a verified `pass` result just because logging failed.
2. Do not remove or truncate user copy.
3. Do not omit `raw_result` from `零克查词` when it is available.
4. Prefer repository-relative paths in the returned JSON appendix.
