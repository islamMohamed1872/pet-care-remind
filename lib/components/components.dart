import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


Widget defaultField({
  required String hint,
  required TextEditingController controller,
  required FormFieldValidator validator,
  IconData? prefixIcon,
  IconData? suffixIcon,
  required bool obscureText,
  VoidCallback? onPressedSuffix,
  VoidCallback? onPressedPrefix,
  GestureTapCallback? onTap,
  ValueChanged? onChange,
  bool? readOnly,
})=>
    TextFormField(
      readOnly: readOnly ?? false,
      onChanged: onChange,
      onTap: onTap,
      textAlign: TextAlign.start,
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),
      cursorColor: Colors.green,
      decoration: InputDecoration(
        prefixStyle: const TextStyle(
          color: Colors.black,
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.black, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
        errorStyle: const TextStyle(
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:  BorderSide(
            color: Colors.grey.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
    );


void navigateTo(context,widget)=>Navigator.push(context, MaterialPageRoute(builder: (context) => widget,));
void navigateAndFinish(context,widget)=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget,));


Widget divider()=>Padding(
  padding: const EdgeInsetsDirectional.symmetric(vertical:20.0),
  child: Container(
    width: double.infinity,
    height: 1,
    color: Colors.grey.withOpacity(0.3),
  ),
);