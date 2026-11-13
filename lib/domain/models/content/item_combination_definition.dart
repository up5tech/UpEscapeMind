import '../../../core/errors/app_exceptions.dart';
import 'parse_utils.dart';

/// `assets/content/items/*.json` — `type: "item_combination"`.
///
/// Only explicitly defined recipes may combine items; invalid combinations
/// never consume items (enforced by use cases in later phases).
class ItemCombinationDefinition {
  const ItemCombinationDefinition({
    required this.id,
    required this.inputItemIds,
    required this.resultItemId,
    required this.consumeInputItems,
    required this.resultMessageKey,
  });

  final String id;
  final List<String> inputItemIds;
  final String resultItemId;
  final bool consumeInputItems;
  final String resultMessageKey;

  factory ItemCombinationDefinition.fromJson(
    Map<String, dynamic> json,
    String filePath,
  ) {
    if (json['type'] != 'item_combination') {
      throw ContentValidationException(
        '$filePath: expected "type": "item_combination"',
      );
    }
    final inputs = reqStringList(json, 'inputItemIds', filePath);
    if (inputs.length < 2) {
      throw ContentValidationException(
        '$filePath: "inputItemIds" must contain at least 2 items',
      );
    }
    return ItemCombinationDefinition(
      id: reqString(json, 'id', filePath),
      inputItemIds: inputs,
      resultItemId: reqString(json, 'resultItemId', filePath),
      consumeInputItems: reqBool(
        json,
        'consumeInputItems',
        filePath,
        mandatory: false,
      ),
      resultMessageKey: reqString(json, 'resultMessageKey', filePath),
    );
  }
}
