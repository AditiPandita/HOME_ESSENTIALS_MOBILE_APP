import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiProduct {
  final String name;
  final String brand;
  final String category;

  ApiProduct({
    required this.name,
    required this.brand,
    required this.category,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    final String englishName =
        (json['product_name_en'] ?? '').toString().trim();

    final String normalName =
        (json['product_name'] ?? '').toString().trim();

    final String brand =
        (json['brands'] ?? '').toString().trim();

    final String englishCategory =
        (json['categories_tags_en'] ?? '').toString().trim();

    final String normalCategory =
        (json['categories'] ?? '').toString().trim();

    final String name = englishName.isNotEmpty
        ? englishName
        : normalName;

    final String category = englishCategory.isNotEmpty
        ? englishCategory
        : normalCategory;

    return ApiProduct(
      name: name.isEmpty ? 'Unknown Product' : name,
      brand: brand,
      category: category.isEmpty
          ? 'Food'
          : category
              .split(',')
              .first
              .trim()
              .replaceFirst('en:', ''),
    );
  }
}

class ApiService {
  static const String baseUrl =
      'https://world.openfoodfacts.org/api/v2/search';

  Future<List<ApiProduct>> searchProducts(
    String category,
  ) async {
    final Uri uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'categories_tags_en': category,
        'lc': 'en',
        'page': '1',
        'page_size': '5',
        'fields':
            'product_name,product_name_en,brands,categories,categories_tags_en',
      },
    );

    final http.Response response = await http.get(
      uri,
      headers: {
        'User-Agent':
            'HomeEssentials/1.0 (Home Essentials mobile app)',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'API request failed: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final List<dynamic> products =
        data['products'] as List<dynamic>? ?? [];

    return products
        .map(
          (product) => ApiProduct.fromJson(
            Map<String, dynamic>.from(product as Map),
          ),
        )
        .where(
          (product) => product.name != 'Unknown Product',
        )
        .toList();
  }
}
