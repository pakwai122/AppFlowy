import 'package:appflowy/mobile/presentation/base/app_bar_actions.dart';
import 'package:appflowy/plugins/base/drag_handler.dart';
import 'package:flowy_infra/size.dart';
import 'package:flowy_infra_ui/flowy_infra_ui.dart' hide WidgetBuilder;
import 'package:flutter/material.dart';

Future<T?> showMobileBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool useSafeArea = true,
  bool isDragEnabled = true,
  bool showDragHandle = false,
  bool showHeader = false,
  // this field is only used if showHeader is true
  bool showBackButton = false,
  bool showCloseButton = false,
  // this field is only used if showHeader is true
  String title = '',
  bool resizeToAvoidBottomInset = true,
  bool isScrollControlled = true,
  bool showDivider = true,
  bool useRootNavigator = false,
  ShapeBorder? shape,
  // the padding of the content, the padding of the header area is fixed
  EdgeInsets padding = EdgeInsets.zero,
  Color? backgroundColor,
  BoxConstraints? constraints,
  Color? barrierColor,
  double? elevation,
  bool showDoneButton = false,
  bool enableDraggableScrollable = false,
  // only used when enableDraggableScrollable is true
  double minChildSize = 0.5,
  double maxChildSize = 0.8,
  double initialChildSize = 0.51,
}) async {
  assert(
    showHeader ||
        title.isEmpty && !showCloseButton && !showBackButton && !showDoneButton,
  );
  assert(!(showCloseButton && showBackButton));

  shape ??= const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Corners.s12Radius,
    ),
  );

  backgroundColor ??= Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFF7F8FB)
      : const Color(0xFF626364);

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    enableDrag: isDragEnabled,
    useSafeArea: true,
    clipBehavior: Clip.antiAlias,
    constraints: constraints,
    barrierColor: barrierColor,
    elevation: elevation,
    backgroundColor: backgroundColor,
    shape: shape,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final List<Widget> children = [];

      final Widget child = builder(context);

      // if the children is only one, we don't need to wrap it with a column
      if (!showDragHandle &&
          !showHeader &&
          !showDivider &&
          !resizeToAvoidBottomInset) {
        return child;
      }

      // ----- header area -----
      if (showDragHandle) {
        children.add(
          const DragHandler(),
        );
      }

      if (showHeader) {
        children.add(
          _Header(
            showCloseButton: showCloseButton,
            showBackButton: showBackButton,
            showDoneButton: showDoneButton,
            title: title,
          ),
        );

        if (showDivider) {
          children.add(
            const Divider(height: 0.5, thickness: 0.5),
          );
        }
      }

      // ----- header area -----

      if (enableDraggableScrollable) {
        return DraggableScrollableSheet(
          expand: false,
          snap: true,
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          builder: (context, scrollController) {
            return Column(
              children: [
                ...children,
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
      }

      // ----- content area -----
      if (resizeToAvoidBottomInset) {
        children.add(
          Padding(
            padding: EdgeInsets.only(
              top: padding.top,
              left: padding.left,
              right: padding.right,
              bottom: padding.bottom + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: child,
          ),
        );
      } else {
        children.add(child);
      }
      // ----- content area -----

      if (children.length == 1) {
        return children.first;
      }

      // add default padding
      children.add(
        VSpace(MediaQuery.of(context).padding.bottom == 0 ? 28.0 : 16.0),
      );

      return useSafeArea
          ? SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            );
    },
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.showBackButton,
    required this.showCloseButton,
    required this.title,
    required this.showDoneButton,
  });

  final bool showBackButton;
  final bool showCloseButton;
  final String title;
  final bool showDoneButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: SizedBox(
        height: 44.0, // the height of the header area is fixed
        child: Stack(
          children: [
            if (showBackButton)
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBarBackButton(),
              ),
            if (showCloseButton)
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBarCloseButton(),
              ),
            Align(
              child: FlowyText(
                title,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showDoneButton)
              Align(
                alignment: Alignment.centerRight,
                child: AppBarDoneButton(
                  onTap: () => Navigator.pop(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
