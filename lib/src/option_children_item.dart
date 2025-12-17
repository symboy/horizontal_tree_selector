abstract class OptionChildrenItem {
  String? name;
  String? value;
  List<OptionChildrenItem>? children;

  OptionChildrenItem(
      {required this.name, required this.value, required this.children});

  @override
  String toString() {
    return 'name: $name, value: $value';
  }
}

class OptionChildrenItemImpl extends OptionChildrenItem {
  OptionChildrenItemImpl(
      {required super.name, required super.value, required super.children});
}
