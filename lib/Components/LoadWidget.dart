import 'dart:async';

import 'package:flutter/material.dart';

typedef FutureCallBack = Future<bool> Function();

class LoadMoreGrid extends StatefulWidget {
  static DelegateBuilder<LoadMoreDelegate> buildDelegate =
      () => const DefaultLoadMoreDelegate();

  final Widget child;
  final FutureCallBack onLoadMore;
  final bool isFinish;
  final LoadMoreDelegate? delegate;
  final bool whenEmptyLoad;

  const LoadMoreGrid({
    Key? key,
    required this.child,
    required this.onLoadMore,
    this.isFinish = false,
    this.delegate,
    this.whenEmptyLoad = true,
  }) : super(key: key);

  @override
  _LoadMoreGridState createState() => _LoadMoreGridState();
}

class _LoadMoreGridState extends State<LoadMoreGrid> {
  Widget get child => widget.child;

  LoadMoreDelegate get loadMoreDelegate =>
      widget.delegate ?? LoadMoreGrid.buildDelegate();


  @override
  Widget build(BuildContext context) {
    if (child is GridView) {
      return _buildGridView(child as GridView) ?? Container();
    }
    if (child is SliverList) {
      return _buildSliverList(child as SliverList);
    }
    return child;
  }

  Widget? _buildGridView(GridView gridView) {
    var delegate = gridView.childrenDelegate;
    outer:
    if (delegate is SliverChildBuilderDelegate) {
      SliverChildBuilderDelegate delegate =
      gridView.childrenDelegate as SliverChildBuilderDelegate;
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      var viewCount = (delegate.estimatedChildCount ?? 0) + 1;
      builder(context, index) {
        if (index == viewCount - 1) {
          return _buildLoadMoreView();
        }
        return delegate.builder(context, index) ?? Container();
      }

      return GridView.builder(
        itemBuilder: builder,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: gridView.dragStartBehavior,
        semanticChildCount: gridView.semanticChildCount,
        itemCount: viewCount,
        cacheExtent: gridView.cacheExtent,
        controller: gridView.controller,
        key: gridView.key,
        padding: gridView.padding,
        physics: gridView.physics,
        primary: gridView.primary,
        reverse: gridView.reverse,
        scrollDirection: gridView.scrollDirection,
        shrinkWrap: gridView.shrinkWrap,
        gridDelegate:gridView.gridDelegate,
      );
    } else if (delegate is SliverChildListDelegate) {
      SliverChildListDelegate delegate =
      gridView.childrenDelegate as SliverChildListDelegate;

      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      delegate.children.add(_buildLoadMoreView());
      return GridView(
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        cacheExtent: gridView.cacheExtent,
        controller: gridView.controller,
        key: gridView.key,
        padding: gridView.padding,
        physics: gridView.physics,
        primary: gridView.primary,
        reverse: gridView.reverse,
        scrollDirection: gridView.scrollDirection,
        shrinkWrap: gridView.shrinkWrap,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: gridView.dragStartBehavior,
        semanticChildCount: gridView.semanticChildCount,
        gridDelegate: gridView.gridDelegate,
        children: delegate.children,
      );
    }
    return gridView;
  }

  Widget _buildSliverList(SliverList list) {
    final delegate = list.delegate;

    if (delegate is SliverChildListDelegate) {
      return SliverList(
        delegate: delegate,
      );
    }

    outer:
    if (delegate is SliverChildBuilderDelegate) {
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      final viewCount = (delegate.estimatedChildCount ?? 0) + 1;
      builder(context, index) {
        if (index == viewCount - 1) {
          return _buildLoadMoreView();
        }
        return delegate.builder(context, index) ?? Container();
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          builder,
          addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
          addRepaintBoundaries: delegate.addRepaintBoundaries,
          addSemanticIndexes: delegate.addSemanticIndexes,
          childCount: viewCount,
          semanticIndexCallback: delegate.semanticIndexCallback,
          semanticIndexOffset: delegate.semanticIndexOffset,
        ),
      );
    }

    outer:
    if (delegate is SliverChildListDelegate) {
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      delegate.children.add(_buildLoadMoreView());
      return SliverList(
        delegate: SliverChildListDelegate(
          delegate.children,
          addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
          addRepaintBoundaries: delegate.addRepaintBoundaries,
          addSemanticIndexes: delegate.addSemanticIndexes,
          semanticIndexCallback: delegate.semanticIndexCallback,
          semanticIndexOffset: delegate.semanticIndexOffset,
        ),
      );
    }

