import 'package:flutter/material.dart';

abstract class TableWidgetColumnWidth extends TableColumnWidth {
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final double? fieldHeight;

  const TableWidgetColumnWidth({
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.all(4.0),
    this.fieldHeight,
  });
}

class FixedTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final double value;

  const FixedTableWidgetColumnWidth(
    this.value, {
    super.alignment,
    super.padding,
    super.fieldHeight,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value;
  }
}

class FlexTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final double value;

  const FlexTableWidgetColumnWidth(
    this.value, {
    super.alignment,
    super.padding,
    super.fieldHeight,
  });

  @override
  double flex(Iterable<RenderBox> cells) {
    return value;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 0.0;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 0.0;
  }
}

class FractionTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final double value;

  const FractionTableWidgetColumnWidth(
    this.value, {
    super.alignment,
    super.padding,
    super.fieldHeight,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value * containerWidth;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value * containerWidth;
  }
}

class IntrinsicTableWidgetColumnWidth extends TableWidgetColumnWidth {
  const IntrinsicTableWidgetColumnWidth({
    super.alignment,
    super.padding,
    super.fieldHeight,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double maxIntrinsicWidth = 0.0;
    for (final RenderBox cell in cells) {
      maxIntrinsicWidth =
          maxIntrinsicWidth > cell.getMaxIntrinsicWidth(double.infinity)
          ? maxIntrinsicWidth
          : cell.getMaxIntrinsicWidth(double.infinity);
    }
    return maxIntrinsicWidth;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double minIntrinsicWidth = 0.0;
    for (final RenderBox cell in cells) {
      minIntrinsicWidth =
          minIntrinsicWidth > cell.getMinIntrinsicWidth(double.infinity)
          ? minIntrinsicWidth
          : cell.getMinIntrinsicWidth(double.infinity);
    }
    return minIntrinsicWidth;
  }
}

class MaxTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final TableColumnWidth a;
  final TableColumnWidth b;

  const MaxTableWidgetColumnWidth(
    this.a,
    this.b, {
    super.alignment,
    super.padding,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.maxIntrinsicWidth(cells, containerWidth) >
            b.maxIntrinsicWidth(cells, containerWidth)
        ? a.maxIntrinsicWidth(cells, containerWidth)
        : b.maxIntrinsicWidth(cells, containerWidth);
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.minIntrinsicWidth(cells, containerWidth) >
            b.minIntrinsicWidth(cells, containerWidth)
        ? a.minIntrinsicWidth(cells, containerWidth)
        : b.minIntrinsicWidth(cells, containerWidth);
  }
}

class MinTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final TableColumnWidth a;
  final TableColumnWidth b;

  const MinTableWidgetColumnWidth(
    this.a,
    this.b, {
    super.alignment,
    super.padding,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.maxIntrinsicWidth(cells, containerWidth) <
            b.maxIntrinsicWidth(cells, containerWidth)
        ? a.maxIntrinsicWidth(cells, containerWidth)
        : b.maxIntrinsicWidth(cells, containerWidth);
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.minIntrinsicWidth(cells, containerWidth) <
            b.minIntrinsicWidth(cells, containerWidth)
        ? a.minIntrinsicWidth(cells, containerWidth)
        : b.minIntrinsicWidth(cells, containerWidth);
  }
}

class TableWidget<T> extends StatelessWidget {
  final Map<int, TableWidgetColumnWidth> columns;
  final void Function(T item)? onTapRow;
  final void Function(T item)? onDoubleTap;
  final void Function(T item)? onLongPressed;
  final List<Widget> Function(BuildContext context, T item, int index) builder;
  final List<String> header;
  final List<T> items;
  final double borderThickness;
  final Color? rowColor;
  final bool Function(T item, int index)? paintRowColorWhen;
  final double? minWidth;
  final ScrollPhysics? physics;
  final bool? shrinkWrap;
  final TextStyle? headerTextStyle;
  final List<Widget> Function(BuildContext context)? footerBuilder;

