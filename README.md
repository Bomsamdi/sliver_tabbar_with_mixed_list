# SliverTabBarWithMixedList

[![Pub Version](https://img.shields.io/pub/v/sliver_tabbar_with_mixed_list)](https://pub.dev/packages/sliver_tabbar_with_mixed_list)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![pub points](https://img.shields.io/pub/points/sliver_tabbar_with_mixed_list)](https://pub.dev/packages/sliver_tabbar_with_mixed_list/score) 
[![popularity](https://img.shields.io/pub/popularity/sliver_tabbar_with_mixed_list)](https://pub.dev/packages/sliver_tabbar_with_mixed_list/score)

A Flutter package that provides a sliver widget with a customizable tab bar and a mixed list of items with different heights, including parents and children. If the last section (parent and its children) is too short to reach the top of the screen, the package offers a customizable footer to fill the missing space.


## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  sliver_tabbar_with_mixed_list: ^0.0.1
```

## Usage
Use the SliverTabBarWithMixedList widget in your app. Customize the tab bar, list items, and footer according to your needs.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_tabbar_with_mixed_list/sliver_tabbar_with_mixed_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SliverTabBarWithMixedList Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SliverTabBarWithMixedList Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<HeaderItem> sections = [];
  double listHeaderHeight = 80;
  double listHeaderSmallHeight = 40;
  double listSubheaderHeight = 50;
  double listItemHeight = 100;
  double variantListItemHeight = 120;
  @override
  void initState() {
    super.initState();
    double offsetStart = 0;
    List<ChildItem> children = List.generate(
      5,
      (index) => Child(itemHeight: listItemHeight),
    );
    List<ChildItem> subChildren = List.generate(
      3,
      (index) => Child(itemHeight: listItemHeight),
    );
    List<ChildItem> subSubChildren = List.generate(
      2,
      (index) => Child(itemHeight: listItemHeight),
    );

    List<ChildItem> variantChildrean = List.generate(
      4,
      (index) => VariantChild(itemHeight: variantListItemHeight),
    );
    for (int i = 0; i < 11; i++) {
      double offsetToAdd = 0;
      Header header;
      if (i < 10) {
        header = Header(
          key: ValueKey(i),
          name: 'Header item $i',
          offsetStart: offsetStart,
          childrenCount: children.length,
          itemHeight: listHeaderHeight,
          childrenHeight: listItemHeight,
          childrean: children,
          subSections: List.generate(
            3,
            (index) {
              var subSubSection = SubHeader(
                key: ValueKey(index),
                name: 'SubSubheader item $index',
                offsetStart: offsetStart,
                childrenCount: subSubChildren.length,
                itemHeight: listSubheaderHeight,
                childrenHeight: listItemHeight,
                childrean: subSubChildren,
              );
              offsetToAdd += subSubSection.itemHeight +
                  (subSubSection.childrenHeight * subSubSection.childrenCount);
              var section = SubHeader(
                key: ValueKey(index),
                name: 'Subheader item $index',
                offsetStart: offsetStart,
                childrenCount: subChildren.length,
                itemHeight: listSubheaderHeight,
                childrenHeight: listItemHeight,
                subSections: [subSubSection],
                childrean: subChildren,
              );

              offsetToAdd +=
                  listSubheaderHeight + (listItemHeight * subChildren.length);

              return section;
            },
          ),
        );
      } else {
        header = Header(
          key: ValueKey(i),
          name: 'Header V item $i',
          offsetStart: offsetStart,
          childrenCount: children.length,
          itemHeight: listHeaderSmallHeight,
          childrenHeight: variantListItemHeight,
          childrean: variantChildrean,
          subSections: List.generate(
            3,
            (index) {
              var subSubSection = SubHeader(
                key: ValueKey(index),
                name: 'SubSubheader V item $index',
                offsetStart: offsetStart,
                childrenCount: subSubChildren.length,
                itemHeight: listSubheaderHeight,
                childrenHeight: variantListItemHeight,
                childrean: variantChildrean,
              );
              offsetToAdd += subSubSection.itemHeight +
                  (subSubSection.childrenHeight * subSubSection.childrenCount);
              var section = SubHeader(
                key: ValueKey(index),
                name: 'Subheader  V item $index',
                offsetStart: offsetStart,
                childrenCount: subChildren.length,
                itemHeight: listSubheaderHeight,
                childrenHeight: variantListItemHeight,
                subSections: [subSubSection],
                childrean: variantChildrean,
              );

              offsetToAdd += listSubheaderHeight +
                  (variantListItemHeight * subChildren.length);

              return section;
            },
          ),
        );
      }
      offsetStart += offsetToAdd;
      offsetToAdd = 0;

      offsetStart +=
          header.itemHeight + (header.childrenHeight * header.childrenCount);
      header = Header.clone(header, offsetStart);
      sections.add(header);
    }
    sections.last = Header.clone((sections.last as Header), double.infinity);
  }

  Widget buildHeader(BuildContext context, HeaderItem item) {
    Header header = item as Header;
    return Container(
      color: Colors.orange,
      child: Center(
        child: Text(
          header.name,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  Widget buildSubHeader(BuildContext context, covariant SubheaderItem item) {
    SubHeader header = item as SubHeader;
    return Container(
      color: Colors.green,
      child: Center(
        child: Text(
          header.name,
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }

  Widget buildChild(BuildContext context, ChildItem item) {
    return Container(
      color: Colors.blue.shade400,
      child: const Center(
        child: Text(
          'Child item',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget buildVariantChild(
      BuildContext context, covariant VariantChildItem item) {
    return Container(
      color: Colors.purple.shade400,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Variant Child item',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Variant Child Description',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  double itemExtentBuilder(
      ListItem item, int index, SliverLayoutDimensions dimensions) {
    return item.itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(widget.title),
            ),
            SliverTabBarWithMixedList(
              controller: PrimaryScrollController.of(context),
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              tabBarIndicator: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
                color: Colors.green,
              ),
              listHeaderHeight: listHeaderHeight,
              listItemHeight: listItemHeight,
              sections: sections,
              headerBuilder: buildHeader,
              subHeaderBuilder: buildSubHeader,
              childBuilder: buildChild,
              variantChildBuilder: buildVariantChild,
              itemExtentBuilder: itemExtentBuilder,
            )
          ],
        ),
      ),
    );
  }
}

class Header extends HeaderItem {
  Header({
    required super.key,
    required this.name,
    required super.offsetStart,
    required super.itemHeight,
    required super.childrenCount,
    required super.childrenHeight,
    super.childrean,
    super.subSections,
  });
  final String name;

  Header.params({
    required super.key,
    required this.name,
    required super.offsetStart,
    required super.itemHeight,
    required super.childrenCount,
    required super.childrenHeight,
    required super.offsetEnd,
    super.childrean,
    super.subSections,
  }) : super.params();

  factory Header.clone(Header header, double offsetEnd) => Header.params(
        key: header.key,
        name: header.name,
        offsetStart: header.offsetStart,
        itemHeight: header.itemHeight,
        childrenCount: header.childrenCount,
        childrenHeight: header.childrenHeight,
        offsetEnd: offsetEnd,
        childrean: header.childrean,
        subSections: header.subSections,
      );
}

class SubHeader extends SubheaderItem {
  SubHeader({
    required super.key,
    required this.name,
    required super.offsetStart,
    required super.itemHeight,
    required super.childrenCount,
    required super.childrenHeight,
    super.childrean,
    super.subSections,
  }) : super();
  final String name;
}

class Child extends ChildItem {
  Child({required super.itemHeight});
}

class VariantChild extends VariantChildItem {
  VariantChild({required super.itemHeight});
}
```

## Features

- Sliver widget with a customizable tab bar.
- Mixed list of items, including parents and children with different heights.
- Customizable footer to fill the missing space if the last section is too short.

## Configuration

Customize the appearance and behavior of the SliverTabBarWithMixedList widget through various configuration options.

## Issues and Bugs

Report any issues or bugs on the GitHub issues page.

## License

This package is licensed under the MIT License.
