/// Payment Status
enum PaymentStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  cancelled('cancelled', 'Cancelled'),
  refunded('refunded', 'Refunded'),
  partiallyRefunded('partially_refunded', 'Partially Refunded');

  const PaymentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Invoice Status
enum InvoiceStatus {
  draft('draft', 'Draft'),
  pending('pending', 'Pending'),
  sent('sent', 'Sent'),
  paid('paid', 'Paid'),
  overdue('overdue', 'Overdue'),
  cancelled('cancelled', 'Cancelled'),
  voided('voided', 'Voided');

  const InvoiceStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static InvoiceStatus fromString(String value) {
    return InvoiceStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InvoiceStatus.draft,
    );
  }
}

/// Payment Method
enum PaymentMethod {
  card('card', 'Credit/Debit Card'),
  upi('upi', 'UPI'),
  netbanking('netbanking', 'Net Banking'),
  wallet('wallet', 'Digital Wallet'),
  bankTransfer('bank_transfer', 'Bank Transfer'),
  cheque('cheque', 'Cheque'),
  cash('cash', 'Cash');

  const PaymentMethod(this.value, this.displayName);
  final String value;
  final String displayName;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.card,
    );
  }
}

/// Currency
enum Currency {
  inr('INR', '₹', 'Indian Rupee'),
  usd('USD', '\$', 'US Dollar'),
  eur('EUR', '€', 'Euro');

  const Currency(this.code, this.symbol, this.name);
  final String code;
  final String symbol;
  final String name;

  static Currency fromString(String code) {
    return Currency.values.firstWhere(
      (currency) => currency.code == code,
      orElse: () => Currency.inr,
    );
  }
}

/// Tax Type
enum TaxType {
  gst('gst', 'GST'),
  vat('vat', 'VAT'),
  cgst('cgst', 'CGST'),
  sgst('sgst', 'SGST'),
  igst('igst', 'IGST'),
  cess('cess', 'Cess');

  const TaxType(this.value, this.displayName);
  final String value;
  final String displayName;

  static TaxType fromString(String value) {
    return TaxType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TaxType.gst,
    );
  }
}

/// Payment Model
class Payment {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final double amount;
  final Currency currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? gatewayTransactionId;
  final String? gatewayResponse;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? notes;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    this.transactionId,
    this.gatewayTransactionId,
    this.gatewayResponse,
    this.failureReason,
    required this.createdAt,
    this.processedAt,
    this.notes,
    this.metadata,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userEmail: json['user_email'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: Currency.fromString(json['currency'] as String),
        status: PaymentStatus.fromString(json['status'] as String),
        method: PaymentMethod.fromString(json['method'] as String),
        transactionId: json['transaction_id'] as String?,
        gatewayTransactionId: json['gateway_transaction_id'] as String?,
        gatewayResponse: json['gateway_response'] as String?,
        failureReason: json['failure_reason'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        processedAt: json['processed_at'] != null
            ? DateTime.parse(json['processed_at'] as String)
            : null,
        notes: json['notes'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'amount': amount,
        'currency': currency.code,
        'status': status.value,
        'method': method.value,
        if (transactionId != null) 'transaction_id': transactionId,
        if (gatewayTransactionId != null)
          'gateway_transaction_id': gatewayTransactionId,
        if (gatewayResponse != null) 'gateway_response': gatewayResponse,
        if (failureReason != null) 'failure_reason': failureReason,
        'created_at': createdAt.toIso8601String(),
        if (processedAt != null) 'processed_at': processedAt!.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (metadata != null) 'metadata': metadata,
      };

  Payment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    double? amount,
    Currency? currency,
    PaymentStatus? status,
    PaymentMethod? method,
    String? transactionId,
    String? gatewayTransactionId,
    String? gatewayResponse,
    String? failureReason,
    DateTime? createdAt,
    DateTime? processedAt,
    String? notes,
    Map<String, dynamic>? metadata,
  }) =>
      Payment(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        status: status ?? this.status,
        method: method ?? this.method,
        transactionId: transactionId ?? this.transactionId,
        gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
        gatewayResponse: gatewayResponse ?? this.gatewayResponse,
        failureReason: failureReason ?? this.failureReason,
        createdAt: createdAt ?? this.createdAt,
        processedAt: processedAt ?? this.processedAt,
        notes: notes ?? this.notes,
        metadata: metadata ?? this.metadata,
      );
}

/// Invoice Model
class Invoice {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String invoiceNumber;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final Currency currency;
  final InvoiceStatus status;
  final String? paymentId;
  final DateTime? paidAt;
  final String? notes;
  final List<InvoiceItem> items;
  final List<InvoiceTax> taxes;
  final Map<String, dynamic>? metadata;

