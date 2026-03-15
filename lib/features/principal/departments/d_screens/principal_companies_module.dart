import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrincipalCompanyTab extends StatefulWidget {
  const PrincipalCompanyTab({super.key});

  @override
  State<PrincipalCompanyTab> createState() => _PrincipalCompanyTabState();
}

class _PrincipalCompanyTabState extends State<PrincipalCompanyTab> {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 30),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => searchQuery = value.trim().toLowerCase()),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search company...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection("company").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState("No companies found");
                }

                final companies = snapshot.data!.docs;
                final filteredCompanies = companies.where((doc) {
                  final data = doc.data();
                  final name = (data["name"] ?? "").toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (filteredCompanies.isEmpty) {
                  return _buildEmptyState("No companies match your search");
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredCompanies.length,
                  itemBuilder: (context, index) {
                    final company = filteredCompanies[index].data();
                    final logoUrl =
                        (company["logoUrl"] ?? company["companyLogoUrl"] ?? "")
                            .toString();
                    final experience = (company["experience"] ?? "N/A").toString();
                    final internCount = company["internCount"] ?? 0;
                    final courses = company["courses"] is List
                        ? List.from(company["courses"] as List)
                        : const [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrincipalCompanyDetailsScreen(
                                  companyData: company,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          primaryBlue.withOpacity(0.1),
                                      backgroundImage: logoUrl.isNotEmpty
                                          ? NetworkImage(logoUrl)
                                          : null,
                                      child: logoUrl.isEmpty
                                          ? const Icon(
                                              Icons.business_rounded,
                                              color: primaryBlue,
                                              size: 30,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (company["name"] ?? "Unknown Company")
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            (company["industry"] ?? "Technology")
                                                .toString(),
                                            style: TextStyle(
                                              color: primaryBlue,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSmallStat(
                                      Icons.history,
                                      "$experience Exp",
                                    ),
                                    _buildSmallStat(
                                      Icons.people_outline,
                                      "$internCount Interns",
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "${courses.length} Courses",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class PrincipalCompanyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> companyData;
  const PrincipalCompanyDetailsScreen({super.key, required this.companyData});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF64A9F6);
    final logoUrl =
        (companyData["logoUrl"] ?? companyData["companyLogoUrl"] ?? "").toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Company Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 40),
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
                      child: logoUrl.isEmpty
                          ? const Icon(
                              Icons.business_rounded,
                              size: 50,
                              color: primaryBlue,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    (companyData["name"] ?? "Unknown Company").toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    (companyData["industry"] ?? "Technology").toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "About Company",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (companyData["about"] ??
                              companyData["description"] ??
                              "No description available.")
                          .toString(),
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Contact Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildContactRow(
                    Icons.email_outlined,
                    "Email",
                    (companyData["email"] ?? "Not available").toString(),
                    primaryBlue,
                  ),
                  _buildContactRow(
                    Icons.language_outlined,
                    "Website",
                    (companyData["website"] ?? "Not available").toString(),
                    primaryBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
