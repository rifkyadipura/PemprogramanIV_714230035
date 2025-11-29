import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  ContactListPageState createState() => ContactListPageState();
}

class ContactListPageState extends State<ContactListPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Color _selectedColor = Colors.blue;
  String? _selectedFile;

  final List<Contact> contacts = [];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.single.path;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form belum lengkap atau salah format')),
      );
      return false;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih file terlebih dahulu')),
      );
      return false;
    }
    return true;
  }

  /// Named parameter is `contact` to match calls like `_submitContact(contact: c)`
  void _submitContact({Contact? contact}) {
    if (!_validateForm()) return;

    if (contact != null) {
      // update
      contact.name = _nameController.text.trim();
      contact.phone = _phoneController.text.trim();
      contact.date = _dateController.text.trim();
      contact.color = _selectedColor;
      contact.filePath = _selectedFile;
    } else {
      // add new
      contacts.add(
        Contact(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          date: _dateController.text.trim(),
          color: _selectedColor,
          filePath: _selectedFile,
        ),
      );
    }

    setState(() {});
    Navigator.of(context).pop();
  }

  void _openForm({Contact? contact}) {
    if (contact != null) {
      _nameController.text = contact.name;
      _phoneController.text = contact.phone;
      _dateController.text = contact.date;
      _selectedColor = contact.color;
      _selectedFile = contact.filePath;
    } else {
      _nameController.clear();
      _phoneController.clear();
      _dateController.clear();
      _selectedFile = null;
      _selectedColor = Colors.blue;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    contact == null ? 'Tambah Contact' : 'Update Contact',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final val = v?.trim() ?? '';
                      if (val.isEmpty) return 'Nama wajib diisi';
                      final words = val.split(RegExp(r'\s+'));
                      if (words.length < 2) return 'Nama minimal 2 kata';
                      final namePattern = RegExp(r'^[A-Z][a-zA-Z]+$');
                      for (var w in words) {
                        if (!namePattern.hasMatch(w)) {
                          return 'Setiap kata harus diawali kapital dan tanpa angka/simbol';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'contoh: 62812345678',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final val = v?.trim() ?? '';
                      if (val.isEmpty) return 'Nomor telepon wajib diisi';
                      if (!RegExp(r'^[0-9]+$').hasMatch(val)) {
                        return 'Nomor hanya boleh angka';
                      }
                      if (val.length < 8 || val.length > 13) {
                        return 'Panjang nomor 8-13 digit';
                      }
                      if (!val.startsWith('62')) {
                        return 'Nomor harus dimulai dengan 62';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    onTap: _pickDate,
                    validator: (v) {
                      final val = v?.trim() ?? '';
                      if (val.isEmpty) return 'Tanggal wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Color
                  Row(
                    children: [
                      const Text('Color: '),
                      const SizedBox(width: 12),
                      DropdownButton<Color>(
                        value: _selectedColor,
                        items: <Color>[
                          Colors.red,
                          Colors.green,
                          Colors.blue,
                          Colors.orange,
                          Colors.purple,
                          Colors.brown
                        ].map((c) {
                          return DropdownMenuItem<Color>(
                            value: c,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.black12),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (c) {
                          if (c == null) return;
                          setState(() => _selectedColor = c);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // File Picker
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Pick File'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFile ?? 'No file selected',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submitContact(contact: contact),
                      child: Text(contact == null ? 'Submit' : 'Update'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Contact'),
        content: const Text('Yakin ingin menghapus contact ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() => contacts.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Contacts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: contacts.isEmpty
          ? const Center(child: Text('Belum ada kontak. Tekan + untuk menambah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: contacts.length,
              itemBuilder: (context, i) {
                final c = contacts[i];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: c.color),
                    title: Text(c.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Tel: ${c.phone}'),
                        const SizedBox(height: 2),
                        Text('Date: ${c.date}'),
                        const SizedBox(height: 2),
                        Text('File: ${c.filePath ?? "-"}', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _openForm(contact: c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(i),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
