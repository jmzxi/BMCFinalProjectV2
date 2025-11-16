import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:ecommerce_app/widgets/product_card.dart'; // From Module 6
import 'package:ecommerce_app/screens/product_detail_screen.dart'; // From Module 7
import 'package:ecommerce_app/providers/cart_provider.dart'; // From Module 8
import 'package:ecommerce_app/screens/cart_screen.dart'; // From Module 8
import 'package:provider/provider.dart'; // From Module 8

// This is the final, most complex file, combining Modules 4, 5, 6, 7, and 8
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Logic from Module 5 ---
  String _userRole = 'user';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc.data()!['role'];
        });
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
  }
  // --- End of Module 5 Logic ---

  // --- Logic from Module 4 ---
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
  // --- End of Module 4 Logic ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser != null ? 'Welcome, ${_currentUser!.email}' : 'Home'),
        actions: [
          // --- Cart Icon from Module 8 ---
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // --- End of Module 8 ---

          // --- Admin Button from Module 5 ---
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),
          // --- End of Module 5 ---

          // --- Logout Button from Module 4 ---
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _signOut,
          ),
        ],
      ),
      
      // --- Body from Module 6, updated in Module 7 ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;
              
              // --- ProductCard call updated in Module 7 ---
              return ProductCard(
                productName: productData['name'],
                price: productData['price'],
                imageUrl: productData['imageUrl'],
                // --- This is the new part from Module 7 ---
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productData: productData,
                        productId: productDoc.id, // Pass the unique ID!
                      ),
                    ),
                  );
                },
                // --- End of Module 7 Update ---
              );
            },
          );
        },
      ),
      // --- End of Module 6/7 Body ---
    );
  }
}