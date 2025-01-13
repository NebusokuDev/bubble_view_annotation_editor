import 'package:flutter/material.dart';

class RangeSelection extends StatefulWidget {
  final Widget child; // 選択可能エリアとなるウィジェット
  final void Function(Rect bounds) onBoundsChanged; // バウンディングボックス範囲のコールバック

  const RangeSelection({
    Key? key,
    required this.child,
    required this.onBoundsChanged,
  }) : super(key: key);

  @override
  State<RangeSelection> createState() => _RangeSelectionState();
}

class _RangeSelectionState extends State<RangeSelection> {
  Offset? _startPosition;
  Offset? _currentPosition;

  // childの位置とサイズ情報
  Rect? _childBounds;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) {
            // 子ウィジェットの範囲内でドラッグ開始（グローバル座標を調整）
            _updateChildBounds(context);
            if (_childBounds?.contains(details.localPosition) ?? false) {
              setState(() {
                _startPosition = details.localPosition;
                _currentPosition = details.localPosition;
              });

              _invokeBoundsCallback();
            }
          },
          onPanUpdate: (details) {
            // 子ウィジェットの範囲内でドラッグ中
            if (_startPosition != null) {
              setState(() {
                _currentPosition = details.localPosition;
              });
              _invokeBoundsCallback();
            }
          },
          onPanEnd: (details) {
            // ドラッグ終了時は座標をリセット
            setState(() {
              _startPosition = null;
              _currentPosition = null;
            });
            _invokeBoundsCallback(); // 最終状態を通知
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  clipBehavior: Clip.hardEdge, // 子ウィジェットの図形でクリップ
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // 必須、ジェスチャーを有効化
                  ),
                  child: widget.child,
                ),
              ),
              if (_startPosition != null && _currentPosition != null)
                _buildBoundingBox(),
            ],
          ),
        );
      },
    );
  }

  // 現在のchild範囲に基づいてバウンディングボックスを描画
  Widget _buildBoundingBox() {
    final rect = Rect.fromLTRB(
      _clamp(_startPosition!.dx, _childBounds!.left, _childBounds!.right),
      _clamp(_startPosition!.dy, _childBounds!.top, _childBounds!.bottom),
      _clamp(_currentPosition!.dx, _childBounds!.left, _childBounds!.right),
      _clamp(_currentPosition!.dy, _childBounds!.top, _childBounds!.bottom),
    );

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3), // 半透明の青色
          border: Border.all(
            color: Colors.blue, // 枠線
            width: 2.0,
          ),
        ),
      ),
    );
  }

  void _updateChildBounds(BuildContext context) {
    // childのサイズと位置情報を取得する
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _childBounds = renderBox.paintBounds;
    }
  }

  void _invokeBoundsCallback() {
    if (_startPosition != null && _currentPosition != null && _childBounds != null) {
      final bounds = Rect.fromLTRB(
        _clamp(_startPosition!.dx, _childBounds!.left, _childBounds!.right),
        _clamp(_startPosition!.dy, _childBounds!.top, _childBounds!.bottom),
        _clamp(_currentPosition!.dx, _childBounds!.left, _childBounds!.right),
        _clamp(_currentPosition!.dy, _childBounds!.top, _childBounds!.bottom),
      );
      widget.onBoundsChanged(bounds);
    }
  }

  double _clamp(double value, double min, double max) {
    // 数値の境界を制限
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}