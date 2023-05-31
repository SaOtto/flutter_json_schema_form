import 'package:flutter/material.dart';
import 'package:json_schema2/json_schema2.dart';
import 'package:json_schema_form/json_schema_form.dart';

var schema = JsonSchema.createSchema({
  "\$id": "https://example.com/person.schema.json",
  "title": "Person",
  "type": "object",
  "properties": {
    "firstName": {"type": "string", "description": "The person's first name."},
    "lastName": {"type": "string", "description": "The person's last name."},
    'testConstValue': {'type': 'string', 'const': 'Test'},
    'birthDate': {'type': 'string', 'format': 'date-time'},
    "age": {
      "description":
          "Age in years which must be equal to or greater than zero.",
      "type": "integer",
      "minimum": 0
    },
    "role": {
      "enum": ['Mama', 'Papa', 43]
    },
    "friend": {
      "type": "object",
      "properties": {
        "firstName": {
          "type": "string",
          "description": "The person's first name."
        },
        "lastName": {
          "type": "string",
          "description": "The person's last name."
        },
        "age": {
          "description":
              "Age in years which must be equal to or greater than zero.",
          "type": "integer",
          "minimum": 0
        },
        "isBestFriend": {'type': 'boolean'}
      }
    }
  }
});

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          // Using Json schema Form Widget
          child: JsonSchemaForm(
        schema: schema,
        controller: SchemaFormController(schema),
      )),
    );
  }
}
