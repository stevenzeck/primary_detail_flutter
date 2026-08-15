import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/platform_utils.dart';

class AdaptiveDialogAction extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool isDestructive;

  const AdaptiveDialogAction({
    super.key,
    required this.child,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isApple) {
      return CupertinoDialogAction(
        onPressed: onPressed,
        isDestructiveAction: isDestructive,
        child: child,
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: isDestructive
          ? TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            )
          : null,
      child: child,
    );
  }
}