  Invoice({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.invoiceNumber,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.paymentId,
    this.paidAt,
    this.notes,
    required this.items,
    required this.taxes,
    this.metadata,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userEmail: json['user_email'] as String,
        invoiceNumber: json['invoice_number'] as String,
        issueDate: DateTime.parse(json['issue_date'] as String),
        dueDate: DateTime.parse(json['due_date'] as String),
        subtotal: (json['subtotal'] as num).toDouble(),
        taxAmount: (json['tax_amount'] as num).toDouble(),
        totalAmount: (json['total_amount'] as num).toDouble(),
        currency: Currency.fromString(json['currency'] as String),
        status: InvoiceStatus.fromString(json['status'] as String),
        paymentId: json['payment_id'] as String?,
        paidAt: json['paid_at'] != null
            ? DateTime.parse(json['paid_at'] as String)
            : null,
        notes: json['notes'] as String?,
        items: (json['items'] as List)
            .map((item) => InvoiceItem.fromJson(item))
            .toList(),
        taxes: (json['taxes'] as List)
            .map((tax) => InvoiceTax.fromJson(tax))
            .toList(),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'invoice_number': invoiceNumber,
        'issue_date': issueDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'subtotal': subtotal,
        'tax_amount': taxAmount,
        'total_amount': totalAmount,
        'currency': currency.code,
        'status': status.value,
        if (paymentId != null) 'payment_id': paymentId,
        if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
        if (notes != null) 'notes': notes,
        'items': items.map((item) => item.toJson()).toList(),
        'taxes': taxes.map((tax) => tax.toJson()).toList(),
        if (metadata != null) 'metadata': metadata,
      };

  Invoice copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? invoiceNumber,
    DateTime? issueDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxAmount,
    double? totalAmount,
    Currency? currency,
    InvoiceStatus? status,
    String? paymentId,
    DateTime? paidAt,
    String? notes,
    List<InvoiceItem>? items,
    List<InvoiceTax>? taxes,
    Map<String, dynamic>? metadata,
  }) =>
      Invoice(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        issueDate: issueDate ?? this.issueDate,
        dueDate: dueDate ?? this.dueDate,
        subtotal: subtotal ?? this.subtotal,
        taxAmount: taxAmount ?? this.taxAmount,
        totalAmount: totalAmount ?? this.totalAmount,
        currency: currency ?? this.currency,
        status: status ?? this.status,
        paymentId: paymentId ?? this.paymentId,
        paidAt: paidAt ?? this.paidAt,
        notes: notes ?? this.notes,
        items: items ?? this.items,
        taxes: taxes ?? this.taxes,
        metadata: metadata ?? this.metadata,
      );

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && status != InvoiceStatus.paid;
  bool get isPaid => status == InvoiceStatus.paid;
  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
}

/// Invoice Item
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? productId;
  final String? planId;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.productId,
    this.planId,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        description: json['description'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unit_price'] as num).toDouble(),
        totalPrice: (json['total_price'] as num).toDouble(),
        productId: json['product_id'] as String?,
        planId: json['plan_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total_price': totalPrice,
        if (productId != null) 'product_id': productId,
        if (planId != null) 'plan_id': planId,
      };
}

/// Invoice Tax
class InvoiceTax {
  final TaxType type;
  final String name;
  final double rate;
  final double amount;

  InvoiceTax({
    required this.type,
    required this.name,
    required this.rate,
    required this.amount,
  });

