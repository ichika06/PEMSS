import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:lottie/lottie.dart';
import '../../../../../models/event_model.dart';
import '../../../../../services/firestore_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  AddEventScreenState createState() => AddEventScreenState();
}

class AddEventScreenState extends State<AddEventScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  AssetEntity? _selectedImage;
  bool _isLoading = false;

  ThemeData get theme => Theme.of(context);

  Future<void> _pickImage() async {
    await InstaAssetPicker.pickAssets(
      context,
      maxAssets: 1,
      pickerConfig: InstaAssetPickerConfig(
        pickerTheme: theme.copyWith(
          canvasColor: theme.colorScheme.surface,
          splashColor: Colors.grey,
          colorScheme: theme.colorScheme.copyWith(
            surface: theme.colorScheme.surface,
          ),
          appBarTheme: theme.appBarTheme.copyWith(
            backgroundColor: theme.colorScheme.surface,
            titleTextStyle: Theme.of(context)
                .appBarTheme
                .titleTextStyle
                ?.copyWith(color: Colors.white),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              disabledForegroundColor: Colors.grey,
            ),
          ),
        ),
      ),
      onCompleted: (Stream<InstaAssetsExportDetails> stream) async {
        final details = await stream.first;

        if (details.selectedAssets.isNotEmpty) {
          final selectedAsset = details.selectedAssets.first;

          setState(() {
            _selectedImage = selectedAsset;
          });

          final isConfirmed = await _confirmAndSaveImage(selectedAsset, context);
          if (!isConfirmed) {
            setState(() {
              _selectedImage = null;
            });
          }
        }
      },
    );
  }

  Future<bool> _confirmAndSaveImage(AssetEntity asset, BuildContext context) async {
    final file = await asset.file;
    if (file == null) {
      _showErrorSnackBar('Unable to load the selected image.');
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: const BorderSide(color: Color.fromARGB(87, 255, 255, 255), width: 1.0 ),
          ),
          title: const Text('Confirm Image'),
          content: Image.file(
            file,
            fit: BoxFit.cover,
            height: 200,
          ),
          actions: [
            Card(
              elevation: 0,
              clipBehavior: Clip.hardEdge,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : const Color.fromARGB(255, 247, 229, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: const BorderSide(color: Color.fromARGB(87, 255, 255, 255), width: 1.0 ),
              ),
              
              child: SizedBox(      
                height: 40, 
                width: 100, 
                child: TextButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  onPressed: () {
                  Navigator.of(context).pop(true);
                  },
                  child: Text('Confirm', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue)),
                ),
              ),
            ),
            Card(
              elevation: 0,
              clipBehavior: Clip.hardEdge,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.transparent : const Color.fromARGB(255, 247, 229, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
                side: const BorderSide(color: Color.fromARGB(87, 255, 255, 255), width: 1.0 ),
              ),
              child: SizedBox(
                
                height: 40,
                width: 100,
                child: TextButton(
                  
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  onPressed: () {
                  Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue)),
                ),
                
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      Navigator.pop(context);
      return true;
    }

    return false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<String?> _uploadImage(AssetEntity asset) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return null;
      }

      final file = await asset.file;
      if (file == null) {
        _showErrorSnackBar('Selected image file is null');
        return null;
      }

      final String fileName = 'event_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('events/${user.uid}/$fileName');

      final uploadTask = await storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_by': user.uid,
            'event_type': 'user_created'
          },
        ),
      );

      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      _showErrorSnackBar('Firebase Error: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      _showErrorSnackBar('Unexpected error during image upload: $e');
      return null;
    }
  }

  Future<String?> _getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = userDoc.data();
      return data != null ? '${data['firstName']} ${data['lastName']}' : null;
    }
    return null;
  }

  void _addEvent() async {
    if (_validateInputs()) {
      setState(() => _isLoading = true);

      try {
        final imageUrl = _selectedImage != null
            ? await _uploadImage(_selectedImage!)
            : null;

        if (imageUrl != null) {
          await _firestoreService.addEvent(
            Event(
              id: '',
              title: titleController.text.trim(),
              date: dateController.text.trim(),
              description: descriptionController.text.trim(),
              imageUrl: imageUrl,
              author: (await _getCurrentUserName()) ?? 'Unknown',
            ),
          );

          if (mounted) Navigator.pop(context);
        } else {
          _showErrorSnackBar('Image upload failed');
        }
      } catch (e) {
        _showErrorSnackBar('Event creation failed: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateInputs() {
    if (titleController.text.isEmpty) {
      _showErrorSnackBar('Please enter an event title');
      return false;
    }
    if (dateController.text.isEmpty) {
      _showErrorSnackBar('Please enter an event date');
      return false;
    }
    if (descriptionController.text.isEmpty) {
      _showErrorSnackBar('Please enter an event description');
      return false;
    }
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {

    const List<String> _eventStatus = <String>[
      'Pending',
      'Ongoing',
      'Paused',
      'Scheduled',
      'Waitlisted',
      'Online',
      'Hybrid',
    ];


    void _showDialogPicker(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

    return Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'Create Event',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ElevatedButton(
                        onPressed: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            timeController.text = time.format(context);
                          }
                        },
                        child: const Text('Select Time'),
                      ),  
                      const SizedBox(height: 16),

                       ElevatedButton(
                        onPressed: () async {
                          final DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            dateController.text =  '${date.month.toString()}/${date.day.toString()}/${date.year.toString()}';
                          }
                        },
                        child: const Text('Select Date'),
                      ), 

                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ButtonStyle(
                          minimumSize: const WidgetStatePropertyAll<Size>(Size.fromHeight(50)),
                          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        child: const Text('Event Status'),
                        onPressed: () {
                          _showDialogPicker(
                            CupertinoPicker(
                              itemExtent: 50.0,
                              onSelectedItemChanged: (int selectedIndex) {
                                setState(() {
                                  statusController.text = _eventStatus[selectedIndex];
                                });
                              },
                              children: _eventStatus.map<Widget>((String item) {
                                return Center(
                                  child: Text(item),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                        Text(
                      statusController.text.isEmpty ? 'Select Status' : 'Status: ${statusController.text}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          labelText: 'Event Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _selectedImage == null
                              ? const Center(
                                  
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      
                                      Icon(Icons.image, size: 50, color: Colors.grey),
                                      Text('Tap to select image'),
                                    ],
                                  ),
                                )
                              : FutureBuilder<File?>( 
                                  future: _selectedImage!.file,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      return snapshot.data != null
                                          ? Image.file(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            )
                                          : const Center(
                                              child: Text('Error loading image'),
                                            );
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addEvent,
                        child: Text(_isLoading ? 'Creating...' : 'Create Event'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
              Positioned.fill(
                  child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black54,
                  child: Center(
                    child: Lottie.asset(
                    'lib/assets/loading/NfcLoading.json',
                    width: 50,
                    height: 50,
                    ),
                  ),
                  ),
              ),
            ],
          ),
        ),
      );
    }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
