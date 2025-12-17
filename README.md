# Horizontal Tree Selector

一个 Flutter 横向多级树形结构选择器组件，支持无限层级的数据选择。

[![pub package](https://img.shields.io/pub/v/horizontal_tree_selector.svg)](https://pub.dev/packages/horizontal_tree_selector)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![platform](https://img.shields.io/badge/platform-flutter-blue.svg)](https://flutter.dev)

## 效果预览

<img src="https://raw.githubusercontent.com/symboy/horizontal_tree_selector/main/assets/screenshot.GIF" width="300" alt="效果演示"/>

## 特性

- 🎯 **面包屑导航** - 清晰显示选择路径，支持快速回退
- 🔍 **搜索功能** - 支持快速搜索叶子节点
- 🎨 **主题定制** - 支持自定义主题颜色
- ✨ **预选回显** - 自动定位已选项
- 📱 **底部弹窗** - 适配移动端交互
- 🔄 **两种模式** - 确认模式 / 即选即回调模式

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  horizontal_tree_selector: ^0.0.1
```

然后运行：

```bash
flutter pub get
```

## 使用方法

### 1. 定义数据模型

使用内置的 `OptionChildrenItemImpl` 或实现 `OptionChildrenItem` 抽象类：

```dart
import 'package:horizontal_tree_selector/horizontal_tree_selector.dart';

final options = [
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
];
```

### 2. 调用选择器

```dart
final result = await showHorizontalTreePopup<OptionChildrenItemImpl>(
  context: context,
  options: options,
  title: '请选择分类',
  themeColor: Colors.blue,
  onConfirm: (result) {
    print('最终选中: ${result?.name}');
  },
);
```

## API 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:----:|--------|------|
| `context` | `BuildContext` | ✅ | - | 上下文 |
| `options` | `List<T>` | ✅ | - | 树形选项列表 |
| `selectedItem` | `T?` | ❌ | `null` | 预选项（用于回显） |
| `title` | `String` | ❌ | `'请选择'` | 弹窗标题 |
| `themeColor` | `Color?` | ❌ | `null` | 主题颜色 |
| `showConfirmButton` | `bool` | ❌ | `true` | 是否显示确定按钮 |
| `showSearch` | `bool` | ❌ | `true` | 是否显示搜索框 |
| `onConfirm` | `Function(T?)?` | ❌ | `null` | 确定回调 |
| `onCancel` | `VoidCallback?` | ❌ | `null` | 取消回调 |
| `confirmText` | `String` | ❌ | `'确定'` | 确定按钮文本 |
| `cancelText` | `String` | ❌ | `'取消'` | 取消按钮文本 |

## 两种交互模式

### 确认模式（默认）

用户选择后需点击确定按钮才会返回结果：

```dart
showHorizontalTreePopup(
  context: context,
  options: options,
  showConfirmButton: true,  // 默认值
  onConfirm: (result) {
    // 点击确定后回调
  },
);
```

### 即选即回调模式

选择叶子节点后直接返回，无需点击确定：

```dart
showHorizontalTreePopup(
  context: context,
  options: options,
  showConfirmButton: false,  // 关闭确定按钮
  onConfirm: (result) {
    // 选择后立即回调
  },
);
```

## 搜索功能

默认开启搜索功能，可搜索所有叶子节点：

```dart
// 显示搜索框（默认）
showHorizontalTreePopup(
  context: context,
  options: options,
  showSearch: true,
);

// 隐藏搜索框
showHorizontalTreePopup(
  context: context,
  options: options,
  showSearch: false,
);
```

## 自定义数据模型

继承 `OptionChildrenItem` 抽象类来使用自定义数据模型：

```dart
class Category extends OptionChildrenItem {
  final int id;
  final String? icon;
  
  Category({
    required this.id,
    this.icon,
    required String name,
    List<Category>? children,
  }) : super(
    name: name,
    value: id.toString(),
    children: children,
  );
}

// 使用自定义模型
final result = await showHorizontalTreePopup<Category>(
  context: context,
  options: categoryList,
);
```

## 返回值

`showHorizontalTreePopup` 返回 `Future<List<T>?>`，包含完整的选择路径：

```dart
final result = await showHorizontalTreePopup<OptionChildrenItemImpl>(
  context: context,
  options: options,
);

if (result != null && result.isNotEmpty) {
  // result 是从根到叶子节点的完整路径
  print('选择路径: ${result.map((e) => e.name).join(' > ')}');
  print('最终选中: ${result.last.name}');
}
```

## License

MIT License
