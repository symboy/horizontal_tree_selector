import 'package:flutter/material.dart';
import 'package:horizontal_tree_selector/horizontal_tree_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horizontal Tree Selector Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  String _selectedText = '未选择';

  // 构建演示数据
  List<OptionChildrenItemImpl> get _demoOptions => [
    OptionChildrenItemImpl(
      name: '电子产品',
      value: '1',
      children: [
        OptionChildrenItemImpl(
          name: '手机',
          value: '1-1',
          children: [
            OptionChildrenItemImpl(name: 'iPhone', value: '1-1-1', children: null),
            OptionChildrenItemImpl(name: '华为', value: '1-1-2', children: null),
            OptionChildrenItemImpl(name: '小米', value: '1-1-3', children: null),
          ],
        ),
        OptionChildrenItemImpl(
          name: '电脑',
          value: '1-2',
          children: [
            OptionChildrenItemImpl(name: 'MacBook', value: '1-2-1', children: null),
            OptionChildrenItemImpl(name: 'ThinkPad', value: '1-2-2', children: null),
          ],
        ),
      ],
    ),
    OptionChildrenItemImpl(
      name: '服装',
      value: '2',
      children: [
        OptionChildrenItemImpl(
          name: '男装',
          value: '2-1',
          children: [
            OptionChildrenItemImpl(name: 'T恤', value: '2-1-1', children: null),
            OptionChildrenItemImpl(name: '衬衫', value: '2-1-2', children: null),
          ],
        ),
        OptionChildrenItemImpl(
          name: '女装',
          value: '2-2',
          children: [
            OptionChildrenItemImpl(name: '连衣裙', value: '2-2-1', children: null),
            OptionChildrenItemImpl(name: '上衣', value: '2-2-2', children: null),
          ],
        ),
      ],
    ),
    OptionChildrenItemImpl(
      name: '食品',
      value: '3',
      children: [
        OptionChildrenItemImpl(name: '水果', value: '3-1', children: null),
        OptionChildrenItemImpl(name: '零食', value: '3-2', children: null),
      ],
    ),
  ];

  void _showSelector() async {
    final result = await showHorizontalMultiLevelTreePopup(
      context: context,
      options: _demoOptions,
      title: '请选择分类',
      themeColor: Colors.blue,
      onConfirm: (selectedPath, finalSelected) {
        // 构建选择路径文本
        final pathText = selectedPath
            .where((item) => item != null)
            .map((item) => item!.name)
            .join(' > ');
        setState(() {
          _selectedText = pathText.isNotEmpty ? pathText : '未选择';
        });
      },
    );

    if (result == null) {
      // 用户取消了选择
      debugPrint('用户取消选择');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('横向树形选择器示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '当前选择: $_selectedText',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showSelector,
              child: const Text('打开选择器'),
            ),
          ],
        ),
      ),
    );
  }
}
