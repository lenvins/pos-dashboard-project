import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/data/models/merchant_model.dart';

bool _listEquals<T>(List<T>? a, List<T>? b) {
  return foundation.listEquals(a, b);
}

extension _IterableExtensions<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}


class StoreSelector extends StatefulWidget {
  final List<int> initialSelection;
  final List<Stores> availableStores;
  final bool isLoading;
  final ValueChanged<List<int>> onSelectionChanged;

  const StoreSelector({
    super.key,
    required this.initialSelection,
    required this.availableStores,
    required this.onSelectionChanged,
    this.isLoading = false,
  });

  @override
  _StoreSelectorState createState() => _StoreSelectorState();
}

class _StoreSelectorState extends State<StoreSelector> {
  List<int> _getAllStoreIds() {
    return widget.availableStores
        .map((store) => store.storeId)
        .whereType<int>()
        .toList();
  }

  Widget _buildSelectionButton(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isLoading && widget.availableStores.isEmpty) {
      return const SizedBox(
        height: 38,
        width: 150,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (widget.availableStores.isEmpty && !widget.isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.height10 / 1.5),
        child: Text(
          'No Stores Available',
          style: TextStyle(
            fontSize: Dimensions.font12,
            fontStyle: FontStyle.italic,
            color: theme.disabledColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    String buttonText;
    if (widget.initialSelection.isEmpty) {
      buttonText = 'All Stores (${widget.availableStores.length})';
    } else if (widget.initialSelection.length == 1) {
      final store = widget.availableStores.firstWhereOrNull( 
        (s) => s.storeId == widget.initialSelection.first,
      );
      buttonText = store?.storeName ?? 'Unknown Store';
    } else {
      buttonText = '${widget.initialSelection.length} Stores Selected';
    }

    return OutlinedButton.icon(
      icon: Icon(Icons.store_mall_directory_outlined,
          size: Dimensions.height16),
      label: Text(
        buttonText,
        style: theme.textTheme.labelLarge?.copyWith(
          fontSize: Dimensions.font12,
        ), // Use theme text style
        overflow: TextOverflow.ellipsis,
      ),
      onPressed: widget.availableStores.isEmpty
          ? null
          : () => _showStoreSelectionDialog(context),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.height10 / 1.5),
        side: BorderSide(color: theme.dividerColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showStoreSelectionDialog(BuildContext context) {
    List<int> tempSelectedStoreIds = List.from(widget.initialSelection);
    final List<int> allStoreIds = _getAllStoreIds();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isAllSelected = allStoreIds.isNotEmpty && (tempSelectedStoreIds.isEmpty || tempSelectedStoreIds.length == allStoreIds.length);

            if (allStoreIds.isEmpty) {
              isAllSelected = false;
            }

            return AlertDialog(
              title: const Text('Select Stores'),
              contentPadding: const EdgeInsets.only(top: 20.0),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: CheckboxListTile(
                        title: Text('All Stores (${allStoreIds.length})'),
                        value: isAllSelected,
                        onChanged: allStoreIds.isEmpty
                          ? null
                          : (bool? value) {
                              setDialogState(() {
                                tempSelectedStoreIds = (value == true) ? [] : [];
                              });
                            },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: widget.availableStores.length,
                        itemBuilder: (context, index) {
                          final store = widget.availableStores[index];
                          final storeId = store.storeId;
                          final bool isSelected = tempSelectedStoreIds.contains(storeId);

                          return CheckboxListTile(
                            title: Text(store.storeName ?? 'Unknown Store',
                                overflow: TextOverflow.ellipsis),
                            value: isSelected,
                            enabled: !isAllSelected && storeId != null,
                            onChanged: storeId == null
                              ? null
                              : (bool? value) {
                                  setDialogState(() {
                                    List<int> currentSpecificSelection = List.from(tempSelectedStoreIds);
                                    if(isAllSelected){
                                        currentSpecificSelection = [];
                                    }

                                    if (value == true) {
                                      if (!currentSpecificSelection.contains(storeId)) {
                                        currentSpecificSelection.add(storeId);
                                      }
                                    } else {
                                      currentSpecificSelection.remove(storeId);
                                    }

                                    if (allStoreIds.isNotEmpty && currentSpecificSelection.length == allStoreIds.length) {
                                      tempSelectedStoreIds = [];
                                    } else {
                                      tempSelectedStoreIds = currentSpecificSelection;
                                    }
                                  });
                                },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                            dense: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Apply'),
                  onPressed: () {
                     final bool representsAll = tempSelectedStoreIds.isEmpty && allStoreIds.isNotEmpty;
                     final finalSelection = representsAll ? <int>[] : tempSelectedStoreIds;

                    if (!_listEquals(finalSelection, widget.initialSelection)) {
                      widget.onSelectionChanged(finalSelection);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildSelectionButton(context);
  }
}