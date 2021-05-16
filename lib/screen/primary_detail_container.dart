import 'package:flutter/material.dart';

import '../services/utils.dart';
import 'primary_page.dart';

class PrimaryDetailContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
                width: isTablet(context)
                    ? kTabletContainerWidth
                    : MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: PrimaryPage())
          ],
        ));
  }
}
