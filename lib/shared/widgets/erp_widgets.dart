import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';

/// Page title row: big uppercase title on the left, action buttons on the
/// right, optional close (X) button.
class ErpPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onClose;

  const ErpPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: AppTheme.textMain,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    subtitle!,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
                  ),
                ),
            ],
          ),
        ),
        Wrap(spacing: 8.w, children: actions),
        if (onClose != null) ...[
          SizedBox(width: 8.w),
          IconButton(
            onPressed: onClose,
            tooltip: 'Close (Esc)',
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ],
    );
  }
}

/// Outlined header action (Print / Preview / Email style).
class ErpHeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const ErpHeaderButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      ),
    );
  }
}

/// White bordered panel. Optional blue section [title] shown above the body.
class ErpPanel extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;

  const ErpPanel({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor ?? AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(child: ErpSectionTitle(title!)),
                if (trailing != null) trailing!,
              ],
            ),
            SizedBox(height: 10.h),
          ],
          child,
        ],
      ),
    );
  }
}

/// Blue section label, e.g. "MATERIAL DETAILS".
class ErpSectionTitle extends StatelessWidget {
  final String text;
  const ErpSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: AppTheme.primaryBlue,
      ),
    );
  }
}

/// Label on the left, control on the right – the classic ERP form row.
class ErpField extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;
  final double labelWidth;

  const ErpField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.labelWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: labelWidth.w,
            child: Text.rich(
              TextSpan(
                text: label,
                children: [
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppTheme.dangerRed),
                    ),
                ],
              ),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMain,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Lays children out in equal-width columns with a gap between them.
/// Collapses to a single column on narrow widths.
class ErpColumns extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final double collapseBelow;

  const ErpColumns({
    super.key,
    required this.children,
    this.gap = 24,
    this.collapseBelow = 760,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < collapseBelow) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap.w),
            Expanded(child: children[i]),
          ],
        ],
      );
    });
  }
}

/// Label / amount line used in totals panels.
class ErpTotalLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const ErpTotalLine({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color ?? AppTheme.textMain,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// Fixed bottom bar with Cancel / Save buttons, like the reference screen.
class ErpActionBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSaveAndNew;
  final VoidCallback? onSaveAndClose;
  final bool loading;
  final String saveLabel;

  const ErpActionBar({
    super.key,
    required this.onCancel,
    this.onSaveAndNew,
    this.onSaveAndClose,
    this.loading = false,
    this.saveLabel = 'Save & Close',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Ctrl + Enter to save  ·  Esc to cancel',
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
          ),
          const Spacer(),
          OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
          if (onSaveAndNew != null) ...[
            SizedBox(width: 10.w),
            FilledButton(
              onPressed: loading ? null : onSaveAndNew,
              child: const Text('Save & New'),
            ),
          ],
          SizedBox(width: 10.w),
          FilledButton(
            onPressed: loading ? null : onSaveAndClose,
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.successGreen),
            child: loading
                ? SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(saveLabel),
          ),
        ],
      ),
    );
  }
}
