# cell-kn-schema

A [LinkML](https://linkml.io/) data model for cell phenotypes and biological entities,
structured as a [Biolink Model](https://biolink.github.io/biolink-model/) extension: it
imports `biolink-model`, its node classes (`Ckn*`) are subclasses of Biolink categories,
and its association predicates reference Biolink predicates.

The schema is defined in [`ckn-schema.yaml`](ckn-schema.yaml). The build first inlines
`biolink-model` into a single self-contained schema (`build/ckn_merged.yaml`, via
[`merge_schema.py`](merge_schema.py)), then generates Pydantic models, SHACL shapes, and
JSON Schema from it. The merged schema (not the import-bearing source) is what ships in the
package, so consumers can load it without `biolink-model` or an importmap.

## Prerequisites

- [uv](https://docs.astral.sh/uv/) — Python package manager

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv sync --extra dev
```

## Makefile

| Target | Description |
|---|---|
| `make` / `make all` | Generate all artifacts from the schema |
| `make validate` | Generate all artifacts, then run validation checks |
| `make clean` | Remove all generated artifacts |

## Workflows

### `validate.yml`
Runs on every push. Generates artifacts and validates them.

### `publish.yml`
Runs on release. Generates artifacts, builds the Python package, and attaches it to the GitHub release.

To trigger a release, create and publish a GitHub release with a version tag (e.g. `v1.2.0`). See [GitHub's release documentation](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

### `promote-to-upstream.yml`
Runs on pushes to `main` (Springbok-LLC fork only). Opens or updates a pull request on NIH-NLM upstream for manual review and merge.

> **Note:** The `UPSTREAM_PR_TOKEN` secret must be configured on the fork for this workflow to function.
