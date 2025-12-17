import 'package:flutter_test/flutter_test.dart';
import 'package:horizontal_tree_selector/horizontal_tree_selector.dart';

void main() {
  group('HorizontalTreeSelector', () {
    test('TreeNode should be created correctly', () {
      const node = TreeNode(
        id: '1',
        label: 'Test Node',
        children: [],
      );

      expect(node.id, '1');
      expect(node.label, 'Test Node');
      expect(node.children, isEmpty);
    });

    // TODO: 添加更多测试
  });
}
