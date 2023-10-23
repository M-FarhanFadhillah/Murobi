import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key});

  @override
  _ProfilePagesState createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(170, 245, 179, 1),
                Color.fromRGBO(165, 210, 238, 1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: SingleChildScrollView(
              child: Column(children: [
                Text(
                  'Profile',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: Offset(0,
                            5), // Offset in the vertical direction (creates a bottom shadow)
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image(
                            image: AssetImage(
                                "assets/prototype/images/facebook-1.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(0xff3a57e8),
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(type: FileType.any);
                              if (result != null) {
                                // Handle the selected file or folder here
                                if (result.files.isNotEmpty) {
                                  // If a file was selected, you can access it using result.files.first
                                  print(
                                      "Selected file: ${result.files.first.name}");
                                } else {
                                  // If a folder was selected, you can access the folder path using result.paths.first
                                  print(
                                      "Selected folder: ${result.paths.first}");
                                }
                              }
                            },
                            child: Icon(
                              Icons.photo_camera,
                              color: Color(0xffffffff),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 130, 190, 190),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        blurRadius: 5, // Spread radius
                        offset: Offset(0,
                            5), // Offset in the vertical direction (creates a bottom shadow)
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('Sayaa'),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
