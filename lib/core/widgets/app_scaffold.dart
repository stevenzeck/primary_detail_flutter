import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/platform_utils.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isCupertino = PlatformUtils.isApple;

    if (isCupertino) {
      return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          middle: title,
          backgroundColor: backgroundColor?.withValues(alpha: 0.9),
          automaticallyImplyLeading: automaticallyImplyLeading,
          leading: leading,
          // Cupertino only takes one trailing widget, so we wrap actions in a Row
          trailing: actions != null && actions!.isNotEmpty
              ? Row(
                  mainAxisSize: .min,
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .end,
                  children: actions!,
                )
              : null,
        ),
        child: SafeArea(child: body),
      );
    }

    // Material Design
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: title,
        leading: leading,
        actions: actions,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
