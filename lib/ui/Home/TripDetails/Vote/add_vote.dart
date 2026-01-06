// lib/ui/Home/TripDetails/Vote/add_vote.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moblie_btl/repository/vote_repository.dart';
import 'package:moblie_btl/services/notification_service.dart';

const Color mainBlueColor = Color(0xFF153359);
const Color darkFieldColor = Color(0xFF2C436D);
const Color lightTextColor = Colors.white;

class AddVoteLocationModal extends StatefulWidget {
  final String tripId;

  const AddVoteLocationModal({super.key, required this.tripId});

  @override
  State<AddVoteLocationModal> createState() => _AddVoteLocationModalState();
}

class _AddVoteLocationModalState extends State<AddVoteLocationModal> {
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final VoteRepository _repository = VoteRepository();
  final NotificationService _notificationService = NotificationService();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _tripName;

  @override
  void initState() {
    super.initState();
    _loadTripName();
  }

  Future<void> _loadTripName() async {
    final tripDoc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();
    if (tripDoc.exists && mounted) {
      setState(() {
        _tripName = tripDoc.data()?['name'] ?? 'Chuyến đi';
      });
    }
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để thêm địa điểm')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repository.addVoteOption(
        tripId: widget.tripId,
        location: _locationNameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        createdBy: currentUser.uid,
      );

      // Gửi thông báo cho các thành viên khác trong chuyến đi
      await _notificationService.notifyVoteCreated(
        tripId: widget.tripId,
        tripName: _tripName ?? 'Chuyến đi',
        locationName: _locationNameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm địa điểm bình chọn!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Scaffold(
        backgroundColor: mainBlueColor,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCustomHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _locationNameController,
                        label: 'Tên địa điểm',
                        hint: 'VD: Caffe',
                        icon: Icons.location_on_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên địa điểm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Mô tả (Tùy chọn)',
                        hint: 'Vài dòng về địa điểm này...',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 10,
            left: 20,
            right: 20,
            top: 10,
          ),
          child: _buildAddButton(),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: _isSubmitting ? Colors.white38 : lightTextColor,
                fontSize: 16,
              ),
            ),
          ),
          const Text(
            'Thêm địa điểm',
            style: TextStyle(
              color: lightTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isSubmitting,
          style: const TextStyle(color: lightTextColor, fontSize: 16),
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(icon, color: Colors.white70),
            filled: true,
            fillColor: darkFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _saveLocation,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: mainBlueColor,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Thêm địa điểm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }
}
