import 'package:flutter/material.dart';

// 🏢 SCREEN 1: THE COMPANY LIST (The Companies Tab)
class PrincipalCompanyTab extends StatefulWidget {
  const PrincipalCompanyTab({super.key});

  @override
  State<PrincipalCompanyTab> createState() => _PrincipalCompanyTabState();
}

class _PrincipalCompanyTabState extends State<PrincipalCompanyTab> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  // 📝 EXTENDED LOCAL DATA
  final List<Map<String, dynamic>> dummyCompanies = [
    {
      "name": "Google",
      "industry": "Tech & AI",
      "email": "hr@google.com",
      "website": "www.google.com",
      "description":
          "Google's mission is to organize the world's information and make it universally accessible and useful. We offer internship roles in Software Engineering, Data Science, and Product Management.",
    },
    {
      "name": "Tesla",
      "industry": "Automotive",
      "email": "careers@tesla.com",
      "website": "www.tesla.com",
      "description":
          "Accelerating the world's transition to sustainable energy through electric vehicles, solar, and integrated renewable energy solutions.",
    },
    {
      "name": "Microsoft",
      "industry": "Software",
      "email": "recruitment@microsoft.com",
      "website": "www.microsoft.com",
      "description":
          "Empowering every person and organization on the planet to achieve more. Join us for world-class mentorship and innovative projects.",
    },
    {
      "name": "Amazon",
      "industry": "E-Commerce",
      "email": "jobs@amazon.com",
      "website": "www.amazon.com",
      "description":
          "Customer obsession rather than competitor focus, passion for invention, commitment to operational excellence, and long-term thinking.",
    },
    {
      "name": "Apple",
      "industry": "Consumer Electronics",
      "email": "internships@apple.com",
      "website": "www.apple.com",
      "description":
          "At Apple, we don’t just build products — we create the kind of wonder that’s revolutionized entire industries. Join our hardware or software teams.",
    },
    {
      "name": "Meta",
      "industry": "Social Media & AI",
      "email": "careers@meta.com",
      "website": "www.meta.com",
      "description":
          "Building the future of social connection through virtual reality and artificial intelligence.",
    },
    {
      "name": "Netflix",
      "industry": "Entertainment",
      "email": "talent@netflix.com",
      "website": "www.netflix.com",
      "description":
          "Reinventing how people watch movies and TV shows through cutting-edge cloud engineering and algorithms.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF64A9F6);

    final filteredCompanies = dummyCompanies.where((company) {
      return company["name"].toString().toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // 📘 SEARCH HEADER (Exact Match to image_05fdf9.png)
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
                    setState(() => searchQuery = value.toLowerCase()),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search company...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 🏢 LIST OF COMPANIES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCompanies.length,
              itemBuilder: (context, index) {
                final company = filteredCompanies[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: primaryBlue.withOpacity(0.1),
                      child: const Icon(
                        Icons.business_rounded,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      company["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      company["industry"],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PrincipalCompanyDetailsScreen(companyData: company),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 📄 SCREEN 2: THE DETAILS VIEW (Exact Match to image_05fe53.jpg)
class PrincipalCompanyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> companyData;
  const PrincipalCompanyDetailsScreen({super.key, required this.companyData});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF64A9F6);

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
            // 🟦 BLUE HEADER WITH LOGO
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
                    child: const Icon(
                      Icons.business_rounded,
                      size: 50,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    companyData["name"],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    companyData["industry"],
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
                      companyData["description"],
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
                    companyData["email"],
                    primaryBlue,
                  ),
                  _buildContactRow(
                    Icons.language_outlined,
                    "Website",
                    companyData["website"],
                    primaryBlue,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Contact Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
          Column(
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
        ],
      ),
    );
  }
}
