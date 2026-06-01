#!/usr/bin/env python3
"""Produce a self-contained schema by inlining all imports (incl. biolink-model).

The LinkML CLI generators resolve imports inconsistently: gen-shacl/gen-linkml
rebuild a SchemaView that ignores the ``--importmap`` file and fall back to
fetching biolink-model over the network (which 404s). Building the merged
schema here via the SchemaView API — which honours a parsed importmap dict —
sidesteps that, and lets every downstream generator run against a single file
with no external imports to resolve.

Usage:
    python merge_schema.py <schema.yaml> <importmap.json> <out.yaml>
"""
import json
import sys

from linkml_runtime import SchemaView
from linkml_runtime.dumpers import yaml_dumper


def main(schema_path: str, importmap_path: str, out_path: str) -> None:
    with open(importmap_path) as f:
        importmap = json.load(f)

    sv = SchemaView(schema_path, importmap=importmap)
    sv.merge_imports()

    schema = sv.schema
    # Imports are fully inlined now; drop the list so downstream generators
    # don't try (and fail) to re-resolve biolink-model.
    schema.imports = []

    # biolink references many CURIEs (DOID, HGNC, PMID, ...) that it resolves
    # via default_curi_maps rather than inline prefixes. merge_imports drops
    # that, so carry biolink's maps onto the merged schema; otherwise every such
    # CURIE triggers an "Unrecognized prefix" warning during generation.
    if not schema.default_curi_maps:
        schema.default_curi_maps = [
            "obo_context",
            "idot_context",
            "monarch_context",
            "semweb_context",
        ]

    yaml_dumper.dump(schema, out_path)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2], sys.argv[3])
