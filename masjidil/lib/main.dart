import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0.0), // Set the height to zero
          child: AppBar(
            title: const Text(''),
          ),
        ),
        body: const MyHomePage(title: ''),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BerandaPages(),
    const EdukasiPages(),
    const IbadahPages(),
    const ZiswafPages(),
    const QurbanPages(),
    const KeuanganPages(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.blueAccent,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cast_for_education_rounded),
            label: 'Edukasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque_outlined),
            label: 'Ibadah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            label: 'Ziswaf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_outlined),
            label: 'Qurban',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}

class BerandaPages extends StatelessWidget {
  const BerandaPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Here...',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                  ),
                ),
                Icon(
                  Icons.notifications,
                  color: Colors.red,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class EdukasiPages extends StatelessWidget {
  const EdukasiPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Here...',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                  ),
                ),
                Icon(
                  Icons.notifications,
                  color: Colors.red,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class IbadahPages extends StatelessWidget {
  const IbadahPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SingleChildScrollView(
        child: Container(
          
        )
      ),
    );
  }
}

class ZiswafPages extends StatelessWidget {
  const ZiswafPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ZISWAF',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                // Add your BoxDecoration properties here
                color: const Color.fromARGB(
                    255, 139, 206, 158), // For example, set a background color
                borderRadius:
                    BorderRadius.circular(10.0), // Add rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      "https://raw.githubusercontent.com/ahmadalfarizi2017051060/assets-super-masjid/main/mosque1.png",
                      height: 120,
                      width: 120,
                    ),
                  ),
                  Container(
                    height: 150, // Adjust the height as needed
                    width: 1, // Width of the vertical line
                    color: const Color.fromARGB(
                        255, 0, 38, 6), // Color of the vertical line
                        margin: const EdgeInsets.only(right: 16.0),
                  ),
                  const Column(
                    children: [
                    Text(
                      'Zakat',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Selengkapnya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ])
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                // Add your BoxDecoration properties here
                color: const Color.fromARGB(
                    255, 139, 206, 158), // For example, set a background color
                borderRadius:
                    BorderRadius.circular(10.0), // Add rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      "https://raw.githubusercontent.com/ahmadalfarizi2017051060/assets-super-masjid/main/mosque1.png",
                      height: 120,
                      width: 120,
                    ),
                  ),
                  Container(
                    height: 150, // Adjust the height as needed
                    width: 1, // Width of the vertical line
                    color: const Color.fromARGB(
                        255, 0, 38, 6), // Color of the vertical line
                        margin: const EdgeInsets.only(right: 16.0),
                  ),
                  const Column(
                    children: [
                    Text(
                      'INFAQ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Selengkapnya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ])
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                // Add your BoxDecoration properties here
                color: const Color.fromARGB(
                    255, 139, 206, 158), // For example, set a background color
                borderRadius:
                    BorderRadius.circular(10.0), // Add rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      "https://raw.githubusercontent.com/ahmadalfarizi2017051060/assets-super-masjid/main/mosque1.png",
                      height: 120,
                      width: 120,
                    ),
                  ),
                  Container(
                    height: 150, // Adjust the height as needed
                    width: 1, // Width of the vertical line
                    color: const Color.fromARGB(
                        255, 0, 38, 6), // Color of the vertical line
                        margin: const EdgeInsets.only(right: 16.0),
                  ),
                  const Column(
                    children: [
                    Text(
                      'SHODAQOH',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Selengkapnya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ])
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              decoration: BoxDecoration(
                // Add your BoxDecoration properties here
                color: const Color.fromARGB(
                    255, 139, 206, 158), // For example, set a background color
                borderRadius:
                    BorderRadius.circular(10.0), // Add rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      "https://raw.githubusercontent.com/ahmadalfarizi2017051060/assets-super-masjid/main/mosque1.png",
                      height: 120,
                      width: 120,
                    ),
                  ),
                  Container(
                    height: 150, // Adjust the height as needed
                    width: 1, // Width of the vertical line
                    color: const Color.fromARGB(
                        255, 0, 38, 6), // Color of the vertical line
                        margin: const EdgeInsets.only(right: 16.0),
                  ),
                  const Column(
                    children: [
                    Text(
                      'WAKAF',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Selengkapnya',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ])
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class QurbanPages extends StatelessWidget {
  const QurbanPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Here...',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                  ),
                ),
                Icon(
                  Icons.notifications,
                  color: Colors.red,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class KeuanganPages extends StatelessWidget {
  const KeuanganPages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(170, 245, 179, 1),
            Color.fromRGBO(165, 210, 238, 1)
          ], // Warna gradient yang Anda inginkan
          begin: Alignment.topLeft, // Posisi awal gradient
          end: Alignment.bottomLeft, // Posisi akhir gradient
        ),
      ),
      child: const Center(
        child: Text(
          'Laporan Keuangan',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    ));
  }
}
