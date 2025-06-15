import 'package:flutter/material.dart';
import 'package:cemungut_app/app/services/firebase_auth_service.dart';
import 'package:cemungut_app/app/services/firestore_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _initials;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // ... (This method remains the same)
    setState(() => _isLoading = true);
    final user = FirebaseAuthService.currentUser;
    if (user != null) {
      final appUser = await FirestoreService.getAppUser(user.uid);
      if (appUser != null) {
        _nameController.text = appUser.name;
        _phoneController.text = appUser.phoneNumber;
        _emailController.text = appUser.email;
        if (appUser.name.isNotEmpty) {
          final names = appUser.name.split(' ');
          _initials = names.map((e) => e[0]).take(2).join();
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateUserData() async {
    // ... (This method remains the same)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuthService.currentUser;
    if (user == null) {
      _showFeedbackSnackBar("Gagal memperbarui: User tidak ditemukan.");
      setState(() => _isLoading = false);
      return;
    }

    try {
      await FirestoreService.updateUserData(
        id: user.uid,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      _showFeedbackSnackBar("Profil berhasil diperbarui!", isSuccess: true);
    } catch (e) {
      _showFeedbackSnackBar("Gagal memperbarui profil. Silakan coba lagi.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFeedbackSnackBar(String message, {bool isSuccess = false}) {
    // ... (This method remains the same)
    if (!mounted) return;
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    // ... (This method remains the same)
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akun"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileAvatar(),
              const SizedBox(height: 48),
              // Updated calls to _buildTextField (no more icon)
              _buildTextField(
                controller: _nameController,
                label: "Nama",
                validator: (value) =>
                value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _phoneController,
                label: "Nomor HP",
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _emailController,
                label: "Email",
                readOnly: true, // Email should not be changed
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,))
                    : Text("Simpan", style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    // ... (This method remains the same)
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).primaryColor,
            child: _initials != null
                ? Text(
              _initials!,
              style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )
                : const Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- THIS IS THE UPDATED WIDGET ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        // This makes the background transparent. By default, `filled` is false.
        filled: false,

        // The floating label that moves up when you tap the field
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),

        // This defines the line shown at the bottom
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }
}