import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../utils/storage_helper.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ApiService.getProducts();
      setState(() => _products = products);
    } catch (e) {
      _showSnack('Gagal memuat produk: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteProduct(int id) async {
    final ok = await ApiService.deleteProduct(id);
    if (ok) {
      _showSnack('Produk dihapus', Colors.green);
      _loadProducts();
    } else {
      _showSnack('Gagal hapus produk', Colors.red);
    }
  }

  Future<void> _showSubmitDialog() async {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final descC = TextEditingController();
    final githubC = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Submit Tugas',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _dialogField(nameC, 'Nama Produk'),
              const SizedBox(height: 10),
              _dialogField(priceC, 'Harga', isNumber: true),
              const SizedBox(height: 10),
              _dialogField(descC, 'Deskripsi'),
              const SizedBox(height: 10),
              _dialogField(githubC, 'GitHub URL'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF238636)),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await ApiService.submitTugas(
                name: nameC.text.trim(),
                price: int.tryParse(priceC.text) ?? 0,
                description: descC.text.trim(),
                githubUrl: githubC.text.trim(),
              );
              if (result['success'] == true) {
                _showSnack('✅ Tugas berhasil disubmit!', Colors.green);
              } else {
                _showSnack('❌ ${result['message']}', Colors.red);
              }
            },
            child: const Text('Submit',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF30363D))),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF238636))),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(0).split('');
    final result = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) result.write('.');
      result.write(parts[i]);
    }
    return 'Rp ${result.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Katalog Produk',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_rounded, color: Color(0xFF238636)),
            tooltip: 'Submit Tugas',
            onPressed: _showSubmitDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              await StorageHelper.deleteToken();
              if (!mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF238636),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddProductScreen()));
          _loadProducts();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Produk',
            style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF238636)))
          : _products.isEmpty
              ? const Center(
                  child: Text('Belum ada produk.\nTambah produk baru!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16)))
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (_, i) {
                      final p = _products[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(14),
                          border: const Border(
                            left: BorderSide(
                                color: Color(0xFF238636), width: 4),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(p.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(_formatPrice(p.price),
                                  style: const TextStyle(
                                      color: Color(0xFF238636),
                                      fontWeight: FontWeight.w600)),
                              if (p.description.isNotEmpty)
                                Text(p.description,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _deleteProduct(p.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}