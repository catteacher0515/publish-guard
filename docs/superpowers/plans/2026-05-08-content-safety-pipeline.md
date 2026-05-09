# Content Safety Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an MVP personal skill that runs a fixed Xiaohongshu content safety pipeline through `RedBook-Fixer` and `零克查词`, returns copy-ready text first, and writes passing copy into a Xiaohongshu image-note draft without auto-publishing.

**Architecture:** Keep orchestration in `SKILL.md` and move site-specific behavior into three adapter reference files. Do not add scripts in the MVP. The skill must compose with `web-access` rather than re-implement browser logic.

**Tech Stack:** Markdown skill files, local skill references, browser automation delegated to `web-access`

---

### Task 1: Update The Design Artifacts

**Files:**
- Modify: `docs/superpowers/specs/2026-05-08-content-safety-pipeline-design.md`
- Modify: `docs/superpowers/plans/2026-05-08-content-safety-pipeline.md`

- [ ] **Step 1: Extend the design document**

Update the design so it covers:

1. The Xiaohongshu draft sub-state machine
2. The fixed image path `/Users/huapingyu/Myself/pingyu.jpg`
3. The new JSON fields `draft_status`, `draft_url`, and `draft_note`
4. The rule that `status=pass` still outputs copy-first text before draft handling details

- [ ] **Step 2: Review the design document for missing scope**

Check that the design includes:

1. Two-layer state handling
2. Draft failure independence from content safety pass/fail
3. No auto-publish rule
4. Human review retained even after draft creation

Expected: all four are present with no placeholders.

- [ ] **Step 3: Update the implementation plan**

Add the Xiaohongshu draft adapter and the live validation work for image upload and editor filling.

### Task 2: Update The Main Skill

**Files:**
- Modify: `skills/content-safety-pipeline/SKILL.md`

- [ ] **Step 1: Extend the workflow**

Document the new branch:

1. `status=pass` triggers Xiaohongshu draft attempt
2. `status=fail` and `status=error` skip the draft branch
3. Draft failure must not erase content safety success

- [ ] **Step 2: Extend the output contract**

Add:

1. `draft_status`
2. `draft_url`
3. `draft_note`
4. Summary text rules for `draft_status=created` and `draft_status=failed`

- [ ] **Step 3: Extend the hard constraints**

Document:

1. No auto-publish
2. Fixed image path for MVP
3. Copy-first output remains mandatory even when draft creation succeeds

### Task 3: Add The Xiaohongshu Draft Adapter

**Files:**
- Create: `skills/content-safety-pipeline/references/site-adapters/xiaohongshu-image-draft.md`

- [ ] **Step 1: Create the adapter structure**

Include these sections:

1. `Site`
2. `Preconditions`
3. `Entry`
4. `Upload`
5. `Editor Transition`
6. `Content Input`
7. `Success`
8. `Known Traps`

- [ ] **Step 2: Fill verified entry and precondition facts**

Document:

1. Entry URL
2. Login requirement
3. Fixed image path
4. Image-note mode target

- [ ] **Step 3: Fill verified DOM behavior after live validation**

Document:

1. Upload control selector or file input path
2. Upload success signal
3. Editor-ready signal
4. Body selector and input method
5. Draft success signal

### Task 4: Validate The Xiaohongshu Creator Flow Live

**Files:**
- Modify: `skills/content-safety-pipeline/references/site-adapters/xiaohongshu-image-draft.md`

- [ ] **Step 1: Open the creator image-note entry page**

Run a real browser validation with the logged-in Xiaohongshu creator page.

Expected: page is reachable and image-note flow is available.

- [ ] **Step 2: Validate image upload**

Upload `/Users/huapingyu/Myself/pingyu.jpg` through the real page.

Expected: uploaded image appears in the editor flow and the page transitions to body editing.

- [ ] **Step 3: Validate body input**

Write a short sample string into the body field.

Expected: body field contains the written text and remains on the draft editor page.

- [ ] **Step 4: Capture failure signals**

Record concrete failure clues for:

1. Not logged in
2. Upload rejection
3. Missing editor body field
4. Transition failure after upload

### Task 5: Review The Draft Skill Package

**Files:**
- Modify: `skills/content-safety-pipeline/SKILL.md`
- Modify: `docs/superpowers/specs/2026-05-08-content-safety-pipeline-design.md`
- Modify: `docs/superpowers/plans/2026-05-08-content-safety-pipeline.md`
- Modify: `skills/content-safety-pipeline/references/site-adapters/xiaohongshu-image-draft.md`

- [ ] **Step 1: Check naming consistency**

Verify consistent use of:

1. `draft_status`
2. `draft_url`
3. `draft_note`
4. `created | failed | skipped`
5. `/Users/huapingyu/Myself/pingyu.jpg`

- [ ] **Step 2: Check contract consistency**

Verify the same draft fields and status rules appear in the design doc and `SKILL.md`.

- [ ] **Step 3: Check scope discipline**

Verify none of the files introduce:

1. Auto-publish
2. Extra social platforms
3. Retry loops back into content safety
4. AI rewriting fallback

- [ ] **Step 4: Record next validation step**

Document that the next execution phase is a full end-to-end live run that reaches `status=pass` and attempts draft creation.
