library sliver_tabbar_with_mixed_list;

import 'dart:async';

import 'package:after_first_frame_mixin/after_first_frame_mixin.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_tabbar_with_mixed_list/src/sliver_header_with_sliver_body_widget.dart';
import 'package:sliver_tools/sliver_tools.dart';

typedef HeaderBuilder = Widget Function(BuildContext context, HeaderItem item);
typedef SubHeaderBuilder = Widget Function(
    BuildContext context, SubheaderItem item);
typedef ChildBuilder = Widget Function(BuildContext context, ChildItem item);
typedef VariantChildBuilder = Widget Function(
    BuildContext context, VariantChildItem item);
typedef ExtendedItemExtentBuilder = double Function(
    ListItem item, int index, SliverLayoutDimensions dimensions);

typedef TabsBuilder = List<TabItem> Function(List<HeaderItem> sections);

const double _kTabHeight = 46.0;

/// A sliver list with a fixed extent and tabs.
class SliverTabBarWithMixedList extends StatefulWidget {
  const SliverTabBarWithMixedList({
    super.key,
    this.listHeaderHeight,
    required this.listItemHeight,
    required this.controller,
    required this.childBuilder,
    required this.itemExtentBuilder,
    required this.sections,
    required this.generateTabs,
    required this.tabBarButtonBackgroundColor,
    required this.tabBarButtonUnselectedBackgroundColor,
    required this.labelStyle,
    required this.unselectedLabelStyle,
    required this.tabBarButtonRadius,
    this.prefixWidget,
    this.sufixWidget,
    this.tabBarScrollPhysics,
    this.variantChildBuilder,
    this.scrollAnimated = true,
    this.headerBuilder,
    this.subHeaderBuilder,
    this.startOffset = 0,
    this.tabBarIndicator,
    this.tabBarBackgroundColor,
    this.indicatorPadding = EdgeInsets.zero,
    this.tabBarIndicatorSize = TabBarIndicatorSize.tab,
    this.tabAlignment = TabAlignment.start,
    this.tabBarCurveAnimation = Curves.linear,
    this.listScrollCurveAnimation = Curves.easeInOut,
    this.customFooterWidget,
    this.contentPadding = EdgeInsets.zero,
    this.buttonMargin = const EdgeInsets.all(4.0),
    this.tabBarPadding = EdgeInsets.zero,
  });

  /// The widget to use as a prefix before tabs.
  final Widget? prefixWidget;

  /// The widget to use as a sufix after tabs.
  final Widget? sufixWidget;

  final ScrollPhysics? tabBarScrollPhysics;

  /// Function to generate the tabs.
  final TabsBuilder generateTabs;

  final double? listHeaderHeight;

  /// The height of each item in the list.
  final double listItemHeight;

  /// The padding for the indicator.
  final EdgeInsetsGeometry indicatorPadding;

  /// The size of the indicator.
  final TabBarIndicatorSize tabBarIndicatorSize;

  /// The alignment of the tabs.
  final TabAlignment tabAlignment;

  /// The curve animation of the tab bar.
  final Curve tabBarCurveAnimation;

  /// The curve animation of the list scroll.
  final Curve listScrollCurveAnimation;

  /// The list of sections to display.
  final List<HeaderItem> sections;

  /// The controller to use for the scroll view.
  final ScrollController controller;

  /// Whether to animate the scroll when the tab is tapped.
  final bool scrollAnimated;

  /// The builder to use for the header items.
  final HeaderBuilder? headerBuilder;

  final SubHeaderBuilder? subHeaderBuilder;

  /// The builder to use for the child items.
  final ChildBuilder childBuilder;

  final VariantChildBuilder? variantChildBuilder;

  /// The start offset of the list. It is needed when
  ///
  ///  in [CustomScrollView] before [SliverTabBarWithMixedList]
  ///
  ///  exist some other slivers which are expandable for example [SliverAppBar]
  ///
  ///  with [SliverAppBar.expandedHeight] and [SliverAppBar.collapsedHeight] params set.
  final double startOffset;

