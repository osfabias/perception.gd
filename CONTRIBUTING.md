# Contributing

## Steps

1. Create a branch with a suitable prefix (see [Branches](#branches)).
2. Make your changes and commit them (see [Commits](#commits)).
3. Once your changes are ready, open a pull request (see [Pull requests](#pull-requests)).

## Branches

Create a branch with a suitable prefix, e.g. `feat/some-feature-name`.

Keep each branch focused on a single feature, fix, or improvement. Use lowercase letters and hyphens in branch names.

Suitable prefixes:

- `feat/` — new features
- `fix/` — bug fixes
- `ref/` — refactoring
- `docs/` — documentation
- `chore/` — maintenance
- `test/` — tests

## Commits

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. Include a scope when useful.

- Keep commits focused on a single logical change.
- Write commit messages in the imperative mood.
- When fixing a bug, explain the problem and it's cause in the commit body when appropriate.
- Reference related issues in the commit body, e.g. `Refs #42`.
- When a commit resolves an issue, use `Closes #42`.

Example:

```text
fix(scanner): prevent duplicate hits

The scanner could apply damage multiple times when
detecting the same hurt area through multiple rays.

Closes #42
```

### Scopes

A scope names the part of the project a commit concerns, so history can be skimmed and filtered without opening the diff. There is no fixed list of scopes; pick one as follows:

1. Look in the existing history first. If a scope already in use fits the change, reuse it verbatim, with the same spelling and casing.
2. If nothing in the history fits, invent a scope naming the system or subsystem the change belongs to (e.g. `enemy`, `ui`, `input`). Prefer a concern name over a file name.
3. Use an individual node or class name (lowercased, as-is) only as a last resort, when the change is confined to a single component that is not part of any larger system.
4. Use a single scope. When a change spans several systems, use the scope that owns the primary behaviour and describe the rest in the body. Avoid compound scopes (`a+b`) and comma-separated lists.
5. The scope is optional - omit it when it's repo-wide chores, formatting, typos, or dependency and version bumps, or when the subject already localizes the change.

Scopes are lowercase; spaces are allowed in multi-word names, matching the existing history (e.g. `camera animator`, `node pool`).

## Pull requests

Once your changes are ready, open a pull request.

- Keep each pull request focused on a single feature, fix, or improvement.
- Use a clear, descriptive title following the Conventional Commits format.
- Describe what changed and why.
- Link related issues. Use `Closes #42` when the pull request resolves an issue.
- Ensure existing tests pass and add tests for new functionality when applicable.
- Update documentation when introducing or changing public behavior.
- Address review feedback.

Prefer referencing issues in the pull request description when the issue is resolved by the entire pull request rather than an individual commit.