    return list;
  }

  LoadMoreStatus status = LoadMoreStatus.idle;

  Widget _buildLoadMoreView() {
    if (widget.isFinish == true) {
      status = LoadMoreStatus.nomore;
    } else {
      if (status == LoadMoreStatus.nomore) {
        status = LoadMoreStatus.idle;
      }
    }
    return NotificationListener<_RetryNotify>(
      onNotification: _onRetry,
      child: NotificationListener<_BuildNotify>(
        onNotification: _onLoadMoreBuild,
        child: DefaultLoadMoreView(
          status: status,
          delegate: loadMoreDelegate,
        ),
      ),
    );
  }

  bool _onLoadMoreBuild(_BuildNotify notification) {
    if (status == LoadMoreStatus.loading) {
      return false;
    }
    if (status == LoadMoreStatus.nomore) {
      return false;
    }
    if (status == LoadMoreStatus.fail) {
      return false;
    }
    if (status == LoadMoreStatus.idle) {
      loadMore();
    }
    return false;
  }

  void _updateStatus(LoadMoreStatus status) {
    if (mounted) setState(() => this.status = status);
  }

  bool _onRetry(_RetryNotify notification) {
    loadMore();
    return false;
  }

  void loadMore() {
    _updateStatus(LoadMoreStatus.loading);
    widget.onLoadMore().then((v) {
      if (v == true) {
        _updateStatus(LoadMoreStatus.idle);
      } else {
        _updateStatus(LoadMoreStatus.fail);
      }
    });
  }
}

enum LoadMoreStatus {
  idle,
  loading,
  fail,
  nomore,
}

class DefaultLoadMoreView extends StatefulWidget {
  final LoadMoreStatus status;
  final LoadMoreDelegate delegate;
  const DefaultLoadMoreView({
    Key? key,
    this.status = LoadMoreStatus.idle,
    required this.delegate,
  }) : super(key: key);

  @override
  DefaultLoadMoreViewState createState() => DefaultLoadMoreViewState();
}

const _defaultLoadMoreHeight = 10.0;
const _loadMoreDelay = 6;

class DefaultLoadMoreViewState extends State<DefaultLoadMoreView> {
  LoadMoreDelegate get delegate => widget.delegate;

  @override
  Widget build(BuildContext context) {
    notify();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.status == LoadMoreStatus.fail ||
            widget.status == LoadMoreStatus.idle) {
          _RetryNotify().dispatch(context);
        }
      },
      child: Container(
        height: delegate.widgetHeight(widget.status),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: delegate.buildChild(
          widget.status,
        ),
      ),
    );
  }

  void notify() async {
    var delay = max(delegate.loadMoreDelay(), const Duration(milliseconds: 16));
    await Future.delayed(delay);
    if (widget.status == LoadMoreStatus.idle) {
      _BuildNotify().dispatch(context);
    }
  }

  Duration max(Duration duration, Duration duration2) {
    if (duration > duration2) {
      return duration;
    }
    return duration2;
  }
}

class _BuildNotify extends Notification {}

class _RetryNotify extends Notification {}

typedef DelegateBuilder<T> = T Function();

abstract class LoadMoreDelegate {
  static DelegateBuilder<LoadMoreDelegate> buildWidget =
      () => const DefaultLoadMoreDelegate();

  const LoadMoreDelegate();

  double widgetHeight(LoadMoreStatus status) => _defaultLoadMoreHeight;

  Duration loadMoreDelay() => const Duration(milliseconds: _loadMoreDelay);

  Widget buildChild(LoadMoreStatus status);
}

class DefaultLoadMoreDelegate extends LoadMoreDelegate {
  const DefaultLoadMoreDelegate();

  @override
  Widget buildChild(LoadMoreStatus status) {
    if (status == LoadMoreStatus.fail) {
      return const Text("Error");
    }
    if (status == LoadMoreStatus.idle) {
      return Container();
    }
    if (status == LoadMoreStatus.loading) {
      return const Center(child:
             CircularProgressIndicator(
               color: Colors.amber,
            ),
      );
    }
    if (status == LoadMoreStatus.nomore) {
      return const Text("End of story :(");
    }
    return Container();
  }
}
