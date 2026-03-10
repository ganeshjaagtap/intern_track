import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/features/student/models/company_details_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const primaryBlue = Color(0xFF64A9F6);
    const bgLight = Color(0xFFF5F7F9);

    return Scaffold(
      backgroundColor: bgLight,

      body: Column(
        children: [

          /// 🔎 SEARCH HEADER
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
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10)
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

          /// 🏢 COMPANY LIST FROM FIREBASE
          Expanded(

            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("company")
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {

                  return _buildEmptyState();
                }

                final companies = snapshot.data!.docs;

                /// 🔎 SEARCH FILTER
                final filteredCompanies = companies.where((doc) {

                  final data =
                  doc.data() as Map<String, dynamic>;

                  final name =
                  (data["name"] ?? "").toString().toLowerCase();

                  return name.contains(searchQuery);

                }).toList();

                if (filteredCompanies.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(

                  padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15),

                  itemCount: filteredCompanies.length,

                  itemBuilder: (context, index) {

                    final data = filteredCompanies[index]
                        .data() as Map<String, dynamic>;

                    return _buildCompanyCard(data, primaryBlue);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// EMPTY STATE
  Widget _buildEmptyState() {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(Icons.search_off,
              size: 80,
              color: Colors.grey[300]),

          const SizedBox(height: 10),

          Text(
            "No companies found",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// COMPANY CARD
  Widget _buildCompanyCard(
      Map<String, dynamic> company,
      Color themeColor) {

    return Container(

      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),

      child: ListTile(

        onTap: () {

          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) =>
                  CompanyDetailScreen(
                      companyData: company),
            ),
          );
        },

        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10),

        leading: CircleAvatar(
          radius: 28,
          backgroundColor: themeColor.withOpacity(0.1),

          child: Icon(
            Icons.business_rounded,
            color: themeColor,
            size: 30,
          ),
        ),

        title: Text(
          company["name"] ?? "",
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),

        subtitle: Text(
          company["industry"] ?? "",
          style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }
}