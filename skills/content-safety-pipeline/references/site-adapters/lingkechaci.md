# Lingkechaci Adapter

## Site

- name: `零克查词`
- url: `https://www.lingkechaci.com/`
- purpose: 最终风险审查

## Entry

- page_ready_signal:
  - `document.title` contains `零克查词`
  - `textarea.el-textarea__inner`
  - A visible button with text `立即检测`
- login_required: `no`
- notes:
  - This site is the source of truth for the final review decision in the MVP.
  - A flagged result must stop the pipeline and return manual review guidance.

## Input

- input_selector: `textarea.el-textarea__inner`
- input_method: Set `textarea.el-textarea__inner.value`, then dispatch `input` and `change` events.
- input_events:
  - `input`
  - `change`

## Action

- submit_selector: Visible `button` whose trimmed text equals `立即检测`
- submit_text: `立即检测`
- fallback_action:
  - If no visible `立即检测` button can be found, stop with `pipeline_error`.
- wait_condition_after_submit:
  - Wait until `.tool-result` reflects the current input text counts.
  - Confirm `.editor-result` has refreshed to the submitted text.
  - Do not treat button-click success as result success.

## Review Result

- result_root_selector: `.tool-result`
- raw_result_extraction:
  - Preserve the page's original review text as closely as possible in `raw_result`.
  - Whitespace normalization is allowed, semantic rewriting is not.
- no_risk_signal:
  - `.tool-result` contains both `违禁词：0` and `敏感词：0`
  - `.editor-result .highlight-words` is empty
- risk_signal:
  - `.tool-result` reports a non-zero `违禁词` or `敏感词`
  - Highlighted terms appear under `.editor-result .highlight-words`
- risk_words_selector:
  - `.editor-result .highlight-words`
  - Extract highlighted token text only.
- risk_level_selector:
  - No dedicated risk-level field was verified during MVP validation.
  - Leave empty unless the site later exposes one explicitly.
- empty_result_rule:
  - If no review result can be read after submission appears complete, return `pipeline_error`.

## Verified DOM Facts

- Input box: `textarea.el-textarea__inner`
- Input count node: `.el-input__count`
- Reviewed text container: `.editor-result`
- Summary counts container: `.tool-result`
- Highlighted tokens: `.editor-result .highlight-words`
- The site may show a toast-like success message such as `检测成功！`, but it is weaker than `.tool-result` and `.editor-result` state.

## Known Traps

- Absence of highlights alone is not enough to conclude `pass`; require `.tool-result` to report zero counts.
- The site updates in place. Read results only after the editor content and count line reflect the latest submitted text.
- Extract `risk_words` only from `.editor-result .highlight-words`, not from unrelated marketing copy or checkbox labels.
- If the page result area changes structure, do not synthesize a decision from unrelated page copy.
- No dedicated risk-level UI was verified during MVP validation, so `risk_level` should stay empty for now.
