# RedBook-Fixer Adapter

## Site

- name: `RedBook-Fixer`
- url: `https://catteacher0515.github.io/RedBook-Fixer/`
- purpose: 初筛、替换、自动修复

## Entry

- page_ready_signal:
  - `document.title === "RedBook Fixer — 小红书文案敏感词处理"`
  - `#input-textarea`
  - `#btn-detect`
- login_required: `no`
- notes:
  - This site is the source of truth for the fix step.
  - The model must not substitute its own rewriting for this site's result.

## Input

- input_selector: `#input-textarea`
- input_method: Set `#input-textarea.value`, then dispatch `input` and `change` events.
- input_events:
  - `input`
  - `change`
- max_length_notes:
  - The page displays a live character counter next to the source panel.
  - No explicit hard limit was verified during MVP validation.

## Action

- trigger_selector: `#btn-detect`
- trigger_text:
  - Before detection: `开始检测`
  - After detection: `重新检测`
- fallback_action:
  - If `#btn-detect` is missing, stop with `pipeline_error`.
- wait_condition_after_trigger:
  - Wait until `#btn-detect` text becomes `重新检测`.
  - Then verify `#output-view` is non-empty.
  - The page may also expose `检测到 N 个敏感词` in `#page-process`.

## Output

- output_selector: `#output-view`
- extraction_method:
  - Extract `innerText` from `#output-view`.
  - Normalize surrounding whitespace only.
- success_signal:
  - `#output-view` contains non-empty text.
  - `#btn-detect` text has switched to `重新检测`.
- empty_output_rule:
  - If no fixed text can be extracted after the action appears complete, return `pipeline_error`.

## Verified DOM Facts

- Source panel root: `#page-process .panel-left`
- Result panel root: `#page-process .panel-right`
- Result text container: `#output-view`
- Input highlight container: `#input-highlight`
- Built-in risk matches may appear as `.word-red` spans in the source highlight layer.

## Known Traps

- Button clicks alone do not prove the fix step succeeded.
- The page uses a plain textarea for input. Direct `.value=` without event dispatch is weaker than `.value=` plus `input` and `change`.
- If page structure changes and the validated output node disappears, do not guess from unrelated text blocks.
- The drawer `#drawer` and its controls are visible in DOM after detection, but they are not required for the MVP pipeline.
