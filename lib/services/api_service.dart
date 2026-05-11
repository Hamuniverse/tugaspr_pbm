import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../utils/storage_helper.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  // ── LOGIN ──────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String nim) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': nim, 'password': nim}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return {'success': true, 'token': data['data']['token']};
    }
    return {'success': false, 'message': data['message'] ?? 'Login gagal'};
  }

  // ── GET PRODUCTS ───────────────────────────────────
  static Future<List<Product>> getProducts() async {
    final token = await StorageHelper.getToken();
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data']['products'];
      return list.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception('Gagal mengambil produk');
  }

  // ── ADD PRODUCT ────────────────────────────────────
  static Future<bool> addProduct(String name, int price, String desc) async {
    final token = await StorageHelper.getToken();
    final url = Uri.parse('$baseUrl/api/products');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'name': name, 'price': price, 'description': desc}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // ── SUBMIT TUGAS ───────────────────────────────────
  static Future<Map<String, dynamic>> submitTugas({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final token = await StorageHelper.getToken();
    final url = Uri.parse('$baseUrl/api/products/submit');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true};
    }
    return {'success': false, 'message': data['message'] ?? 'Submit gagal'};
  }

  // ── DELETE PRODUCT ─────────────────────────────────
  static Future<bool> deleteProduct(int id) async {
    final token = await StorageHelper.getToken();
    final url = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
}