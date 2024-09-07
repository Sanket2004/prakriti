import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prakriti/responsive/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final List<String> markets = [
    'Vegetable Market',
    'Fertilizer suppliers',
    'Seed suppliers',
    'Tractor dealers',
    'Irrigation equipment providers',
    'Farmers markets',
    'Agricultural equipment repair',
    'Veterinary clinics',
    'Organic produce markets',
    'Pesticide sellers',
  ];

  final List<IconData> marketIcons = [
    HugeIcons.strokeRoundedLeaf01,
    HugeIcons.strokeRoundedFlower,
    HugeIcons.strokeRoundedPlant04,
    HugeIcons.strokeRoundedTractor,
    HugeIcons.strokeRoundedDroplet,
    HugeIcons.strokeRoundedShoppingCart01,
    HugeIcons.strokeRoundedWrench01,
    HugeIcons.strokeRoundedInjection,
    HugeIcons.strokeRoundedOrganicFood,
    HugeIcons.strokeRoundedBug01,
  ];

  final List<String> transport = [
    'Agricultural trucks',
    'Farm equipment transport services',
    'Livestock transport services',
    'Grain transport services',
    'Bulk fertilizer transport',
    'Seed transport services',
    'Irrigation equipment transport',
    'Produce delivery services',
    'Cold storage transport',
    'Farm machinery rental services',
  ];

  final List<IconData> transportIcons = [
    HugeIcons.strokeRoundedTruck,
    HugeIcons.strokeRoundedTractor,
    HugeIcons.strokeRoundedCowboyHat,
    HugeIcons.strokeRoundedColors,
    HugeIcons.strokeRoundedContainerTruck02,
    HugeIcons.strokeRoundedPlant02,
    HugeIcons.strokeRoundedWaterEnergy,
    HugeIcons.strokeRoundedVan,
    HugeIcons.strokeRoundedCloud,
    HugeIcons.strokeRoundedSettings03,
  ];

  final List<String> emergency = [
    'Hospitals',
    'Bus Stops',
    'Taxi',
    'Pharmacy',
    'Police Station',
    'Ambulance'
  ];

  final List<IconData> emergencyIcons = [
    HugeIcons.strokeRoundedHospital02,
    HugeIcons.strokeRoundedBus01,
    HugeIcons.strokeRoundedTaxi,
    HugeIcons.strokeRoundedMedicine02,
    HugeIcons.strokeRoundedPoliceBadge,
    HugeIcons.strokeRoundedAmbulance,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agri Market',
          style: GoogleFonts.amaranth(
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Section(
                  title: 'Markets',
                  items: markets,
                  icons: marketIcons,
                ),
                Section(
                  title: 'Perennial Products',
                  items: transport,
                  icons: transportIcons,
                ),
                Section(
                  title: 'Essential Services',
                  items: emergency,
                  icons: emergencyIcons,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<String> items;
  final List<IconData> icons;
  final Color? backgroundColor;

  const Section({
    super.key,
    required this.title,
    required this.items,
    required this.icons,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.amaranth(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff399918),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                color: Colors.grey.shade100,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  leading: Icon(icons[index], color: Colors.green),
                  title: Text(items[index]),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${items[index]} selected')),
                    );
                    final Uri _url = Uri.parse(
                        "https://www.google.co.in/maps/search/nearby ${items[index]}");
                    try {
                      if (await launchUrl(_url)) {
                        throw Exception('Could not launch $_url');
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
