#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SOURCE_DIR="${REPO_ROOT}/skills/content-safety-pipeline"
TARGET_ROOT="${HOME}/.agents/skills"
TARGET_DIR="${TARGET_ROOT}/content-safety-pipeline"

if [ ! -d "${SOURCE_DIR}" ]; then
  echo "Skill source not found: ${SOURCE_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_ROOT}"

if [ -L "${TARGET_DIR}" ]; then
  CURRENT_TARGET="$(readlink "${TARGET_DIR}")"
  if [ "${CURRENT_TARGET}" = "${SOURCE_DIR}" ]; then
    echo "content-safety-pipeline is already installed."
    echo "Restart Codex to pick up the skill if this is a new session."
    exit 0
  fi

  echo "Skill link already exists but points elsewhere: ${TARGET_DIR} -> ${CURRENT_TARGET}" >&2
  exit 1
fi

if [ -e "${TARGET_DIR}" ]; then
  echo "Target already exists and is not a symlink: ${TARGET_DIR}" >&2
  exit 1
fi

ln -s "${SOURCE_DIR}" "${TARGET_DIR}"

echo "Installed content-safety-pipeline:"
echo "  ${TARGET_DIR} -> ${SOURCE_DIR}"
echo "Restart Codex to pick up the skill."
