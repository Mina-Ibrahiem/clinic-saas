import 'package:flutter/material.dart';

enum AppBreakpoint { mobile, tablet, desktop }

AppBreakpoint breakpointForWidth(double width) {
  if (width >= 1100) return AppBreakpoint.desktop;
  if (width >= 720) return AppBreakpoint.tablet;
  return AppBreakpoint.mobile;
}

extension BreakpointContext on BuildContext {
  AppBreakpoint get breakpoint => breakpointForWidth(MediaQuery.sizeOf(this).width);
}
