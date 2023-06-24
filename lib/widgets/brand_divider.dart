//t2 Core Packages Imports
import 'package:flutter/material.dart';

//t2 Dependancies Imports
//t3 Services
//t3 Models
//t1 Exports
class BrandDivider extends StatelessWidget {
  //SECTION - Widget Arguments
  //!SECTION
  //
  const BrandDivider({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    //SECTION - Build Setup
    //t2 -Values
    //double w = MediaQuery.of(context).size.width;
    //double h = MediaQuery.of(context).size.height;
    //t2 -Values
    //
    //t2 -Widgets
    //t2 -Widgets
    //!SECTION

    //SECTION - Build Return
    return Divider(
      height: 1,
      color: Color(0xFFe2e2e2),
      thickness: 1.0,
    );
    //!SECTION
  }
}