  factory InvoiceTax.fromJson(Map<String, dynamic> json) => InvoiceTax(
        type: TaxType.fromString(json['type'] as String),
        name: json['name'] as String,
        rate: (json['rate'] as num).toDouble(),
        amount: (json['amount'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'type': type.value,
        'name': name,
        'rate': rate,
        'amount': amount,
      };
}

/// Credit Note
class CreditNote {
  final String id;
  final String invoiceId;
  final String userId;
  final String userName;
  final String userEmail;
  final String creditNoteNumber;
  final DateTime issueDate;
  final double amount;
  final Currency currency;
  final String reason;
  final String? notes;
  final Map<String, dynamic>? metadata;

  CreditNote({
    required this.id,
    required this.invoiceId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.creditNoteNumber,
    required this.issueDate,
    required this.amount,
    required this.currency,
    required this.reason,
    this.notes,
    this.metadata,
  });

  factory CreditNote.fromJson(Map<String, dynamic> json) => CreditNote(
        id: json['id'] as String,
        invoiceId: json['invoice_id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userEmail: json['user_email'] as String,
        creditNoteNumber: json['credit_note_number'] as String,
        issueDate: DateTime.parse(json['issue_date'] as String),
        amount: (json['amount'] as num).toDouble(),
        currency: Currency.fromString(json['currency'] as String),
        reason: json['reason'] as String,
        notes: json['notes'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'credit_note_number': creditNoteNumber,
        'issue_date': issueDate.toIso8601String(),
        'amount': amount,
        'currency': currency.code,
        'reason': reason,
        if (notes != null) 'notes': notes,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Refund
class Refund {
  final String id;
  final String paymentId;
  final String userId;
  final String userName;
  final String userEmail;
  final double amount;
  final Currency currency;
  final PaymentStatus status;
  final String reason;
  final String? gatewayRefundId;
  final String? gatewayResponse;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? notes;
  final Map<String, dynamic>? metadata;

  Refund({
    required this.id,
    required this.paymentId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.currency,
    required this.status,
    required this.reason,
    this.gatewayRefundId,
    this.gatewayResponse,
    this.failureReason,
    required this.createdAt,
    this.processedAt,
    this.notes,
    this.metadata,
  });

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
        id: json['id'] as String,
        paymentId: json['payment_id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userEmail: json['user_email'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: Currency.fromString(json['currency'] as String),
        status: PaymentStatus.fromString(json['status'] as String),
        reason: json['reason'] as String,
        gatewayRefundId: json['gateway_refund_id'] as String?,
        gatewayResponse: json['gateway_response'] as String?,
        failureReason: json['failure_reason'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        processedAt: json['processed_at'] != null
            ? DateTime.parse(json['processed_at'] as String)
            : null,
        notes: json['notes'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'payment_id': paymentId,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'amount': amount,
        'currency': currency.code,
        'status': status.value,
        'reason': reason,
        if (gatewayRefundId != null) 'gateway_refund_id': gatewayRefundId,
        if (gatewayResponse != null) 'gateway_response': gatewayResponse,
        if (failureReason != null) 'failure_reason': failureReason,
        'created_at': createdAt.toIso8601String(),
        if (processedAt != null) 'processed_at': processedAt!.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Billing Statistics
class BillingStats {
  final double totalRevenue;
  final double monthlyRevenue;
  final double pendingPayments;
  final double overdueAmount;
  final int totalInvoices;
  final int pendingInvoices;
  final int overdueInvoices;
  final int totalPayments;
  final int successfulPayments;
  final int failedPayments;
  final double averagePaymentValue;
  final double refundRate;

  BillingStats({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.pendingPayments,
    required this.overdueAmount,
    required this.totalInvoices,
    required this.pendingInvoices,
    required this.overdueInvoices,
    required this.totalPayments,
    required this.successfulPayments,
    required this.failedPayments,
    required this.averagePaymentValue,
    required this.refundRate,
  });

  factory BillingStats.fromJson(Map<String, dynamic> json) => BillingStats(
        totalRevenue: (json['total_revenue'] as num).toDouble(),
        monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
        pendingPayments: (json['pending_payments'] as num).toDouble(),
        overdueAmount: (json['overdue_amount'] as num).toDouble(),
        totalInvoices: json['total_invoices'] as int,
        pendingInvoices: json['pending_invoices'] as int,
        overdueInvoices: json['overdue_invoices'] as int,
        totalPayments: json['total_payments'] as int,
        successfulPayments: json['successful_payments'] as int,
        failedPayments: json['failed_payments'] as int,
        averagePaymentValue: (json['average_payment_value'] as num).toDouble(),
        refundRate: (json['refund_rate'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'total_revenue': totalRevenue,
        'monthly_revenue': monthlyRevenue,
        'pending_payments': pendingPayments,
        'overdue_amount': overdueAmount,
        'total_invoices': totalInvoices,
        'pending_invoices': pendingInvoices,
        'overdue_invoices': overdueInvoices,
        'total_payments': totalPayments,
        'successful_payments': successfulPayments,
        'failed_payments': failedPayments,
        'average_payment_value': averagePaymentValue,
        'refund_rate': refundRate,
      };
}

/// Request/Response Models
class CreateInvoiceRequest {
  final String userId;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final String? notes;

  CreateInvoiceRequest({
    required this.userId,
    required this.dueDate,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'due_date': dueDate.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        if (notes != null) 'notes': notes,
      };
}

class CreateRefundRequest {
  final String paymentId;
  final double amount;
  final String reason;
  final String? notes;

  CreateRefundRequest({
    required this.paymentId,
    required this.amount,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'payment_id': paymentId,
        'amount': amount,
        'reason': reason,
        if (notes != null) 'notes': notes,
      };
}

class PaymentListResponse {
  final List<Payment> payments;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  PaymentListResponse({
    required this.payments,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory PaymentListResponse.fromJson(Map<String, dynamic> json) =>
      PaymentListResponse(
        payments:
            (json['payments'] as List).map((p) => Payment.fromJson(p)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class InvoiceListResponse {
  final List<Invoice> invoices;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  InvoiceListResponse({
    required this.invoices,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) =>
      InvoiceListResponse(
        invoices:
            (json['invoices'] as List).map((i) => Invoice.fromJson(i)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}
