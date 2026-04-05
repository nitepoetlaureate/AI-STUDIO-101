# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.6 |
| **Release Date** | January 2026 |
| **Project Pinned** | 2026-02-12 |
| **Last Docs Verified** | 2026-04-05 |
| **LLM Knowledge Cutoff** | May 2025 |
| **Knowledge Risk** | HIGH — 4.4, 4.5, and 4.6 are all beyond training data |

## Knowledge Gap Warning

The LLM's training data likely covers Godot up to ~4.3. Versions 4.4, 4.5,
and 4.6 introduced significant changes that the model does NOT know about.
**Always cross-reference this directory before suggesting Godot API calls.**

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.4 | Mid 2025 | MEDIUM | Jolt Physics (experimental), Universal UIDs, Typed Dictionaries, 2D batching |
| 4.5 | Late 2025 | HIGH | GDScript abstract/variadic, Shader baker, SMAA, 2D navigation server, Tilemap chunk physics |
| 4.6 | Jan 2026 | HIGH | Jolt default (3D), Audio API changes, AnimationPlayer StringName, Unique Node IDs, D3D12 default on Windows |

## Reference Docs in This Directory

| File | Contents |
|------|----------|
| `breaking-changes.md` | Version-by-version breaking changes (4.4→4.5→4.6) |
| `deprecated-apis.md` | "Don't use X → Use Y" tables |
| `current-best-practices.md` | New patterns and best practices since 4.3 |

## Verified Sources

- Official docs: https://docs.godotengine.org/en/stable/
- 4.5→4.6 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html
- 4.4→4.5 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.5.html
- 4.3→4.4 migration: https://docs.godotengine.org/en/4.4/tutorials/migrating/upgrading_to_godot_4.4.html
- Changelog: https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- Release notes 4.6: https://godotengine.org/releases/4.6/
- Release notes 4.5: https://godotengine.org/releases/4.5/
- Release notes 4.4: https://godotengine.org/releases/4.4/
