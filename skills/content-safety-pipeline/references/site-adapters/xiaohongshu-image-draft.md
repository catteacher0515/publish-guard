# Xiaohongshu Image Draft Adapter

## Site

- name: `小红书图文草稿`
- entry_url: `https://creator.xiaohongshu.com/publish/publish?source=official&from=tab_switch&target=image`
- purpose: 图文草稿写入

## Preconditions

- login_required: `yes`
- required_image_path: `/Users/huapingyu/Myself/pingyu.jpg`
- page_mode: `image-note`
- notes:
  - This branch is allowed only after content safety returns `status=pass`.
  - The branch must stop at draft editing and must never click `发布`.

## Entry

- page_ready_signal:
  - `document.title === "小红书创作服务平台"`
  - `location.href` contains `creator.xiaohongshu.com/publish/publish`
  - `div.tiptap.ProseMirror` exists
- fallback_if_not_ready:
  - Prefer reusing an already open logged-in creator tab with `target=image` when a fresh background tab renders blank.
  - If no logged-in creator editor can be reached, return `draft_status=failed`.

## Upload

- file_input_selector:
  - `input[type=file][accept*=".jpg"]`
- upload_trigger_selector:
  - Use the hidden image-note file input directly through `setFiles`.
- upload_success_signal:
  - The editor page remains open and the body text includes `图片编辑`.
  - The page image count changed from `1/18` to `2/18` during validation after uploading the fixed image.
  - A second image thumbnail/index becomes visible in the editor flow.
- upload_failure_signal:
  - `setFiles` returns failure.
  - The page does not reflect an added image after upload.

## Editor Transition

- transition_signal_after_upload:
  - The page stays on the creator editor and still exposes `div.tiptap.ProseMirror`.
  - The main body text still includes `图片编辑` and image count text.
- editor_ready_signal:
  - `div.tiptap.ProseMirror`
  - Existing placeholder paragraph: `输入正文描述，真诚有价值的分享予人温暖`
- preview_signal:
  - The right-side preview area contains `笔记预览`.

## Content Input

- body_selector: `div.tiptap.ProseMirror`
- input_method:
  - Focus `div.tiptap.ProseMirror`
  - Write a paragraph into the editor DOM
  - Dispatch an `InputEvent("input")`
- input_events:
  - `input`
- content_written_signal:
  - `div.tiptap.ProseMirror.innerText` contains the expected text.
  - `document.body.innerText` also reflects the written copy in the editor region.

## Success

- draft_success_signal:
  - Uploaded image is reflected in the editor state.
  - `div.tiptap.ProseMirror` contains the written copy.
  - The page remains on the creator editor and does not navigate away.
- final_url_capture:
  - Record `location.href` when the draft branch ends.
- final_note:
  - Success means `draft_status=created`.
  - Failure means `draft_status=failed` while preserving content safety `status=pass`.

## Verified DOM Facts

- Title input: `input.d-text[placeholder="填写标题会有更多赞哦"]`
- Body editor: `div.tiptap.ProseMirror`
- Topic button: `#topicBtn`
- Fixed image file inputs:
  - `input[type=file][accept=".jpg,.jpeg,.png,.webp"]` (two instances were present during validation)
- Draft control buttons:
  - `暂存离开`
  - `发布`
- The branch must not interact with the `发布` button.

## Known Traps

- A freshly opened background tab may render as a blank white page even though the title is correct. Reusing the already open logged-in creator tab is more reliable.
- There are multiple `input[type=file][accept*=".jpg"]` nodes. Prefer the image-note inputs, not the unrelated file picker for attachments.
- The body editor is ProseMirror-based, not a plain textarea. Direct textarea logic will fail.
- Draft creation success should not depend on clicking `暂存离开`; for this MVP, staying on the filled editor page is enough.
- If Xiaohongshu is logged out or the creator page no longer exposes `div.tiptap.ProseMirror`, return `draft_status=failed` with a concrete `draft_note`.
