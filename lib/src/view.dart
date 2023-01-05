import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_schema2/json_schema2.dart';
import 'package:json_schema_form/src/controller.dart';
import 'package:json_schema_form/src/model.dart';

class JsonSchemaForm extends StatefulWidget {
  final JsonSchema schema;
  final SchemaFormController controller;
  final void Function(Map)? afterValidation;
  final String validationButtonText;

  const JsonSchemaForm(
      {super.key,
      required this.schema,
      required this.controller,
      this.afterValidation,
      this.validationButtonText = 'Prüfen'});

  @override
  State<StatefulWidget> createState() => JsonSchemaFormState();
}

class JsonSchemaFormState extends State<JsonSchemaForm> {
  Widget buildForm(JsonSchema schema, {bool nested = false}) {
    if (schema.type == SchemaType.object) {
      var propertyMapping = schema.properties.map(
          (key, value) => MapEntry(key, JsonSchemaPropertyEntry(value, key)));
      var propertyList = propertyMapping.values.toList();
      return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: ListView.separated(
              shrinkWrap: nested,
              physics: nested ? const ClampingScrollPhysics() : null,
              itemCount: propertyList.length,
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemBuilder: (context, index) {
                var item = propertyList[index];
                if (item.schema.enumValues != null &&
                    item.schema.enumValues!.isNotEmpty) {
                  return DropdownButtonFormField(
                      validator: (value) {
                        if (value == null) {
                          return 'Bitte Wert auswählen';
                        }
                        return null;
                      },
                      hint: Text(item.schema.description ??
                          item.schema.title ??
                          item.key),
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                      value: widget
                          .controller.enumSelectedValues[item.schema.path],
                      items: item.schema.enumValues!.map((e) {
                        return DropdownMenuItem(
                            value: jsonEncode(e),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Text(jsonEncode(e)),
                            ));
                      }).toList(),
                      onChanged: (value) {
                        widget.controller
                            .enumSelectedValues[item.schema.path!] = value!;
                        setState(() {});
                      });
                } else if (item.schema.type == SchemaType.object) {
                  return buildForm(item.schema, nested: true);
                } else if (item.schema.type == SchemaType.string ||
                    item.schema.type == SchemaType.number ||
                    item.schema.type == SchemaType.integer) {
                  return JsonSchemaTextFormField(
                      schema: item,
                      controller: widget.controller
                          .controllers[item.schema.path ?? item.key]);
                } else if (item.schema.type == SchemaType.boolean) {
                  return Row(
                    children: [
                      Text(item.schema.title ?? item.key),
                      const SizedBox(
                        width: 20,
                      ),
                      Checkbox(
                          value:
                              widget.controller.checkValues[item.schema.path],
                          onChanged: (newValue) {
                            widget.controller.checkValues[item.schema.path!] =
                                newValue!;
                            setState(() {});
                          })
                    ],
                  );
                } else {
                  return const SizedBox(
                    height: 0,
                  );
                }
              }));
    } else if (schema.type == SchemaType.string ||
        schema.type == SchemaType.number ||
        schema.type == SchemaType.integer) {
      return JsonSchemaTextFormField(
        schema: JsonSchemaPropertyEntry(schema, '#'),
        controller: widget.controller.controllers[schema.path],
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  dynamic _buildResult(JsonSchema schema) {
    if (schema.enumValues != null && schema.enumValues!.isNotEmpty) {
      return widget.controller.enumSelectedValues[schema.path];
    } else if (schema.type == SchemaType.string) {
      return widget.controller.controllers[schema.path]!.text;
    } else if (schema.type == SchemaType.integer) {
      return int.parse(widget.controller.controllers[schema.path!]!.text);
    } else if (schema.type == SchemaType.number) {
      return double.parse(widget.controller.controllers[schema.path!]!.text);
    } else if (schema.type == SchemaType.boolean) {
      return widget.controller.checkValues[schema.path];
    } else if (schema.type == SchemaType.object) {
      return schema.properties
          .map((key, value) => MapEntry(key, _buildResult(value)));
    }
  }

  void validate() {
    if (_formKey.currentState!.validate()) {
      var result = _buildResult(widget.schema);
      if (widget.afterValidation == null) {
        Navigator.of(context).pop(result);
      } else {
        widget.afterValidation!.call(result);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Form(key: _formKey, child: buildForm(widget.schema))),
      persistentFooterButtons: [
        TextButton(
            onPressed: validate, child: Text(widget.validationButtonText)),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'))
      ],
    );
  }
}

class JsonSchemaTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final JsonSchemaPropertyEntry schema;

  const JsonSchemaTextFormField(
      {super.key, required this.schema, this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: schema.schema.type == SchemaType.number ||
              schema.schema.type == SchemaType.integer
          ? (schema.schema.type == SchemaType.number
              ? const TextInputType.numberWithOptions(
                  signed: true, decimal: true)
              : const TextInputType.numberWithOptions(signed: true))
          : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bitte Wert eintragen';
        } else {
          try {
            dynamic toValidate;
            if (schema.schema.type == SchemaType.number) {
              toValidate = double.parse(value);
            } else if (schema.schema.type == SchemaType.integer) {
              toValidate = int.parse(value);
            } else {
              toValidate = value;
            }
            if (schema.schema.validate(toValidate)) {
              return null;
            } else {
              return 'Wert entspricht nicht den Vorgaben';
            }
          } catch (e) {
            return 'Wert entspricht nicht den Vorgaben';
          }
        }
      },
      decoration: InputDecoration(
          hintText: schema.schema.description,
          labelText: schema.schema.title ?? schema.key,
          border: const OutlineInputBorder()),
      controller: controller,
    );
  }
}
