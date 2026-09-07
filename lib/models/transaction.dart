import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

enum PaymentMethod { 
  dinheiro, 
  pix, 
  cartaoCredito 
}

enum TransactionKind { 
  entrada, 
  despesa 
}

@freezed
abstract class Transaction with _$Transaction {
  const Transaction._();
  const factory Transaction({
    required String id,
    required TransactionKind kind,
    required double value,
    required DateTime date,
    required PaymentMethod paymentMethod,
    String? planItemId,
    String? categorySnapshotName,
    String? title,
    @Default(false) bool isReversal,
    String? reversalOfId,
    required DateTime createdAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
