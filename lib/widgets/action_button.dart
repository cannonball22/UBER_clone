import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String buttonTitle;
  final Function()? onPressed;
  final Color buttonColor;

  const ActionButton({
    super.key,
    required this.buttonTitle,
    required this.buttonColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(buttonColor),
        ),
        onPressed: onPressed,
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              buttonTitle,
              style: const TextStyle(
                  fontSize: 18, fontFamily: "Brand-Bold", color: Colors.white),
            ),
          ),
        ));
  }
}
