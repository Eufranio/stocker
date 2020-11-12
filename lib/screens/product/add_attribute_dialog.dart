import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocker/components/models/attribute_type.dart';
import 'package:stocker/components/models/product.dart';
import 'package:stocker/components/models/product_attribute.dart';
import 'package:stocker/components/models/store.dart';
import 'package:stocker/components/viewmodels/product/add_attribute_dialog_view_model.dart';
import 'package:stocker/components/widgets/stream_utils.dart';

class AddAttributeDialog extends StatefulWidget {

  final AddAttributeDialogViewModel viewModel;

  AddAttributeDialog(Product product, Store store, DocumentReference userRef)
      : viewModel = AddAttributeDialogViewModel(product, store, userRef);

  @override
  State createState() => _AddAttributeDialogState();
}

class _AddAttributeDialogState extends State<AddAttributeDialog> {

  @override
  Widget build(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    return AlertDialog(
      title: Text('Novo Atributo'),
      content: Form(key: formKey, child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Text('Tipo')
              ),
              Expanded(child: widget.viewModel.attributeTypes.streamBuilder((attributes) => IgnorePointer(
                ignoring: widget.viewModel.ignoreAttributeTypeField,
                child: DropdownButtonFormField<AttributeType>(
                  items: attributes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name)
                  )).toList(),
                  validator: widget.viewModel.validateAttributeType,
                  onChanged: widget.viewModel.ignoreAttributeTypeField ? null : (val) {
                    widget.viewModel.selectedAttributeType = val;
                    setState(() {});
                  },
                  disabledHint: Text(widget.viewModel.selectedAttributeType?.name ?? '...'),
                ),
              )))
            ],
          ),
          Row(
            children: [
              Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Text('Valor')
              ),
              Expanded(child: widget.viewModel.productAttributes.streamBuilder((attributes) => DropdownButtonFormField<ProductAttribute>(
                items: attributes.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.value)
                )).toList(),
                validator: (attribute) => widget.viewModel.validateProductAttribute(attribute, attributes),
                onChanged: (attribute) => setState(() {
                  widget.viewModel.selectedProductAttribute = attribute;
                }),
                autovalidate: true,
                onSaved: (attribute) => widget.viewModel.selectedProductAttribute = attribute,
              ))
              )
            ],
          )
        ],
      )),
      actions: [
        FlatButton(
          child: Text('Salvar'),
          onPressed: () {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
              widget.viewModel.saveSelectedAttribute()
                  .then((value) => Navigator.pop(context));
            }
          },
        )
      ],
    );
  }
}