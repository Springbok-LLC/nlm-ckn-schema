SCHEMA := ckn-schema.yaml
SRC    := src/ckn_schema

.PHONY: all clean copy-schema gen-pydantic gen-shacl gen-json-schema validate

all: copy-schema gen-pydantic gen-shacl gen-json-schema

copy-schema:
	cp $(SCHEMA) $(SRC)/schema/ckn_schema.yaml

gen-pydantic: copy-schema
	uv run gen-pydantic --meta full $(SCHEMA) > $(SRC)/pydantic/ckn_schema.py.tmp
	mv $(SRC)/pydantic/ckn_schema.py.tmp $(SRC)/pydantic/ckn_schema.py

gen-shacl: copy-schema
	uv run gen-shacl $(SCHEMA) > $(SRC)/shacl/ckn_schema.shacl.ttl.tmp
	mv $(SRC)/shacl/ckn_schema.shacl.ttl.tmp $(SRC)/shacl/ckn_schema.shacl.ttl

gen-json-schema: copy-schema
	uv run gen-json-schema $(SCHEMA) > $(SRC)/jsonschema/ckn_schema.json.tmp
	mv $(SRC)/jsonschema/ckn_schema.json.tmp $(SRC)/jsonschema/ckn_schema.json

validate: all
	uv run python validate_artifacts.py

clean:
	rm -f $(SRC)/schema/ckn_schema.yaml
	rm -f $(SRC)/pydantic/ckn_schema.py $(SRC)/pydantic/ckn_schema.py.tmp
	rm -f $(SRC)/shacl/ckn_schema.shacl.ttl $(SRC)/shacl/ckn_schema.shacl.ttl.tmp
	rm -f $(SRC)/jsonschema/ckn_schema.json $(SRC)/jsonschema/ckn_schema.json.tmp
