import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicineInfoPage extends StatefulWidget {
  const MedicineInfoPage({Key? key}) : super(key: key);

  @override
  _MedicineInfoPageState createState() => _MedicineInfoPageState();
}

class _MedicineInfoPageState extends State<MedicineInfoPage> {
  TextEditingController _searchController = TextEditingController();
  Map<String, String> medicineDetails = {
    'purpose:': '',
    'usage': '',
    'warnings': '',
  };
  List<String> imageUrls = [];
  bool isLoading = false;
  bool imageLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchMedicineDetails(String medicineName) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
      'https://api.fda.gov/drug/label.json?search=openfda.brand_name:"$medicineName"',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'][0];

        setState(() {
          medicineDetails['purpose:'] =
              results['purpose:']?[0] ?? 'No purpose info available';
          medicineDetails['usage'] =
              results['indications_and_usage']?[0] ?? 'No usage info available';
          medicineDetails['warnings'] =
              results['warnings']?[0] ?? 'No warnings info available';
        });
      } else {
        setState(() {
          medicineDetails = {
            'purpose:': 'No data available',
            'usage': '',
            'warnings': '',
          };
        });
      }
    } catch (e) {
      setState(() {
        medicineDetails = {
          'purpose:': 'Failed to load data',
          'usage': '',
          'warnings': '',
        };
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMedicineImages(String query) async {
    setState(() {
      imageLoading = true;
    });

    try {
      final String googleApiKey = 'AIzaSyCO08dictKNws9hB-jcLoFeBFng7gmDe0Y';
      final String searchEngineId =
          'd3662e4c653e84bff'; // <- Replace this with actual CSE ID

      final url =
          'https://www.googleapis.com/customsearch/v1?q=${Uri.encodeComponent(query)}&cx=$searchEngineId&searchType=image&key=$googleApiKey&num=10';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List?;
        if (items != null) {
          setState(() {
            // Clear previous images
            imageUrls = [];
            imageUrls = items.map((item) => item['link'] as String).toList();
          });
        }
      }
    } catch (e) {
      setState(() {
        imageUrls = [];
      });
    } finally {
      setState(() {
        imageLoading = false;
      });
    }
  }

  void _onSearchSubmit() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _fetchMedicineDetails(query);
      _fetchMedicineImages(query);
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: InteractiveViewer(child: Image.network(imageUrl)),
        ),
      ),
    );
  }

 Widget _buildExpandableSection(String title, String content) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.black, // force black box background
      borderRadius: BorderRadius.circular(12),
    ),
    child: ExpansionTile(
      initiallyExpanded: true,
      backgroundColor: Colors.black, // also black when expanded
      collapsedBackgroundColor: Colors.black,
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.teal,
        foregroundColor: theme.appBarTheme.foregroundColor ?? Colors.black,
        title: const Text("Medicine Info"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: theme.cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearchSubmit(),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Enter medicine name",
                      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                      filled: true,
                      fillColor:
                          theme.inputDecorationTheme.fillColor ?? Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onSearchSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Images",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        imageLoading
                            ? const CircularProgressIndicator(
                                color: Colors.tealAccent,
                              )
                            : imageUrls.isEmpty
                            ? Text(
                                "No images found",
                                style: TextStyle(
                                  color: textColor.withOpacity(0.6),
                                ),
                              )
                            : SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () =>
                                          _showFullImage(imageUrls[index]),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Container(
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  imageUrls[index],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        const SizedBox(height: 24),
                        Text(
                          "purpose:",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          medicineDetails['purpose:'] ?? '',
                          style: TextStyle(
                            color: textColor.withOpacity(0.8),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildExpandableSection(
                          "Usage",
                          medicineDetails['usage'] ?? '',
                        ),
                        const SizedBox(height: 16),
                        _buildExpandableSection(
                          "Warnings",
                          medicineDetails['warnings'] ?? '',
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
