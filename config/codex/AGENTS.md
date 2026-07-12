# Thread naming

- Name each Codex thread after its current conversation or work context so the
  user can infer its purpose from the name alone.
- Use the fewest words needed to make the purpose clear. Thread names may be
  shorter than four words and should not exceed 4-6 words, with the exact upper
  bound depending on word length.
- Update the thread name whenever the conversation's primary context or scope
  changes enough that the existing name no longer describes it accurately.
- Avoid vague or generic names such as "New task," "Help needed," or "General
  discussion."

# General instructions

**Tool preferences:**
- Prefer `fd` over `find` for filesystem searches because it is faster. Use
  `find` only when `fd` is unavailable or lacks a required capability.

**Codex sandbox:**
- When running `uv` commands from Codex, set `UV_CACHE_DIR` to a
  sandbox-writable cache directory, for example:
  ```
  UV_CACHE_DIR=/private/tmp/uv-cache uv run ...
  ```
- For `just` recipes that invoke `uv`, pass the environment variable to `just`,
  for example:
  ```
  UV_CACHE_DIR=/private/tmp/uv-cache just ...
  ```
