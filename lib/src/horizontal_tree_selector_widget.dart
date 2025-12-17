import 'package:flutter/material.dart';
import 'package:horizontal_tree_selector/horizontal_tree_selector.dart';

/// 样式常量
const _styleConstants = _DefaultStyleConstants();

/// 默认样式常量实现
class _DefaultStyleConstants {
  const _DefaultStyleConstants();

  double get fontSizeSmall => 12.0;
  double get fontSizeNormal => 14.0;
  double get fontSizeLarge => 16.0;
  double get spacingSmall => 4.0;
  double get spacingNormal => 8.0;
  double get spacingLarge => 16.0;
  double get borderRadiusSmall => 4.0;
  double get borderRadiusNormal => 6.0;
  double get iconSizeSmall => 16.0;
  double get iconSizeNormal => 20.0;
}

/// 使用底部模态框显示横向展开的树形结构选择器
///
/// [context] - 上下文
/// [options] - 树形选项列表
/// [selectedItem] - 当前选中项
/// [title] - 标题
/// [themeColor] - 主题颜色
/// [onConfirm] - 确定回调
/// [onCancel] - 取消回调
/// [confirmText] - 确定按钮文本
/// [cancelText] - 取消按钮文本
/// [showConfirmButton] - 是否显示确定按钮，false时选择后直接回调
/// [showSearch] - 是否显示搜索框
Future<List<T>?> showHorizontalTreePopup<T extends OptionChildrenItem>({
  required BuildContext context,
  required List<T> options,
  T? selectedItem,
  String title = '请选择',
  Color? themeColor,
  void Function(T? result)? onConfirm,
  VoidCallback? onCancel,
  String confirmText = '确定',
  String cancelText = '取消',
  bool showConfirmButton = true,
  bool showSearch = true,
}) {
  return showModalBottomSheet<List<T>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => HorizontalTreeSelector<T>(
      options: options,
      selectedItem: selectedItem,
      title: title,
      themeColor: themeColor,
      onConfirm: onConfirm,
      onCancel: onCancel,
      confirmText: confirmText,
      cancelText: cancelText,
      showConfirmButton: showConfirmButton,
      showSearch: showSearch,
    ),
  );
}
/// 横向多级树形结构选择器组件
class HorizontalTreeSelector<T extends OptionChildrenItem>
    extends StatefulWidget {
  final List<T> options;
  final T? selectedItem;
  final String title;
  final Color? themeColor;
  final void Function(T? result)? onConfirm;
  final VoidCallback? onCancel;
  final String confirmText;
  final String cancelText;
  final bool showConfirmButton;
  final bool showSearch;

  const HorizontalTreeSelector({
    super.key,
    required this.options,
    this.selectedItem,
    required this.title,
    this.themeColor,
    this.onConfirm,
    this.onCancel,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.showConfirmButton = true,
    this.showSearch = false,
  });

  @override
  State<HorizontalTreeSelector<T>> createState() =>
      _HorizontalTreeSelectorState<T>();
}

