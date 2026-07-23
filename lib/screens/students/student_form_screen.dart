import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
import '../../services/api_client.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _fatherCtrl;
  late TextEditingController _mobileCtrl;
  late TextEditingController _whatsappCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _feeCtrl;

  String _gender = 'Male';
  String _batch = 'Morning';
  String _skillLevel = 'Beginner';
  String _playingRole = '';
  String _bloodGroup = 'A+';
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isLoading = false;
  bool _isActive = true;
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _nameCtrl = TextEditingController(text: s?.fullName ?? '');
    _fatherCtrl = TextEditingController(text: s?.fatherName ?? '');
    _mobileCtrl = TextEditingController(text: s?.mobileNumber ?? '');
    _whatsappCtrl = TextEditingController(text: s?.whatsappNumber ?? '');
    _dobCtrl = TextEditingController(
        text: s != null
            ? s.dateOfBirth.toLocal().toString().split(' ')[0]
            : '');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
    _emergencyCtrl = TextEditingController(text: s?.emergencyContact ?? '');
    _feeCtrl = TextEditingController(
        text: s != null ? s.monthlyFee.toString() : '');

    if (s != null) {
      _gender = s.gender;
      _batch = s.batch;
      _skillLevel = s.skillLevel;
      _playingRole = s.playingRole;
      _bloodGroup = s.bloodGroup;
      _isActive = s.isActive;
      _selectedDob = s.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fatherCtrl.dispose();
    _mobileCtrl.dispose();
    _whatsappCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _emergencyCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = xFile.name;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2010),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobCtrl.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth'),
            backgroundColor: AppTheme.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uuid = widget.student?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final age = calculateAge(_selectedDob!);

    String? photoUrl = widget.student?.photoUrl;
    if (_imageBytes != null) {
      try {
        final result = await ApiClient.uploadFile(
            '/students/$uuid/upload-photo/',
            'photo',
            _imageBytes!,
            _imageName ?? 'photo.jpg');
        photoUrl = result['photo_url'];
      } catch (_) {}
    }

    final student = Student(
      id: uuid,
      fullName: _nameCtrl.text.trim(),
      fatherName: _fatherCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim().isEmpty
          ? null
          : _whatsappCtrl.text.trim(),
      dateOfBirth: _selectedDob!,
      age: age,
      gender: _gender,
      address: _addressCtrl.text.trim(),
      joinDate: widget.student?.joinDate ?? DateTime.now(),
      batch: _batch,
      skillLevel: _skillLevel,
      playingRole: _playingRole,
      monthlyFee: double.tryParse(_feeCtrl.text) ?? 0,
      emergencyContact: _emergencyCtrl.text.trim(),
      bloodGroup: _bloodGroup,
      photoUrl: photoUrl,
      isActive: _isActive,
    );

    final provider = context.read<StudentProvider>();
    bool success;
    if (widget.student != null) {
      success = await provider.updateStudent(uuid, student.toMap());
    } else {
      success = await provider.addStudent(student);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.student != null
              ? 'Student updated successfully'
              : 'Student registered successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.error ?? 'Failed to save'),
            backgroundColor: AppTheme.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.student != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Student' : 'Register Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            AppTheme.primaryGreen.withValues(alpha: 0.1),
                        backgroundImage: _buildImageProvider(),
                        child: _imageBytes == null &&
                                widget.student?.photoUrl == null
                            ? const Icon(Icons.camera_alt,
                                size: 30, color: AppTheme.primaryGreen)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fatherCtrl,
                decoration: const InputDecoration(
                    labelText: 'Father/Guardian Name *',
                    prefixIcon: Icon(Icons.people)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mobileCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'Mobile Number *',
                          prefixIcon: Icon(Icons.phone)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 10) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _whatsappCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: 'WhatsApp Number',
                          prefixIcon: Icon(Icons.chat)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dobCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: 'Date of Birth *',
                          prefixIcon: Icon(Icons.calendar_today)),
                      onTap: _pickDate,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.wc)),
                      items: AppConstants.genders
                          .map((g) => DropdownMenuItem(
                              value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Address *',
                    prefixIcon: Icon(Icons.location_on)),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Academy Information'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _batch,
                      decoration: const InputDecoration(
                          labelText: 'Batch',
                          prefixIcon: Icon(Icons.schedule)),
                      items: AppConstants.batches
                          .map((b) => DropdownMenuItem(
                              value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _batch = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _skillLevel,
                      decoration: const InputDecoration(
                          labelText: 'Skill Level',
                          prefixIcon: Icon(Icons.trending_up)),
                      items: AppConstants.skillLevels
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _skillLevel = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _playingRole.isEmpty ? null : _playingRole,
                decoration: const InputDecoration(
                    labelText: 'Playing Role',
                    prefixIcon: Icon(Icons.sports_cricket)),
                items: AppConstants.playingRoles
                    .map((r) => DropdownMenuItem(
                        value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _playingRole = v ?? ''),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          prefixIcon: Icon(Icons.bloodtype)),
                      items: AppConstants.bloodGroups
                          .map((b) => DropdownMenuItem(
                              value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _bloodGroup = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _feeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Monthly Fee (Rs.)',
                          prefixIcon: Icon(Icons.money)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emergencyCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Emergency Contact',
                    prefixIcon: Icon(Icons.emergency)),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Active Status'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeColor: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(isEdit ? 'Update Student' : 'Register Student',
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider<Object>? _buildImageProvider() {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    if (widget.student?.photoUrl != null) {
      return NetworkImage(widget.student!.photoUrl!);
    }
    return null;
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.primaryGreen));
  }
}
