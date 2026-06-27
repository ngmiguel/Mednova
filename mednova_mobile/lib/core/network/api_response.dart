class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.correlationId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      correlationId: json['correlationId'] as String?,
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  final bool success;
  final String? message;
  final T? data;
  final String? correlationId;
}

class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    final raw = json['content'] as List<dynamic>? ?? [];
    return PageResponse(
      content: raw
          .whereType<Map<String, dynamic>>()
          .map(fromJsonT)
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? raw.length,
      totalElements: json['totalElements'] as int? ?? raw.length,
    );
  }

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
}