  /// The indicator of the tab bar item.
  final Decoration? tabBarIndicator;

  /// The background color of the tab bar.
  final Color? tabBarBackgroundColor;

  /// The widget to use for the footer.
  final Widget? customFooterWidget;

  /// The children extent builder.
  final ExtendedItemExtentBuilder itemExtentBuilder;

  /// Tabbars button background color
  final Color tabBarButtonBackgroundColor;

  /// Tabbars button unselected background color
  final Color tabBarButtonUnselectedBackgroundColor;

  /// Tabbars button label style
  final TextStyle labelStyle;

  /// Tabbars button unselected label style
  final TextStyle unselectedLabelStyle;

  /// Tabbars button radius
  final double tabBarButtonRadius;

  /// The padding for the content.
  final EdgeInsets contentPadding;

  /// The margin for each button in the tabbar
  final EdgeInsets buttonMargin;

  /// Padding for the tabbar of [SliverTabBarWithMixedList].
  final EdgeInsets tabBarPadding;

  @override
  State<SliverTabBarWithMixedList> createState() =>
      _SliverTabBarWithMixedListState();
}

class _SliverTabBarWithMixedListState extends State<SliverTabBarWithMixedList>
    with SingleTickerProviderStateMixin, AfterFirstFrameMixin {
  /// The tab controller.
  TabController? _tabController;

  /// The height of each item in the list.
  late double _listItemHeight;

  /// The list of items to display.
  final List<ListItem> _items = [];

  List<HeaderItem> _sections = [];

  /// The list of tab items to display.
  late List<TabItem> _tabItems;

  /// Enable/disable scroll animation when list animate to
  ///
  ///  position. This is needed to sync tabs and list.
  bool scrollAnimationEnabled = true;

  /// The current index of the tab controller.
  int _index = 0;

  /// The index of the last header item.
  int? _indexOfLastHeaderItem;

  /// The height of the footer. When in last group of items there
  ///
  ///  is not enough items to fill the screen, the footer is used to fill the screen.
  double? _footerHeight;

  @override
  void initState() {
    super.initState();
    _listItemHeight = widget.listItemHeight;
    _sections = widget.sections;
    _tabController = TabController(length: _sections.length, vsync: this);
    _items.addAll(flattenList(_sections));

    _tabItems = [];
    _tabItems.addAll(widget.generateTabs(_sections));
    _indexOfLastHeaderItem =
        _items.lastIndexWhere((element) => element is HeaderItem);
    if (_indexOfLastHeaderItem == -1) {
      _indexOfLastHeaderItem = null;
    }

    widget.controller.addListener(() {
      if (scrollAnimationEnabled) {
        List<HeaderItem> items = [];

        for (var element in _items.whereType<HeaderItem>().toList()) {
          if (element is! SubheaderItem) {
            items.add(element);
          }
        }

        HeaderItem item = items.firstWhere((element) {
          final HeaderItem headerItem = element;
          return widget.controller.offset >=
                  headerItem.offsetStart + widget.startOffset &&
              widget.controller.offset <
                  headerItem.offsetEnd + widget.startOffset;
        }, orElse: () => items.first);
        int a = (item.key as ValueKey).value;
        if (a != _index) {
          _index = a;
          _tabController?.animateTo(
            _index,
            duration: const Duration(milliseconds: 300),
            curve: widget.listScrollCurveAnimation,
          );
          setState(() {});
        }
      }
    });
  }

  List<ListItem> flattenList(List<HeaderItem> list) {
    List<ListItem> result = [];
    void flatten(HeaderItem header) {
      if (header.childrean != null) {
        result.add(header);
        for (var element in header.childrean!) {
          result.add(element);
        }
      }
      if (header.subSections != null) {
        for (var element in header.subSections!) {
          flatten(element);
        }
      }
    }

    for (var element in list) {
      flatten(element);
    }
    return result;
  }

  @override
  FutureOr<void> afterFirstFrame(BuildContext context) {
    if (_indexOfLastHeaderItem != null) {
      Size size = MediaQuery.of(context).size;
      double height = size.height;
      final padding = MediaQuery.of(context).viewPadding;
      height = height - padding.top - padding.bottom;
      double elementHeight =
          _items.skip(_indexOfLastHeaderItem!).length * _listItemHeight;
      if (height > elementHeight) {
        _footerHeight = (height - elementHeight).ceilToDouble();
        setState(() {});
      }
    }
  }

  // @override
  // void didUpdateWidget(covariant SliverTabBarWithMixedList oldWidget) {
  //   if (oldWidget.listItemHeight != widget.listItemHeight) {
  //     setState(() {
  //       _listItemHeight = widget.listItemHeight;
  //     });
  //   }
  //   if (oldWidget.sections != widget.sections) {
  //     _sections.clear();
  //     _items.clear();
  //     _sections = widget.sections;
  //     for (Section section in _sections) {
  //       _items.add(section.header);
  //       for (ChildItem childItem in section.children) {
  //         _items.add(childItem);
  //       }
  //     }
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _onTapTabBarItem(int value) {
    scrollAnimationEnabled = false;
    TabItem tabItem = _tabItems[value];

    widget.scrollAnimated
        ? widget.controller
            .animateTo(
              tabItem.headerItem.offsetStart + widget.startOffset,
              duration: const Duration(milliseconds: 300),
              curve: widget.tabBarCurveAnimation,
            )
            .then((value) => scrollAnimationEnabled = true)
        : {
            widget.controller.jumpTo(
              tabItem.headerItem.offsetStart + widget.startOffset,
            ),
            scrollAnimationEnabled = true,
          };
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SliverHeaderWithSliverBodyWidget(
      pushPinnedChildren: true,
      header: SliverPinnedHeader(
        child: Container(
          padding: widget.tabBarPadding,
          color: widget.tabBarBackgroundColor ?? theme.scaffoldBackgroundColor,
          child: Row(
            children: [
              if (widget.prefixWidget != null) widget.prefixWidget!,
              // Expanded(
              //   child: TabBar(
              //     isScrollable: true,
              //     indicator: widget.tabBarIndicator,
              //     indicatorPadding: widget.indicatorPadding,
              //     indicatorSize: widget.tabBarIndicatorSize,
              //     tabAlignment: widget.tabAlignment,
              //     controller: _tabController,
              //     onTap: _onTapTabBarItem,
              //     physics: widget.tabBarScrollPhysics,
              //     tabs: _tabItems,
              //   ),
              // ),
              Expanded(
                child: ButtonsTabBar(
                  buttonMargin: widget.buttonMargin,
                  backgroundColor: widget.tabBarButtonBackgroundColor,
                  unselectedBackgroundColor:
                      widget.tabBarButtonUnselectedBackgroundColor,
                  controller: _tabController,
                  labelStyle: widget.labelStyle,
                  unselectedLabelStyle: widget.unselectedLabelStyle,
                  radius: widget.tabBarButtonRadius,
                  tabs: _tabItems,
                  onTap: _onTapTabBarItem,
                  contentPadding: widget.contentPadding,
                  physics: widget.tabBarScrollPhysics ??
                      const BouncingScrollPhysics(),
                ),
              ),
              if (widget.sufixWidget != null) widget.sufixWidget!,
            ],
          ),
        ),
      ),
      body: SliverVariedExtentList.builder(
        itemExtentBuilder: (index, dimensions) {
          if (index < _items.length) {
            return widget.itemExtentBuilder(_items[index], index, dimensions);
          }
          return widget.listItemHeight;
        },
        itemBuilder: (context, index) {
          var item = _items[index];
          if (item is VariantChildItem && widget.variantChildBuilder != null) {
            return widget.variantChildBuilder!(context, item);
          } else if (item is ChildItem) {
            return widget.childBuilder(context, item);
          } else if (item is SubheaderItem && widget.subHeaderBuilder != null) {
            return widget.subHeaderBuilder!(context, item);
          } else if (item is HeaderItem && widget.headerBuilder != null) {
            return widget.headerBuilder!(context, item);
          } else {
            return Container();
          }
        },
        itemCount: _items.length,
      ),
      footerHeight: _footerHeight,
      footerWidget: widget.customFooterWidget,
    );
  }
}

