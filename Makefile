SCHEMA := ckn-schema.yaml
SRC    := src/ckn_schema

.PHONY: all clean copy-schema gen-pydantic gen-shacl gen-json-schema

all: copy-schema gen-pydantic gen-shacl gen-json-schema

copy-schema:
	cp $(SCHEMA) $(SRC)/schema/ckn_schema.yaml

gen-pydantic: copy-schema
	uv run gen-pydantic --meta full $(SCHEMA) > $(SRC)/pydantic/ckn_schema.py

gen-shacl: copy-schema
	uv run gen-shacl $(SCHEMA) > $(SRC)/shacl/ckn_schema.shacl.ttl

gen-json-schema: copy-schema
	uv run gen-json-schema $(SCHEMA) > $(SRC)/jsonschema/ckn_schema.json

clean:
	rm -f $(SRC)/schema/ckn_schema.yaml
	rm -f $(SRC)/pydantic/ckn_schema.py
	rm -f $(SRC)/shacl/ckn_schema.shacl.ttl
	rm -f $(SRC)/jsonschema/ckn_schema.json
