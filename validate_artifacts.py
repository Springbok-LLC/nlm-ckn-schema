#!/usr/bin/env python3
import sys
import json
import jsonschema
import rdflib

errors = []

# Pydantic model — import catches syntax and forward-ref errors
try:
    sys.path.insert(0, "src")
    import ckn_schema.pydantic.ckn_schema  # noqa: F401
    print("pydantic: ok")
except Exception as e:
    errors.append(f"pydantic: {e}")
    print(f"pydantic: FAILED — {e}")

# SHACL — parse catches malformed Turtle
try:
    g = rdflib.Graph()
    g.parse("src/ckn_schema/shacl/ckn_schema.shacl.ttl", format="turtle")
    print(f"shacl: ok ({len(g)} triples)")
except Exception as e:
    errors.append(f"shacl: {e}")
    print(f"shacl: FAILED — {e}")

# JSON Schema — catches invalid JSON and malformed schema structure
try:
    with open("src/ckn_schema/jsonschema/ckn_schema.json") as f:
        schema = json.load(f)
    jsonschema.Draft7Validator.check_schema(schema)
    print("json schema: ok")
except Exception as e:
    errors.append(f"json schema: {e}")
    print(f"json schema: FAILED — {e}")

if errors:
    sys.exit(1)
