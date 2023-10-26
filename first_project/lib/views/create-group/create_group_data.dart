import 'dart:io';
import 'package:first_project/views/create-group/create_group_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupData extends StatefulWidget {
  @override
  _CreateGroupDataState createState() => _CreateGroupDataState();
}

class _CreateGroupDataState extends State<CreateGroupData> {
  String _groupName = '';
  String _groupDescription = '';
  XFile? _selectedImage;
  TextEditingController _searchController = TextEditingController();

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  void onSearch(String query) {
    // You can perform your search action with the 'query' parameter
    print('Search query: $query');
    // Add your logic here
  }

  void goToAnotherView() {
    // Navigate to another view and pass the group name and group description as arguments.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateGroupSearchBar(
          groupName: _groupName,
          groupDescription: _groupDescription,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Data'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20.0), // Add top margin
              child: GestureDetector(
                onTap: _pickImage, // Call the _pickImage function when tapped
                child: Container(
                  width: 100, // Set the width to control size
                  height: 100, // Set the height to control size
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Make it rounded
                    color: Colors.grey, // Set a background color
                  ),
                  child: Center(
                    child: _selectedImage != null
                        ? Image.file(File(_selectedImage!.path)) // Display the picked image
                        : Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.white,
                          ), // Add a smaller icon
                  ),
                ),
              ),
            ),
            SizedBox(height: 5), // Add spacing between image and name

            // Informative text
            Text(
              'Put an image for your group if you want',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 15), // Add spacing between image and name
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => _groupName = value,
                decoration: InputDecoration(
                  labelText: 'Enter group name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => _groupDescription = value,
                decoration: InputDecoration(
                  labelText: 'Enter group description',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 15), // Add spacing between image and name

            // Button to go to another view
            ElevatedButton.icon(
              onPressed: goToAnotherView,
              icon: Icon(Icons.arrow_forward),
              label: Text('Continue'),
            ),

            // Search bar
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: AnimSearchBar(
            //     textController:
            //         _searchController, // Provide the text controller here
            //     width: double.infinity,
            //     helpText: "Search for something...",
            //     onSuffixTap: () {
            //       // Perform search action here
            //       onSearch(_searchController.text);
            //     },
            //     onSubmitted: onSearch, // Pass the onSearch function here
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
