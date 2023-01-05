# json_schema_form
This package is able to render a material form based on a json schema definition.
It is based on the json schema implementation of the package [json_schema2](https://pub.dev/packages/json_schema2).

# Usage
```
var schema = JsonSchema.createSchema('...');

...
//e.g. inside a Scaffolds body
body : JsonSchemaForm(
        schema: schema,
        controller: SchemaFormController(schema),
      ),
...
```

Please check out the example folder for a working demo.

# Notes
- handling of array type is not implemented yet