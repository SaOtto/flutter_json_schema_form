import 'package:flutter/material.dart';
import 'package:json_schema2/json_schema2.dart';

class SchemaFormController {
  late Map<String, TextEditingController> controllers;
  late Map<String, bool> checkValues;
  late Map<String, String?> enumSelectedValues;

  SchemaFormController(JsonSchema schema) {
    controllers = {};
    checkValues = {};
    enumSelectedValues = {};
    if (schema.enumValues != null && schema.enumValues!.isNotEmpty) {
      enumSelectedValues['#'] = null;
    } else if (schema.type == SchemaType.object) {
      _fromProperties(schema.properties);
    } else if (schema.type == SchemaType.string ||
        schema.type == SchemaType.number ||
        schema.type == SchemaType.integer) {
      controllers['#'] = TextEditingController(text: schema.constValue ?? '');
    } else if (schema.type == SchemaType.boolean) {
      checkValues['#'] = false;
    }
  }

  _fromProperties(Map<String, JsonSchema> properties) {
    for (var entry in properties.entries) {
      if (entry.value.enumValues != null &&
          entry.value.enumValues!.isNotEmpty) {
        enumSelectedValues[entry.value.path!] = null;
      } else if (entry.value.type == SchemaType.object) {
        _fromProperties(entry.value.properties);
      } else if (entry.value.type == SchemaType.string ||
          entry.value.type == SchemaType.number ||
          entry.value.type == SchemaType.integer) {
        controllers[entry.value.path!] =
            TextEditingController(text: entry.value.constValue ?? '');
      } else if (entry.value.type == SchemaType.boolean) {
        checkValues[entry.value.path!] = false;
      }
    }
  }
}
