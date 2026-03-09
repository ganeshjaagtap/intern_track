import 'package:flutter/material.dart';
import 'CompanyDetailScreen.dart'; 

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = ""; 

  // 📝 LOCAL DATA: Your mock database
  final List<Map<String, dynamic>> dummyCompanies = [
    {
      "id": "1",
      "name": "Google",
      "email": "hr@google.com",
      "industry": "Tech & AI",
      "address": "Mountain View, CA",
      "description": "Google's mission is to organize the world's information and make it universally accessible and useful. We offer internship roles in Software Engineering, Data Science, and Product Management.",
      "website": "www.google.com"
    },
    {
      "id": "2",
      "name": "Tesla",
      "email": "careers@tesla.com",
      "industry": "Automotive",
      "address": "Austin, TX",
      "description": "Accelerating the world's transition to sustainable energy through electric vehicles, solar, and integrated renewable energy solutions.",
      "website": "www.tesla.com"
    },
    {
      "id": "3",
      "name": "Microsoft",
      "email": "recruitment@microsoft.com",
      "industry": "Software",
      "address": "Redmond, WA",
      "description": "Empowering every person and organization on the planet to achieve more. Join us for world-class mentorship and innovative projects.",
      "website": "www.microsoft.com"
    },
    {
      "id": "4",
      "name": "Amazon",
      "email": "jobs@amazon.com",
      "industry": "E-Commerce",
      "address": "Seattle, WA",
      "description": "Customer obsession rather than competitor focus, passion for invention, commitment to operational excellence, and long-term thinking.",
      "website": "www.amazon.com"
    },
    {
      "id": "5",
      "name": "Apple",
      "email": "internships@apple.com",
      "industry": "Consumer Electronics",
      "address": "Cupertino, CA",
      "description": "At Apple, we don’t just build products — we create the kind of wonder that’s revolutionized entire industries. Join our hardware or software teams.",
      "website": "www.apple.com"
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF64A9F6); 
    const bgLight = Color(0xFFF5F7F9);    

    // Filtering logic for the search bar
    final filteredCompanies = dummyCompanies.where((company) {
      final name = company["name"].toString().toLowerCase();
      return name.contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          /// 📘 SEARCH HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ]
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: primaryBlue),
                    hintText: "Search company...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          /// 🏢 COMPANY LIST
          Expanded(
            child: filteredCompanies.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  itemCount: filteredCompanies.length,
                  itemBuilder: (context, index) {
                    final company = filteredCompanies[index];
                    return _buildCompanyCard(company, primaryBlue);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("No companies match your search.", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: () {
          // 🚀 Passing the whole 'company' map to the Detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetailScreen(companyData: company),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: themeColor.withOpacity(0.1),
          child: Icon(Icons.business_rounded, color: themeColor, size: 30),
        ),
        title: Text(
          company["name"],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          company["industry"],
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
      ),
    );
  }
}