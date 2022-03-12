import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final bool isChecked;
  final String taskTitle;
  final dynamic checkboxCallback;
  final dynamic longPressCallback;
  TaskTile({
    required this.isChecked,
    required this.taskTitle,
    this.checkboxCallback,
    this.longPressCallback,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: longPressCallback,
      title: Text(
        taskTitle,
        style: TextStyle(
            decoration: isChecked ? TextDecoration.lineThrough : null),
      ),
      trailing: Checkbox(
        activeColor: Colors.lightBlueAccent,
        value: isChecked,
        onChanged: checkboxCallback,
      ),
    );
  }
}
// (newValue) {
//             setState(() {
//               isChecked = newValue;
//             });
//           }

// class TaskCheckBox extends StatelessWidget {
//   TaskCheckBox({this.checkboxState, this.toggleCheckboxState});
//   late final bool? checkboxState;
//   final dynamic toggleCheckboxState;
//   @override
//   Widget build(BuildContext context) {
//     return Checkbox(
//         activeColor: Colors.lightBlueAccent,
//         value: checkboxState,
//         onChanged: toggleCheckboxState);
//   }
// }