abstract class HeaderItem extends ListItem {
  const HeaderItem({
    required super.key,
    required this.offsetStart,
    required this.childrenCount,
    required super.itemHeight,
    required this.childrenHeight,
    this.childrean,
    this.subSections,
  }) : offsetEnd = offsetStart + (childrenHeight * childrenCount) + itemHeight;
  final List<SubheaderItem>? subSections;
  final double offsetStart;
  final double offsetEnd;
  final double childrenHeight;
  final int childrenCount;
  final List<ChildItem>? childrean;

  HeaderItem.params({
    required super.key,
    required this.offsetStart,
    required super.itemHeight,
    required this.childrenCount,
    required this.childrenHeight,
    required this.offsetEnd,
    this.childrean,
    this.subSections,
  });

  List<ListItem> iterateSections(
      List<ListItem> Function(HeaderItem section) action) {
    List<ListItem> result = [];
    result.addAll(action(this));
    result.addAll(childrean ?? []);
    subSections?.forEach((subsection) {
      result.addAll(
        subsection.iterateSections(action),
      );
      if (subsection.childrean != null) {
        result.addAll(subsection.childrean!);
      }
    });
    return result;
  }
}

abstract class SubheaderItem extends HeaderItem {
  const SubheaderItem({
    required super.key,
    required super.offsetStart,
    required super.childrenCount,
    required super.itemHeight,
    required super.childrenHeight,
    super.childrean,
    super.subSections,
  }) : super();

