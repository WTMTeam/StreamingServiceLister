import 'package:flutter/material.dart';

Widget optionsModal(BuildContext context, Function(String) onOptionSelected) {
  final List<String> options = ["Stream", "Buy", "Rent"];

  Icon getIconForOption(String option) {
    switch (option) {
      case "Stream":
        return Icon(Icons.live_tv,
            color: Theme.of(context).colorScheme.primary);
      case "Buy":
        return Icon(Icons.shopping_cart,
            color: Theme.of(context).colorScheme.primary);
      case "Rent":
        return Icon(Icons.local_movies_outlined,
            color: Theme.of(context).colorScheme.primary);
      default:
        return Icon(Icons.error, color: Theme.of(context).colorScheme.primary);
    }
  }

  return Padding(
    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
    child: ListView.separated(
      shrinkWrap: true,
      itemCount: options.length,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(context).canvasColor,
        thickness: 1,
        indent: 12,
        endIndent: 12,
      ),
      itemBuilder: (context, index) {
        return ListTile(
          leading: getIconForOption(options[index]),
          title: Text(
            options[index],
            style: Theme.of(context).textTheme.labelMedium,
          ),
          onTap: () {
            onOptionSelected(options[index]);
            Navigator.pop(context);
            print("Switched to ${options[index]} list");
          },
        );
      },
    ),
  );
}
