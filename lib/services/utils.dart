import 'package:flutter/widgets.dart';

const kTabletContainerWidth = 350.0;

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >= 901.0;
}
