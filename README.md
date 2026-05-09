# publish-guard

`publish-guard` 是一个给 Codex / Claude Code 用的自定义 skill 仓库。

当前已实现的 skill：

1. `content-safety-pipeline`

它负责把小红书原始文案按固定流水线送进：

1. `RedBook-Fixer` 做初筛、替换、自动修复
2. `零克查词` 做终审
3. 终审 `pass` 后，把文案写入小红书图文草稿

## 让 Codex 可调用

Codex 的个人自定义 skills 目录是 `~/.agents/skills/`。

第一次安装执行：

```bash
./scripts/install-content-safety-pipeline.sh
```

安装完成后，重启 Codex。

本仓库使用的是符号链接安装方式：

1. `~/.agents/skills/content-safety-pipeline`
2. 会直接指向本仓库里的 `skills/content-safety-pipeline`
3. 后续你修改仓库里的 skill 内容，不需要重复安装

## 如何调用

重启 Codex 后，可以直接在对话里显式提到：

```text
请用 content-safety-pipeline 处理这段小红书文案
```

也可以在任务描述里自然触发它，例如：

```text
这是一段还没过敏感词筛查的小红书文案，请按 RedBook-Fixer -> 零克查词 -> 小红书草稿 的固定流程处理
```

更容易命中的中文说法也可以直接这样写：

```text
帮我过一遍这段小红书文案的敏感词
```

```text
检查这段文案有没有风险词，如果没问题就灌进小红书草稿
```

```text
用零克查词和 RedBook-Fixer 处理这段小红书文案
```

## 当前约束

1. 只做固定流程编排，不做自由改写
2. 小红书草稿分支只写草稿，不自动发布
3. MVP 固定上传图片为 `/Users/huapingyu/Myself/pingyu.jpg`
