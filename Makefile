SCHEMA    := ckn-schema.yaml
SRC       := src/ckn_schema
IMPORTMAP := build/importmap.json
MERGED    := build/ckn_merged.yaml

.PHONY: all clean importmap merged copy-schema gen-pydantic gen-shacl gen-json-schema validate

all: copy-schema gen-pydantic gen-shacl gen-json-schema

# Resolve the installed biolink_model schema dir and emit an absolute-path
# importmap. biolink_model is a namespace package (no __file__), so locate it
# via __path__. Both `biolink:biolink-model` and its nested `attributes` import
# must be mapped. Regenerated every build, so paths are never stale or committed.
importmap:
	mkdir -p build
	uv run python -c "import json, os, biolink_model; \
d = os.path.join(next(iter(biolink_model.__path__)), 'schema'); \
print(json.dumps({'biolink:biolink-model': os.path.join(d, 'biolink_model'), \
'attributes': os.path.join(d, 'attributes')}))" > $(IMPORTMAP)

# Inline biolink-model into a single self-contained schema. All generators run
# against this so none has to resolve the biolink import itself (see
# merge_schema.py for why the CLI's --importmap handling is unreliable here).
merged: importmap
	uv run python merge_schema.py $(SCHEMA) $(IMPORTMAP) $(MERGED)

# Ship the merged (self-contained) schema so consumers can load it without
# biolink-model or an importmap.
copy-schema: merged
	cp $(MERGED) $(SRC)/schema/ckn_schema.yaml

gen-pydantic: merged
	uv run gen-pydantic $(MERGED) > $(SRC)/pydantic/ckn_schema.py.tmp
	mv $(SRC)/pydantic/ckn_schema.py.tmp $(SRC)/pydantic/ckn_schema.py

gen-shacl: merged
	uv run gen-shacl $(MERGED) > $(SRC)/shacl/ckn_schema.shacl.ttl.tmp
	mv $(SRC)/shacl/ckn_schema.shacl.ttl.tmp $(SRC)/shacl/ckn_schema.shacl.ttl

gen-json-schema: merged
	uv run gen-json-schema $(MERGED) > $(SRC)/jsonschema/ckn_schema.json.tmp
	mv $(SRC)/jsonschema/ckn_schema.json.tmp $(SRC)/jsonschema/ckn_schema.json

validate: all
	uv run python validate_artifacts.py

clean:
	rm -rf build
	rm -f $(SRC)/schema/ckn_schema.yaml
	rm -f $(SRC)/pydantic/ckn_schema.py $(SRC)/pydantic/ckn_schema.py.tmp
	rm -f $(SRC)/shacl/ckn_schema.shacl.ttl $(SRC)/shacl/ckn_schema.shacl.ttl.tmp
	rm -f $(SRC)/jsonschema/ckn_schema.json $(SRC)/jsonschema/ckn_schema.json.tmp
