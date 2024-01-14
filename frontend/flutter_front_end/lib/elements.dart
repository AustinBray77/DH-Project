import 'package:flutter/material.dart';

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.child
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.background, 
      child: Padding( 
          padding: const EdgeInsets.all(20),
          child: child
        )
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({super.key, required this.value, required this.validator, required this.label, required this.icon, required this.password});

  final String? Function(String?) validator;
  final Widget label;
  final Widget icon;
  final bool password;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextFormField(
          initialValue: value,
          validator: validator,
          decoration: InputDecoration(
            label: label,
            icon: icon,
          ),
          obscureText: password,
          enableSuggestions: !password,
          autocorrect: !password,
        ),
      )
    );
  }
}

class ReportCatDialog extends StatelessWidget {
  ReportCatDialog({
    super.key,
    required this.sendReport
  });

  final void Function (String, String) sendReport;

  var description = "";
  var color = "";
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return 
    Dialog(
      backgroundColor: Theme.of(context).primaryColorLight,
      child: Column( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ Form(
          key: _formKey,
          child: Column(
            children: [
              InputField(
                value: description,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Please enter a value.";
                  }
                  description = value;
                  return null;
                }, 
                label: const Text("Description"), 
                icon: const Icon(Icons.abc), 
                password: false
              ),
              InputField(
                value: color,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Please enter a value.";
                  }
                  color = value;
                  return null;
                }, 
                label: const Text("Color"), 
                icon: const Icon(Icons.format_paint), 
                password: false
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () { 
                      if(_formKey.currentState!.validate()) {
                        sendReport(description, color);
                        Navigator.of(context).pop();
                      } 
                    }, 
                    child: const Text("Submit")
                    ),
                  ElevatedButton(onPressed: () { Navigator.of(context).pop(); }, child: const Text("Cancel"))
                ]
                )
              ],
            ),
          ),
        ]
      ),
    );
  }
}