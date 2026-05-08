# Content Safety Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an MVP personal skill that runs a fixed Xiaohongshu content safety pipeline through `RedBook-Fixer` and `零克查词`, returning copy-ready text first plus a short Chinese summary and JSON appendix.

**Architecture:** Keep orchestration in `SKILL.md` and move site-specific behavior into two adapter reference files. Do not add scripts in the MVP. The skill must compose with `web-access` rather than re-implement browser logic.

**Tech Stack:** Markdown skill files, local skill references, browser automation delegated to `web-access`

---

### Task 1: Write The Design Artifacts

**Files:**
- Create: `docs/superpowers/specs/2026-05-08-content-safety-pipeline-design.md`
- Create: `docs/superpowers/plans/2026-05-08-content-safety-pipeline.md`

- [ ] **Step 1: Write the design document**

Write a design doc that fixes the approved MVP boundaries:

1. Orchestration-only `SKILL.md`
2. Two site adapter references
3. Copy-first output
4. No auto-loop when final review fails

- [ ] **Step 2: Review the design document for missing scope**

Check that the design includes:

1. State machine
2. Output contract
3. Hard constraints
4. Validation plan

Expected: all four are present with no placeholders.

- [ ] **Step 3: Write the implementation plan**

Write this plan file with the exact file targets, the MVP boundaries, and no script layer.

- [ ] **Step 4: Review the implementation plan**

Check that the plan does not include:

1. `scripts/`
2. Retry loops
3. Freeform rewriting

Expected: plan stays inside the approved MVP.

### Task 2: Draft The Main Skill

**Files:**
- Create: `skills/content-safety-pipeline/SKILL.md`

- [ ] **Step 1: Write the skill frontmatter**

Use:

```yaml
---
name: content-safety-pipeline
description: Use when reviewing Xiaohongshu copy through a fixed browser-based safety pipeline that must use site-provided detection and repair tools instead of freeform AI rewriting
---
```

- [ ] **Step 2: Write the orchestration overview**

Document:

1. Why the skill exists
2. That it is orchestration-only
3. That all web actions must use `web-access`

- [ ] **Step 3: Write the workflow**

Document the exact ordered flow:

1. Receive input
2. Load `web-access`
3. Read `redbook-fixer.md`
4. Run `RedBook-Fixer`
5. Extract fixed text
6. Read `lingkechaci.md`
7. Run `零克查词`
8. Return `pass`, `fail`, or `error`

- [ ] **Step 4: Write the output contract**

Include the exact JSON schema, the copy-first presentation rule, and the short Chinese summary requirement.

- [ ] **Step 5: Write hard constraints and failure rules**

Document:

1. No freeform rewriting
2. No retry loop
3. No guessing when DOM extraction fails
4. `final_text` rules for each status

### Task 3: Draft The RedBook-Fixer Adapter

**Files:**
- Create: `skills/content-safety-pipeline/references/site-adapters/redbook-fixer.md`

- [ ] **Step 1: Create the adapter structure**

Include these sections:

1. `Site`
2. `Entry`
3. `Input`
4. `Action`
5. `Output`
6. `Known Traps`

- [ ] **Step 2: Fill the adapter as a template-backed MVP**

Document the fields that future validation will fill:

1. `page_ready_signal`
2. `input_selector`
3. `trigger_selector`
4. `output_selector`
5. `success_signal`

Expected: fields are explicit, but clearly marked as needing live validation.

- [ ] **Step 3: Add extraction rules**

Document that:

1. Input should prefer DOM assignment plus input events
2. Waiting should prefer state-based conditions over sleep
3. Success must be tied to output availability, not button click alone

### Task 4: Draft The Lingkechaci Adapter

**Files:**
- Create: `skills/content-safety-pipeline/references/site-adapters/lingkechaci.md`

- [ ] **Step 1: Create the adapter structure**

Include these sections:

1. `Site`
2. `Entry`
3. `Input`
4. `Action`
5. `Review Result`
6. `Known Traps`

- [ ] **Step 2: Fill the adapter as a template-backed MVP**

Document the fields that future validation will fill:

1. `page_ready_signal`
2. `input_selector`
3. `submit_selector`
4. `result_root_selector`
5. `no_risk_signal`
6. `risk_signal`

- [ ] **Step 3: Add result extraction rules**

Document that:

1. `raw_result` should preserve the page's original result text
2. Risk words and level should be extracted only when the page explicitly exposes them
3. Missing result state should return `pipeline_error`

### Task 5: Review The Draft Skill Package

**Files:**
- Modify: `skills/content-safety-pipeline/SKILL.md`
- Modify: `skills/content-safety-pipeline/references/site-adapters/redbook-fixer.md`
- Modify: `skills/content-safety-pipeline/references/site-adapters/lingkechaci.md`

- [ ] **Step 1: Check naming consistency**

Verify consistent use of:

1. `content-safety-pipeline`
2. `RedBook-Fixer`
3. `零克查词`
4. `manual_review_required`
5. `pipeline_error`

- [ ] **Step 2: Check contract consistency**

Verify the same JSON fields appear in the design doc and `SKILL.md`.

- [ ] **Step 3: Check scope discipline**

Verify none of the files introduce:

1. Scripts
2. Extra platforms
3. Auto-loop retries
4. AI rewriting fallback

- [ ] **Step 4: Record next validation step**

Document that the next execution phase is live adapter validation against both sites with 2 to 3 real copy samples.