  const TableWidget({
    super.key,
    required this.columns,
    this.onTapRow,
    this.onDoubleTap,
    this.onLongPressed,
    required this.builder,
    required this.header,
    required this.items,
    this.borderThickness = 0.50,
    this.paintRowColorWhen,
    this.rowColor,
    this.minWidth,
    this.physics,
    this.shrinkWrap,
    this.headerTextStyle,
    this.footerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveShrinkWrap =
            shrinkWrap == true || !constraints.hasBoundedHeight;
        final body = _buildBody(context, effectiveShrinkWrap);

        Widget child = Column(
          mainAxisSize: effectiveShrinkWrap
              ? MainAxisSize.min
              : MainAxisSize.max,
          children: [
            _buildHeader(context),
            if (effectiveShrinkWrap) body else Expanded(child: body),
            if (footerBuilder != null) _buildFooter(context),
          ],
        );

        if (minWidth != null) {
          child = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth!),
              child: SizedBox(width: minWidth, child: child),
            ),
          );
        }

        return child;
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme;
    return Table(
      border: TableBorder(
        top: BorderSide(width: borderThickness, color: colors.outline),
        verticalInside: BorderSide(
          width: borderThickness,
          color: colors.outline,
        ),
        bottom: BorderSide(width: borderThickness, color: colors.outline),

        right: BorderSide(width: borderThickness, color: colors.outline),
        left: BorderSide(width: borderThickness, color: colors.outline),
      ),
      defaultVerticalAlignment: .middle,
      columnWidths: columns,
      children: [
        TableRow(
          children: header.asMap().entries.map((entry) {
            final title = entry.value;
            return Container(
              alignment: AlignmentDirectional.center,
              padding: EdgeInsets.all(8.0),
              child: Text(
                title,
                style:
                    headerTextStyle ??
                    style.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final widgets = footerBuilder!(context);
    
    return Material(
      color: colors.primary.withValues(alpha: 0.1),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: columns,
        border: TableBorder(
          bottom: BorderSide(width: borderThickness, color: colors.outline),
          right: BorderSide(width: borderThickness, color: colors.outline),
          left: BorderSide(width: borderThickness, color: colors.outline),
          verticalInside: BorderSide(width: borderThickness, color: colors.outline),
        ),
        children: [
          TableRow(
            children: List.generate(columns.values.length, (indexOfField) {
              final column = columns[indexOfField];
              if (column == null || indexOfField >= widgets.length) {
                return const SizedBox.shrink();
              }
              return Container(
                height: column.fieldHeight,
                padding: column.padding,
                alignment: column.alignment,
                child: widgets[indexOfField],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool effectiveShrinkWrap) {
    final style = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: effectiveShrinkWrap,
      physics: effectiveShrinkWrap
          ? const NeverScrollableScrollPhysics()
          : physics ?? const ClampingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          Divider(color: style.outline, height: 1),
      itemBuilder: (context, index) {
        return _buildRow(context, style, Theme.of(context).textTheme, index);
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    ColorScheme colors,
    TextTheme style,
    int indexOfRow,
  ) {
    final item = items[indexOfRow];
    final widgets = builder(context, item, indexOfRow);
    final rowColorValue = paintRowColorWhen != null
        ? (paintRowColorWhen!(item, indexOfRow) ? rowColor : null)
        : rowColor;

    return Material(
      color: rowColorValue,
      child: InkWell(
        onTap: onTapRow == null ? null : () => onTapRow!(item),
        onDoubleTap: onDoubleTap == null ? null : () => onDoubleTap!(item),
        onLongPress: onLongPressed == null ? null : () => onLongPressed!(item),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columns,
          border: TableBorder(
            verticalInside: BorderSide(
              width: borderThickness,
              color: colors.outline,
            ),
            bottom: indexOfRow == items.length - 1
                ? BorderSide(width: borderThickness, color: colors.outline)
                : BorderSide.none,
            right: BorderSide(width: borderThickness, color: colors.outline),
            left: BorderSide(width: borderThickness, color: colors.outline),
          ),
          children: [
            TableRow(
              children: List.generate(columns.values.length, (indexOfField) {
                final column = columns[indexOfField];
                if (column == null || indexOfField >= widgets.length) {
                  return Container(
                    color: colors.error,
                    height: column?.fieldHeight,
                    padding: EdgeInsets.all(4.0),
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      'لم يتم اضافة الحقل هنا',
                      style: style.bodySmall?.copyWith(color: colors.onError),
                    ),
                  );
                }
                return Container(
                  height: column.fieldHeight,
                  padding: column.padding,
                  alignment: column.alignment,
                  child: widgets[indexOfField],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