class _HorizontalTreeSelectorState<T extends OptionChildrenItem>
      extends State<HorizontalTreeSelector<T>> {
  // 当前选中的项
  T? _selectedItem;

  // 路径记录：每一级选中的项
  List<T> _breadcrumbs = [];

  // 当前显示的选项列表
  List<T> _currentOptions = [];

  // 搜索相关
  final TextEditingController _searchController = TextEditingController();
  List<T> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    _currentOptions = widget.options;

    // 如果有预选项，构建面包屑路径
    if (_selectedItem != null) {
      _buildBreadcrumbsForSelected(_selectedItem!);
    }

    // 监听搜索输入
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 搜索输入变化处理
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults.clear();
      });
    }
  }

  /// 执行搜索
  void _performSearch(String query) {
    List<T> results = [];
    _searchInTree(widget.options, query.toLowerCase(), results, []);
    setState(() {
      _searchResults = results;
    });
  }

  /// 在树形结构中搜索
  void _searchInTree(
      List<T> options, String query, List<T> results, List<T> path) {
    for (var option in options) {
      // 仅在叶子节点匹配时添加到结果
      final bool isLeaf = option.children == null || option.children!.isEmpty;
      final bool nameMatches =
          option.name?.toLowerCase().contains(query) == true;
      if (isLeaf && nameMatches) {
        results.add(option);
      }

      // 递归搜索子项
      if (option.children != null && option.children!.isNotEmpty) {
        List<T> newPath = List.from(path)..add(option);
        // 安全地转换子项类型
        List<T> children = option.children!.map((child) => child as T).toList();
        _searchInTree(children, query, results, newPath);
      }
    }
  }

  /// 获取搜索结果的完整路径
  List<T> _getItemPath(T item) {
    List<T> path = [];
    _findItemPath(widget.options, item, path);
    return path;
  }

  /// 为已选中的项构建面包屑路径
  void _buildBreadcrumbsForSelected(T selectedItem) {
    List<T> path = [];
    _findItemPath(widget.options, selectedItem, path);

    if (path.isNotEmpty) {
      _breadcrumbs = path;
      // 显示当前选中项所在级别的选项列表
      if (_breadcrumbs.length > 1) {
        // 显示父级的子项列表
        _currentOptions = _breadcrumbs[_breadcrumbs.length - 2]
                .children
                ?.map((child) => child as T)
                .toList() ??
            [];
      } else {
        // 如果是根级别，显示根选项列表
        _currentOptions = widget.options;
      }
    }
  }

  /// 递归查找项目路径
  bool _findItemPath(List<T> options, T target, List<T> path) {
    for (var option in options) {
      path.add(option);

      if (option.value == target.value) {
        return true;
      }

      if (option.children != null && option.children!.isNotEmpty) {
        // 安全地转换子项类型
        List<T> children = option.children!.map((child) => child as T).toList();
        if (_findItemPath(children, target, path)) {
          return true;
        }
      }

      path.removeLast();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题栏
          _buildHeader(),

          // 搜索框
          if (widget.showSearch) _buildSearchBox(),

          // 面包屑导航（在非搜索状态下显示）
          if (!_isSearching) _buildBreadcrumbs(),

          // 选项列表
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                minHeight: maxHeight - (widget.showConfirmButton ? 200 : 120),
              ),
              child: _isSearching ? _buildSearchResults() : _buildOptionsList(),
            ),
          ),

          // 底部按钮区域
          if (widget.showConfirmButton) _buildBottomButtons(),

          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// 构建顶部标题栏
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 24,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建搜索框
  Widget _buildSearchBox() {
    return Container(
      padding: EdgeInsets.all(_styleConstants.spacingNormal),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索...',
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade500,
            size: _styleConstants.iconSizeNormal,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.grey.shade500,
                    size: _styleConstants.iconSizeNormal,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(_styleConstants.borderRadiusNormal),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(_styleConstants.borderRadiusNormal),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(_styleConstants.borderRadiusNormal),
            borderSide: BorderSide(
              color: widget.themeColor ?? Theme.of(context).primaryColor,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _styleConstants.spacingNormal,
            vertical: _styleConstants.spacingNormal,
          ),
        ),
        style: TextStyle(fontSize: _styleConstants.fontSizeNormal),
      ),
    );
  }

  /// 构建面包屑导航
  Widget _buildBreadcrumbs() {
    return Container(
      padding: EdgeInsets.all(_styleConstants.spacingNormal),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 根目录
            GestureDetector(
              onTap: () => _navigateToRoot(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _styleConstants.spacingNormal,
                  vertical: _styleConstants.spacingSmall,
                ),
                decoration: BoxDecoration(
                  color: _breadcrumbs.isEmpty
                      ? widget.themeColor?.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(_styleConstants.borderRadiusSmall),
                ),
                child: Text(
                  '全部',
                  style: TextStyle(
                    color: _breadcrumbs.isEmpty
                        ? widget.themeColor
                        : Colors.grey.shade600,
                    fontSize: _styleConstants.fontSizeSmall,
                  ),
                ),
              ),
            ),

            // 面包屑项目
            for (int i = 0; i < _breadcrumbs.length; i++) ...[
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: _styleConstants.spacingSmall),
                child: Icon(
                  Icons.chevron_right,
                  size: _styleConstants.iconSizeSmall,
                  color: Colors.grey.shade400,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToBreadcrumb(i),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _styleConstants.spacingNormal,
                    vertical: _styleConstants.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: i == _breadcrumbs.length - 1
                        ? widget.themeColor?.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(
                        _styleConstants.borderRadiusSmall),
                  ),
                  child: Text(
                    _breadcrumbs[i].name ?? '',
                    style: TextStyle(
                      color: i == _breadcrumbs.length - 1
                          ? widget.themeColor
                          : Colors.grey.shade600,
                      fontSize: _styleConstants.fontSizeSmall,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建选项列表
  Widget _buildOptionsList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _currentOptions.length,
      itemBuilder: (context, index) {
        final option = _currentOptions[index];
        final isSelected = _selectedItem?.value == option.value;
        final hasChildren =
            option.children != null && option.children!.isNotEmpty;

        return _buildOptionItem(option, isSelected, hasChildren);
      },
    );
  }

  /// 构建搜索结果列表
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: _styleConstants.spacingNormal),
            Text(
              '未找到相关结果',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: _styleConstants.fontSizeNormal,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final option = _searchResults[index];
        final isSelected = _selectedItem?.value == option.value;
        final path = _getItemPath(option);

        return _buildSearchResultItem(option, isSelected, path);
      },
    );
  }

  /// 构建搜索结果项目
  Widget _buildSearchResultItem(T option, bool isSelected, List<T> path) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _styleConstants.spacingLarge,
          vertical: _styleConstants.spacingSmall,
        ),
        title: Text(
          option.name ?? '',
          style: TextStyle(
            color: isSelected ? widget.themeColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: path.isNotEmpty
            ? Text(
                path.map((item) => item.name).join(' > '),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: _styleConstants.fontSizeSmall,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: isSelected
            ? Icon(
                Icons.check,
                color: widget.themeColor,
                size: _styleConstants.iconSizeNormal,
              )
            : null,
        onTap: () => _onSearchResultTap(option),
      ),
    );
  }

  /// 处理选项点击
  void _onOptionTap(T option, bool hasChildren) {
    setState(() {
      _selectedItem = option;
    });

    if (hasChildren) {
      // 有子项，展开下一级
      _navigateToChildren(option);
    } else {
      // 没有子项，需要构建完整的面包屑路径
      _buildBreadcrumbsForSelected(option);

      // 如果不显示确定按钮则直接回调
      if (!widget.showConfirmButton) {
        widget.onConfirm?.call(option);
        Navigator.of(context).pop(option);
      }
    }
  }

  /// 处理搜索结果点击
  void _onSearchResultTap(T option) {
    setState(() {
      _selectedItem = option;
      // 构建并显示完整面包屑路径
      _buildBreadcrumbsForSelected(option);
      _isSearching = false;
      _searchController.clear();
    });

    // 如果不显示确定按钮则直接回调
    if (!widget.showConfirmButton) {
      widget.onConfirm?.call(option);
      // 返回完整的路径
      var result = _getItemPath(option);
      Navigator.of(context).pop(result);
    }
  }

  /// 导航到子项
  void _navigateToChildren(T parent) {
    setState(() {
      _breadcrumbs.add(parent);
      // 安全地转换子项类型
      _currentOptions =
          parent.children?.map((child) => child as T).toList() ?? [];
    });
  }

  /// 导航到根目录
  void _navigateToRoot() {
    setState(() {
      _breadcrumbs.clear();
      _currentOptions = widget.options;
    });
  }

  /// 导航到面包屑指定位置
  void _navigateToBreadcrumb(int index) {
    setState(() {
      _breadcrumbs = _breadcrumbs.sublist(0, index + 1);
      // 安全地转换子项类型
      _currentOptions =
          _breadcrumbs[index].children?.map((child) => child as T).toList() ??
              [];
    });
  }

  /// 构建选项项目
  Widget _buildOptionItem(T option, bool isSelected, bool hasChildren) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: _styleConstants.spacingLarge,
          vertical: _styleConstants.spacingSmall,
        ),
        title: Text(
          option.name ?? '',
          style: TextStyle(
            color: isSelected ? widget.themeColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                color: widget.themeColor,
                size: _styleConstants.iconSizeNormal,
              ),
            if (hasChildren) ...[
              if (isSelected) SizedBox(width: _styleConstants.spacingSmall),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: _styleConstants.iconSizeNormal,
              ),
            ],
          ],
        ),
        onTap: () => _onOptionTap(option, hasChildren),
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 取消按钮
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                widget.onCancel?.call();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(_styleConstants.borderRadiusNormal),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: _styleConstants.spacingNormal),
              ),
              child: Text(widget.cancelText),
            ),
          ),
          SizedBox(width: _styleConstants.spacingNormal),
          // 确定按钮
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedItem != null
                  ? () {
                      widget.onConfirm?.call(_selectedItem);
                      var result = _breadcrumbs;
                      Navigator.of(context).pop(result);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.themeColor ?? Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(_styleConstants.borderRadiusNormal),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: _styleConstants.spacingNormal),
                elevation: 0,
              ),
              child: Text(widget.confirmText),
            ),
          ),
        ],
      ),
    );
  }
}
