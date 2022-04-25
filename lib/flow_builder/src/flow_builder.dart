import 'package:flutter/material.dart';

class FlowBuilder<T> {
  final bool Function(T?) shouldShow;
  final Widget Function(BuildContext, T?) build;

  FlowBuilder(this.shouldShow, this.build);
}

class FlowWrapper<T> extends StatefulWidget {
  // ignore: constant_identifier_names
  static const String ROUTE_KEY = 'flowKey';
  final int? currentIndex;
  final T? data;
  final List<FlowBuilder<T?>>? screenBuildersList;
  const FlowWrapper({
    Key? key,
    this.currentIndex,
    this.screenBuildersList,
    this.data,
  }) : super(key: key);

  static _FlowWrapperState? of<T>(BuildContext context) {
    return context.findAncestorStateOfType<_FlowWrapperState<T>>();
  }

  @override
  _FlowWrapperState createState() => _FlowWrapperState<T>();
}

class _FlowWrapperState<T> extends State<FlowWrapper<T?>> {
  int currentIndex = 0;

  void next(dynamic data) {
    int nextCounter = 1;

    for (int i = currentIndex + 1; i < widget.screenBuildersList!.length; i++) {
      if (!(widget.screenBuildersList![i].shouldShow(data))) {
        nextCounter += 1;
      } else {
        break;
      }
    }

    if ((currentIndex + nextCounter) >= widget.screenBuildersList!.length) {
      Navigator.of(context).popUntil(
        (route) => route.settings.name == FlowWrapper.ROUTE_KEY,
      );
      Navigator.of(context).pop(data);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlowWrapper<T>(
          currentIndex: currentIndex + nextCounter,
          data: data is T ? data : null,
          screenBuildersList: widget.screenBuildersList,
        ),
      ),
    );
  }

  void close() {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == FlowWrapper.ROUTE_KEY,
    );
    Navigator.of(context).pop();
    return;
  }

  @override
  void initState() {
    if (widget.currentIndex != null) {
      currentIndex = widget.currentIndex!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => widget.screenBuildersList![currentIndex].build(context, widget.data),
    );
  }
}


///Example:
/*
    Product? result = await Navigator.of(context).push<Data>(
      MaterialPageRoute(
        settings: const RouteSettings(name: FlowWrapper.ROUTE_KEY),
        builder: (context) => FlowWrapper<Data>(
          screenBuildersList: [
            if (initialData == null)
              FlowBuilder<Data>(
                (data) => true,
                (context, Data? prevData) {
                  return WizardWrapper(
                    dialogKey: FlowWrapper.ROUTE_KEY,
                    title: "Add Entry",
                    child: SomeWizard(
                      onNext: (product) {
                        FlowWrapper.of(context)!.next(product);
                      },
                    ),
                  );
                },
              ),
            FlowBuilder<Data>(
              (data) => data.isValid,
              (context, Data? prevData) {
                return SecondWizard(
                    onNext: (product) {
                      FlowWrapper.of(context)!.next(product);
                    },
                  );
              },
            ),
            
          ],
        ),
      ),
    );
*/