  @override
  List<ListItem> iterateSections(
      List<ListItem> Function(HeaderItem section) action) {
    List<ListItem> result = [];
    result.addAll(action(this));
    result.addAll(childrean ?? []);
    subSections?.forEach((subsection) {
      result.addAll(
        subsection.iterateSections(action),
      );
      if (subsection.childrean != null) {
        result.addAll(subsection.childrean!);
      }
    });
    return result;
  }
}

abstract class ChildItem extends ListItem {
  const ChildItem({
    super.key,
    required super.itemHeight,
  });
}

abstract class VariantChildItem extends ChildItem {
  const VariantChildItem({
    super.key,
    required super.itemHeight,
  });
}

abstract class ListItem {
  const ListItem({
    this.key,
    required this.itemHeight,
  });
  final Key? key;
  final double itemHeight;
}

class TabItem extends Tab {
  //StatelessWidget implements PreferredSizeWidget {

  /// Creates a Material Design [SliverTabBarWithMixedList] tab.
  const TabItem({
    super.key,
    super.text,
    super.height,
    super.icon,
    required this.headerItem,
  });

  /// The [HeaderItem] to display as the tab's label.
  final HeaderItem headerItem;

  /// The text to display as the tab's label.
  // @override
  // final String? text;

  /// The height of the [TabItem].
  ///
  /// If null, the height will be calculated based on the content of the [TabItem].
  // @override
  // final double? height;

  Widget buildLabelText() {
    return Text(text!, softWrap: false, overflow: TextOverflow.ellipsis);
  }

  @override
  Size get preferredSize {
    if (height != null) {
      return Size.fromHeight(height!);
    } else {
      return const Size.fromHeight(_kTabHeight);
    }
  }
}

class Section {
  const Section({
    required this.header,
    required this.children,
  });
  final HeaderItem header;
  final List<ChildItem> children;

  static int getSectionItemsCount(
      HeaderItem? header, List<ChildItem> children) {
    return children.length + (header != null ? 1 : 0);
  }
}

class SubSection {
  const SubSection({
    required this.header,
    required this.children,
  });
  final SubheaderItem header;
  final List<ChildItem> children;

  static int getSectionItemsCount(
      SubheaderItem? header, List<ChildItem> children) {
    return children.length + (header != null ? 1 : 0);
  }
}
