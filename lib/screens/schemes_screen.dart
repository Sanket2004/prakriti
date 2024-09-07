import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prakriti/responsive/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final List<Scheme> schemes = [
    Scheme(
      title: 'Pradhan Mantri Krishi Sinchai Yojana (PMKSY)',
      description:
          'A national mission to improve farm productivity and ensure better utilization of the resources in the country.',
      link: 'https://pmksy.gov.in',
    ),
    Scheme(
      title: 'Soil Health Card Scheme',
      description:
          'The Soil Health Card Scheme provides farmers with information on the nutrient status of their soil and how to improve it.',
      link: 'https://soilhealth.dac.gov.in',
    ),
    Scheme(
      title: 'Rashtriya Krishi Vikas Yojana (RKVY)',
      description:
          'A scheme to incentivize states to increase public investment in agriculture and allied sectors.',
      link: 'https://rkvy.nic.in',
    ),
    Scheme(
      title: 'National Mission for Sustainable Agriculture (NMSA)',
      description:
          'A mission aimed at promoting sustainable agriculture through various strategies, including soil conservation, water use efficiency, and nutrient management.',
      link: 'https://nmsa.dac.gov.in',
    ),
    Scheme(
      title: 'NABARD - Scheme for Agriculture & Rural Development',
      description:
          'NABARD\'s schemes for the development of agriculture and rural areas.',
      link: 'https://www.nabard.org/',
    ),
  ];

  final List<Scheme> loans = [
    Scheme(
      title: 'Punjab National Bank (PNB) - Agriculture Loan',
      description:
          'Agriculture loan services offered by PNB for farmers and agricultural sectors.',
      link: 'https://www.pnbindia.in/agriculture-credit-schemes.html',
    ),
    Scheme(
      title: 'Bank of India (BOI) - Agri Scheme Loans',
      description:
          'Agriculture loan schemes provided by Bank of India to support farming activities.',
      link: 'https://bankofindia.co.in/',
    ),
    Scheme(
      title: 'Central Bank of India - Agricultural Term Loan',
      description:
          'Agricultural term loans from Central Bank of India for agricultural purposes.',
      link: 'https://www.centralbankofindia.co.in/en',
    ),
    Scheme(
      title: 'Bank of Baroda - Agriculture Loan',
      description: 'Loans from Bank of Baroda for the agricultural sector.',
      link: 'https://www.bankofbaroda.in/',
    ),
    Scheme(
      title: 'Union Bank of India - Agricultural Loans',
      description: 'Agricultural loans from Union Bank of India.',
      link:
          'https://www.unionbankofindia.co.in/?__cf_chl_tk=Udb3eZ7Knvu3bq4E4s_9kTsxgGgqTwKuRTCcDtYB5qw-1725655256-0.0.1.1-4820',
    ),
    Scheme(
      title: 'Canara Bank - Agricultural Term Loans',
      description:
          'Agricultural term loans provided by Canara Bank for agricultural needs.',
      link: 'https://www.canarabank.com/',
    ),
    Scheme(
      title: 'UCO Bank - Agricultural Loans',
      description: 'Loans from UCO Bank for agricultural purposes.',
      link: 'https://www.ucobank.com/en/',
    ),
    Scheme(
      title: 'IDBI Bank - Agri Loans',
      description:
          'Agricultural loans from IDBI Bank for farming and allied activities.',
      link: 'https://www.idbibank.in/',
    ),
    Scheme(
      title: 'Indian Bank - Agriculture Loans',
      description:
          'Indian Bank provides agricultural loans for various farming purposes.',
      link: 'https://www.indianbank.in/',
    ),
    Scheme(
      title: 'YES Bank - Agricultural Loans',
      description: 'Agricultural loans provided by YES Bank.',
      link: 'https://www.yesbank.in/',
    ),
    Scheme(
      title: 'Federal Bank - Kisan Credit Loan',
      description:
          'Federal Bank\'s Kisan Credit Loan for agricultural activities.',
      link: 'https://www.federalbank.co.in/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs (Schemes & Loans)
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Government Schemes & Loans',
            style: GoogleFonts.amaranth(
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Schemes'),
              Tab(text: 'Loans'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildSchemeList(schemes),
            buildSchemeList(loans),
          ],
        ),
      ),
    );
  }

  Widget buildSchemeList(List<Scheme> items) {
    return ResponsiveWrapper(
      child: ListView.builder(
        itemCount: items.length,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Card(
            color: Colors.grey.shade100,
            elevation: 0,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index].title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    items[index].description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _launchURL(items[index].link);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(67, 160, 71, 1),
                    ),
                    child: const Text(
                      'Learn More',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    try {
      if (await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    } catch (e) {
      print(e);
    }
  }
}

class Scheme {
  final String title;
  final String description;
  final String link;

  Scheme({
    required this.title,
    required this.description,
    required this.link,
  });
}
