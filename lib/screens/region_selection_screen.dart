// STEP 2: Region Selection Screen
// Detect user region using device locale or IP.
// Store state and city in user profile.
// Use fallback if location permission is denied.

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../services/region_service.dart';
import '../services/location_service.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_cards.dart';

class RegionSelectionScreen extends StatefulWidget {
  final bool isInitialSetup;
  final VoidCallback? onComplete;

  const RegionSelectionScreen({
    super.key,
    this.isInitialSetup = true,
    this.onComplete,
  });

  @override
  State<RegionSelectionScreen> createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends State<RegionSelectionScreen> {
  String? _selectedState;
  String? _selectedCity;
  String? _selectedVillage;
  String? _detectedRegion;
  bool _isLoading = false;
  bool _isAutoDetecting = true;
  bool _isEditMode = false; // Track if user is in edit mode

  // Major city coordinates for Indian cities
  final Map<String, Map<String, double>> _cityCoordinates = {
    'Mumbai': {'lat': 19.0760, 'lng': 72.8777},
    'Pune': {'lat': 18.5204, 'lng': 73.8567},
    'Nagpur': {'lat': 21.1458, 'lng': 79.0882},
    'Nashik': {'lat': 19.9975, 'lng': 73.7898},
    'Aurangabad': {'lat': 19.8762, 'lng': 75.3433},
    'Bangalore': {'lat': 12.9716, 'lng': 77.5946},
    'Mysore': {'lat': 12.2958, 'lng': 76.6394},
    'Hubli': {'lat': 15.3647, 'lng': 75.1240},
    'Mangalore': {'lat': 12.9141, 'lng': 74.8560},
    'Belgaum': {'lat': 15.8497, 'lng': 74.4977},
    'Chennai': {'lat': 13.0827, 'lng': 80.2707},
    'Coimbatore': {'lat': 11.0168, 'lng': 76.9558},
    'Madurai': {'lat': 9.9252, 'lng': 78.1198},
    'Trichy': {'lat': 10.7905, 'lng': 78.7047},
    'Salem': {'lat': 11.6643, 'lng': 78.1460},
    'Hyderabad': {'lat': 17.3850, 'lng': 78.4867},
    'Medchal-Malkajgiri': {'lat': 17.5297, 'lng': 78.5275},
    'Rangareddy': {'lat': 17.2543, 'lng': 78.0488},
    'Warangal': {'lat': 17.9689, 'lng': 79.5941},
    'Nizamabad': {'lat': 18.6725, 'lng': 78.0941},
    'Karimnagar': {'lat': 18.4386, 'lng': 79.1288},
    'Khammam': {'lat': 17.2473, 'lng': 80.1514},
    'Vijayawada': {'lat': 16.5062, 'lng': 80.6480},
    'Visakhapatnam': {'lat': 17.6868, 'lng': 83.2185},
    'Guntur': {'lat': 16.3067, 'lng': 80.4365},
    'Tirupati': {'lat': 13.6288, 'lng': 79.4192},
    'Nellore': {'lat': 14.4426, 'lng': 79.9865},
    'Kochi': {'lat': 9.9312, 'lng': 76.2673},
    'Thiruvananthapuram': {'lat': 8.5241, 'lng': 76.9366},
    'Kozhikode': {'lat': 11.2588, 'lng': 75.7804},
    'Thrissur': {'lat': 10.5276, 'lng': 76.2144},
    'Kannur': {'lat': 11.8745, 'lng': 75.3704},
    'Kolkata': {'lat': 22.5726, 'lng': 88.3639},
    'Howrah': {'lat': 22.5958, 'lng': 88.2636},
    'Durgapur': {'lat': 23.5204, 'lng': 87.3119},
    'Siliguri': {'lat': 26.7271, 'lng': 88.3953},
    'Asansol': {'lat': 23.6739, 'lng': 86.9524},
    'Ahmedabad': {'lat': 23.0225, 'lng': 72.5714},
    'Surat': {'lat': 21.1702, 'lng': 72.8311},
    'Vadodara': {'lat': 22.3072, 'lng': 73.1812},
    'Rajkot': {'lat': 22.3039, 'lng': 70.8022},
    'Gandhinagar': {'lat': 23.2156, 'lng': 72.6369},
    'Jaipur': {'lat': 26.9124, 'lng': 75.7873},
    'Jodhpur': {'lat': 26.2389, 'lng': 73.0243},
    'Udaipur': {'lat': 24.5854, 'lng': 73.7125},
    'Kota': {'lat': 25.2138, 'lng': 75.8648},
    'Ajmer': {'lat': 26.4499, 'lng': 74.6399},
    'Chandigarh': {'lat': 30.7333, 'lng': 76.7794},
    'Ludhiana': {'lat': 30.9010, 'lng': 75.8573},
    'Amritsar': {'lat': 31.6340, 'lng': 74.8723},
    'Jalandhar': {'lat': 31.3260, 'lng': 75.5762},
    'Patiala': {'lat': 30.3398, 'lng': 76.3869},
    'New Delhi': {'lat': 28.6139, 'lng': 77.2090},
    'Central Delhi': {'lat': 28.6542, 'lng': 77.2373},
    'South Delhi': {'lat': 28.5244, 'lng': 77.2066},
    'North Delhi': {'lat': 28.7282, 'lng': 77.1946},
    'East Delhi': {'lat': 28.6692, 'lng': 77.3125},
    'Lucknow': {'lat': 26.8467, 'lng': 80.9462},
    'Noida': {'lat': 28.5355, 'lng': 77.3910},
    'Kanpur': {'lat': 26.4499, 'lng': 80.3319},
    'Agra': {'lat': 27.1767, 'lng': 78.0081},
    'Varanasi': {'lat': 25.3176, 'lng': 82.9739},
    'Bhopal': {'lat': 23.2599, 'lng': 77.4126},
    'Indore': {'lat': 22.7196, 'lng': 75.8577},
    'Jabalpur': {'lat': 23.1815, 'lng': 79.9864},
    'Gwalior': {'lat': 26.2183, 'lng': 78.1828},
    'Ujjain': {'lat': 23.1765, 'lng': 75.7885},
    'Patna': {'lat': 25.5941, 'lng': 85.1376},
    'Gaya': {'lat': 24.7955, 'lng': 85.0002},
    'Muzaffarpur': {'lat': 26.1225, 'lng': 85.3906},
    'Bhagalpur': {'lat': 25.2425, 'lng': 86.9842},
    'Darbhanga': {'lat': 26.1542, 'lng': 85.8918},
    'Bhubaneswar': {'lat': 20.2961, 'lng': 85.8245},
    'Cuttack': {'lat': 20.5124, 'lng': 85.8829},
    'Rourkela': {'lat': 22.2604, 'lng': 84.8536},
    'Puri': {'lat': 19.8135, 'lng': 85.8312},
    'Sambalpur': {'lat': 21.4669, 'lng': 83.9812},
    'Guwahati': {'lat': 26.1445, 'lng': 91.7362},
    'Silchar': {'lat': 24.8333, 'lng': 92.7789},
    'Dibrugarh': {'lat': 27.4728, 'lng': 94.9120},
    'Jorhat': {'lat': 26.7509, 'lng': 94.2037},
    'Nagaon': {'lat': 26.3479, 'lng': 92.6869},
  };

  final Map<String, List<String>> _stateCities = {
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Trichy', 'Salem'],
    'Telangana': [
      'Hyderabad',
      'Medchal-Malkajgiri',
      'Rangareddy',
      'Warangal',
      'Nizamabad',
      'Karimnagar',
      'Khammam'
    ],
    'Andhra Pradesh': [
      'Vijayawada',
      'Visakhapatnam',
      'Guntur',
      'Tirupati',
      'Nellore'
    ],
    'Kerala': [
      'Kochi',
      'Thiruvananthapuram',
      'Kozhikode',
      'Thrissur',
      'Kannur'
    ],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri', 'Asansol'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Delhi': [
      'New Delhi',
      'Central Delhi',
      'South Delhi',
      'North Delhi',
      'East Delhi'
    ],
    'Uttar Pradesh': ['Lucknow', 'Noida', 'Kanpur', 'Agra', 'Varanasi'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain'],
    'Bihar': ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur', 'Darbhanga'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri', 'Sambalpur'],
    'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon'],
  };

  // Villages/Towns for each city (optional selection)
  final Map<String, List<String>> _cityVillages = {
    // Maharashtra
    'Mumbai': [
      'Andheri',
      'Bandra',
      'Borivali',
      'Dadar',
      'Kurla',
      'Malad',
      'Thane',
      'Vashi',
      'Panvel'
    ],
    'Pune': [
      'Hinjewadi',
      'Kothrud',
      'Hadapsar',
      'Wakad',
      'Baner',
      'Pimpri',
      'Chinchwad',
      'Kharadi'
    ],
    'Nagpur': [
      'Sitabuldi',
      'Dharampeth',
      'Wardha Road',
      'Hingna',
      'Kamptee',
      'Koradi'
    ],
    'Nashik': [
      'Panchavati',
      'Cidco',
      'Satpur',
      'Deolali',
      'Sinnar',
      'Igatpuri'
    ],
    'Aurangabad': ['Cidco', 'Waluj', 'Chikalthana', 'Garkheda', 'Paithan'],
    // Karnataka
    'Bangalore': [
      'Whitefield',
      'Electronic City',
      'Marathahalli',
      'Koramangala',
      'Jayanagar',
      'BTM Layout',
      'HSR Layout',
      'Yelahanka'
    ],
    'Mysore': [
      'Vijayanagar',
      'Kuvempunagar',
      'Hebbal',
      'Jayalakshmipuram',
      'Saraswathipuram'
    ],
    'Hubli': ['Vidyanagar', 'Gokul Road', 'Keshwapur', 'Navanagar', 'Unkal'],
    'Mangalore': ['Bejai', 'Kadri', 'Kankanady', 'Falnir', 'Hampankatta'],
    'Belgaum': ['Tilakwadi', 'Shahapur', 'Vadgaon', 'Hindwadi', 'Camp'],
    // Tamil Nadu
    'Chennai': [
      'T. Nagar',
      'Anna Nagar',
      'Adyar',
      'Velachery',
      'Tambaram',
      'Porur',
      'Sholinganallur',
      'OMR'
    ],
    'Coimbatore': [
      'RS Puram',
      'Gandhipuram',
      'Peelamedu',
      'Saibaba Colony',
      'Singanallur'
    ],
    'Madurai': [
      'Anna Nagar',
      'KK Nagar',
      'Thirunagar',
      'Villapuram',
      'Pasumalai'
    ],
    'Trichy': [
      'Srirangam',
      'Thillai Nagar',
      'Cantonment',
      'KK Nagar',
      'Woraiyur'
    ],
    'Salem': [
      'Fairlands',
      'Hasthampatti',
      'Shevapet',
      'Ammapet',
      'Kondalampatti'
    ],
    // Telangana
    'Hyderabad': [
      'Gachibowli',
      'Hitech City',
      'Madhapur',
      'Kondapur',
      'Kukatpally',
      'Secunderabad',
      'Begumpet',
      'Jubilee Hills',
      'Banjara Hills',
      'LB Nagar',
      'Dilsukhnagar'
    ],
    'Medchal-Malkajgiri': [
      'Kompally',
      'Alwal',
      'Malkajgiri',
      'Medchal',
      'Boduppal',
      'Dammaiguda',
      'Keesara',
      'Uppal',
      'Nacharam',
      'Habsiguda',
      'Tarnaka',
      'Sainikpuri',
      'AS Rao Nagar',
      'ECIL',
      'Kushaiguda',
      'Moula Ali',
      'Nagaram',
      'Pocharam',
      'Ghatkesar',
      'Jawaharnagar'
    ],
    'Rangareddy': [
      'Shamshabad',
      'Shadnagar',
      'Maheshwaram',
      'Ibrahimpatnam',
      'Kandukur',
      'Chevella',
      'Moinabad',
      'Rajendranagar',
      'Shankarpally',
      'Narsingi',
      'Gandipet',
      'Mokila',
      'Tellapur',
      'Patancheru',
      'Sangareddy',
      'Miyapur',
      'Chandanagar',
      'Lingampally',
      'Nallagandla',
      'Manikonda',
      'Puppalaguda',
      'Kokapet'
    ],
    'Warangal': [
      'Hanamkonda',
      'Kazipet',
      'Subedari',
      'Warangal Fort',
      'Bheemaram'
    ],
    'Nizamabad': ['Armoor', 'Bodhan', 'Kamareddy', 'Banswada', 'Yellareddy'],
    'Karimnagar': [
      'Jagitial',
      'Peddapalli',
      'Huzurabad',
      'Sircilla',
      'Mancherial'
    ],
    'Khammam': ['Kothagudem', 'Bhadrachalam', 'Sathupalli', 'Wyra', 'Madhira'],
    // Andhra Pradesh
    'Vijayawada': [
      'Benz Circle',
      'Governorpet',
      'Labbipet',
      'Moghalrajpuram',
      'Patamata'
    ],
    'Visakhapatnam': [
      'Gajuwaka',
      'MVP Colony',
      'Seethammadhara',
      'Madhurawada',
      'Rushikonda'
    ],
    'Guntur': [
      'Brodipet',
      'Arundelpet',
      'Lakshmipuram',
      'Nagarampalem',
      'AT Agraharam'
    ],
    'Tirupati': [
      'Tirumala',
      'Alipiri',
      'Renigunta',
      'Chandragiri',
      'Srikalahasti'
    ],
    'Nellore': [
      'Magunta Layout',
      'Vedayapalem',
      'Balaji Nagar',
      'Muthukur',
      'Kavali'
    ],
    // Kerala
    'Kochi': [
      'Ernakulam',
      'Fort Kochi',
      'Kakkanad',
      'Edappally',
      'Vyttila',
      'Kaloor'
    ],
    'Thiruvananthapuram': [
      'Technopark',
      'Kazhakootam',
      'Varkala',
      'Kovalam',
      'Attingal'
    ],
    'Kozhikode': [
      'Palayam',
      'Nadakkavu',
      'Vellimadukunnu',
      'Kunnamangalam',
      'Feroke'
    ],
    'Thrissur': [
      'Swaraj Round',
      'Punkunnam',
      'Ayyanthole',
      'Ollur',
      'Chalakudy'
    ],
    'Kannur': [
      'Thavakkara',
      'Pallikkunnu',
      'Thalassery',
      'Payyanur',
      'Mattannur'
    ],
    // West Bengal
    'Kolkata': [
      'Salt Lake',
      'New Town',
      'Behala',
      'Tollygunge',
      'Dum Dum',
      'Howrah Bridge'
    ],
    'Howrah': ['Shibpur', 'Liluah', 'Belur', 'Santragachi', 'Bally'],
    'Durgapur': [
      'City Centre',
      'Benachity',
      'Bidhannagar',
      'Steel Township',
      'Andal'
    ],
    'Siliguri': [
      'Pradhan Nagar',
      'Sevoke Road',
      'Matigara',
      'Bagdogra',
      'Sukna'
    ],
    'Asansol': ['Burnpur', 'Raniganj', 'Kulti', 'Barakar', 'Jamuria'],
    // Gujarat
    'Ahmedabad': [
      'SG Highway',
      'Satellite',
      'Bopal',
      'Navrangpura',
      'Maninagar',
      'Vastrapur'
    ],
    'Surat': ['Adajan', 'Vesu', 'Athwa', 'Katargam', 'Varachha'],
    'Vadodara': ['Alkapuri', 'Gotri', 'Manjalpur', 'Akota', 'Karelibaug'],
    'Rajkot': [
      'Kalawad Road',
      'University Road',
      'Mavdi',
      'Bhaktinagar',
      'Raiya Road'
    ],
    'Gandhinagar': [
      'Sector 21',
      'Infocity',
      'GIFT City',
      'Kudasan',
      'Sargasan'
    ],
    // Rajasthan
    'Jaipur': [
      'Malviya Nagar',
      'Vaishali Nagar',
      'Mansarovar',
      'Jagatpura',
      'Sanganer'
    ],
    'Jodhpur': ['Sardarpura', 'Ratanada', 'Paota', 'Shastri Nagar', 'Mandore'],
    'Udaipur': [
      'Fateh Sagar',
      'City Palace',
      'Hiran Magri',
      'Pratap Nagar',
      'Bhuwana'
    ],
    'Kota': ['Talwandi', 'Mahaveer Nagar', 'Kunhari', 'Borkhera', 'Rangbari'],
    'Ajmer': [
      'Vaishali Nagar',
      'Adarsh Nagar',
      'Nasirabad',
      'Beawar',
      'Kishangarh'
    ],
    // Punjab
    'Chandigarh': [
      'Sector 17',
      'Sector 22',
      'Sector 35',
      'Mohali',
      'Panchkula'
    ],
    'Ludhiana': ['Model Town', 'Sarabha Nagar', 'Dugri', 'Jamalpur', 'Khanna'],
    'Amritsar': [
      'Ranjit Avenue',
      'Lawrence Road',
      'Mall Road',
      'Majitha Road',
      'Chheharta'
    ],
    'Jalandhar': [
      'Model Town',
      'Mota Singh Nagar',
      'Rama Mandi',
      'Nakodar',
      'Phagwara'
    ],
    'Patiala': ['Model Town', 'Rajpura', 'Nabha', 'Samana', 'Ghagga'],
    // Delhi
    'New Delhi': [
      'Connaught Place',
      'Chanakyapuri',
      'Saket',
      'Hauz Khas',
      'Vasant Kunj'
    ],
    'Central Delhi': [
      'Karol Bagh',
      'Paharganj',
      'Rajendra Place',
      'Patel Nagar',
      'Daryaganj'
    ],
    'South Delhi': [
      'Greater Kailash',
      'Lajpat Nagar',
      'Defence Colony',
      'Green Park',
      'Malviya Nagar'
    ],
    'North Delhi': [
      'Model Town',
      'Pitampura',
      'Rohini',
      'Shalimar Bagh',
      'Wazirpur'
    ],
    'East Delhi': [
      'Preet Vihar',
      'Laxmi Nagar',
      'Mayur Vihar',
      'Patparganj',
      'Shahdara'
    ],
    // Uttar Pradesh
    'Lucknow': [
      'Hazratganj',
      'Gomti Nagar',
      'Aliganj',
      'Indira Nagar',
      'Mahanagar'
    ],
    'Noida': [
      'Sector 62',
      'Sector 18',
      'Greater Noida',
      'Sector 63',
      'Sector 137'
    ],
    'Kanpur': [
      'Civil Lines',
      'Swaroop Nagar',
      'Kakadeo',
      'Kidwai Nagar',
      'Shastri Nagar'
    ],
    'Agra': [
      'Tajganj',
      'Sikandra',
      'Dayalbagh',
      'Kamla Nagar',
      'Fatehabad Road'
    ],
    'Varanasi': ['Assi Ghat', 'Lanka', 'Sigra', 'Bhelupur', 'Cantonment'],
    // Madhya Pradesh
    'Bhopal': [
      'MP Nagar',
      'Arera Colony',
      'Kolar Road',
      'Shahpura',
      'Hoshangabad Road'
    ],
    'Indore': [
      'Vijay Nagar',
      'Palasia',
      'Sapna Sangeeta',
      'MG Road',
      'Bhawarkuan'
    ],
    'Jabalpur': [
      'Wright Town',
      'Napier Town',
      'Civil Lines',
      'Madan Mahal',
      'Gorakhpur'
    ],
    'Gwalior': ['City Centre', 'Lashkar', 'Morar', 'Thatipur', 'Maharajpura'],
    'Ujjain': [
      'Freeganj',
      'Dewas Gate',
      'Madhav Nagar',
      'Nanakheda',
      'Tower Chowk'
    ],
    // Bihar
    'Patna': [
      'Boring Road',
      'Kankarbagh',
      'Patna City',
      'Rajendra Nagar',
      'Bailey Road'
    ],
    'Gaya': [
      'Station Road',
      'Bodh Gaya',
      'Civil Lines',
      'Magadh University',
      'Tekari'
    ],
    'Muzaffarpur': [
      'Mithanpura',
      'Saraiyaganj',
      'Juran Chapra',
      'Kanti',
      'Motipur'
    ],
    'Bhagalpur': [
      'Adampur',
      'Tilka Manjhi',
      'Sabour',
      'Kahalgaon',
      'Sultanganj'
    ],
    'Darbhanga': ['Laheriasarai', 'Benta', 'Baheri', 'Keoti', 'Jale'],
    // Odisha
    'Bhubaneswar': [
      'Saheed Nagar',
      'Patia',
      'Chandrasekharpur',
      'Nayapalli',
      'Khandagiri'
    ],
    'Cuttack': [
      'Buxi Bazaar',
      'College Square',
      'Badambadi',
      'Chauliaganj',
      'Jobra'
    ],
    'Rourkela': [
      'Sector 20',
      'Civil Township',
      'Udit Nagar',
      'Panposh',
      'Bondamunda'
    ],
    'Puri': ['Grand Road', 'Swargadwar', 'Chakratirtha', 'Balighai', 'Konark'],
    'Sambalpur': ['Khetrajpur', 'Modipara', 'Ainthapali', 'Burla', 'Hirakud'],
    // Assam
    'Guwahati': [
      'Paltan Bazaar',
      'Dispur',
      'Zoo Road',
      'Ganeshguri',
      'Chandmari'
    ],
    'Silchar': [
      'Rangirkhari',
      'Ambicapatty',
      'Tarapur',
      'Udharbond',
      'Lakhipur'
    ],
    'Dibrugarh': [
      'AT Road',
      'Chowkidinghee',
      'Graham Bazaar',
      'Mancotta',
      'Jalan Nagar'
    ],
    'Jorhat': ['Na Ali', 'AT Road', 'Gar Ali', 'Tarajan', 'Cinnamara'],
    'Nagaon': ['Haibargaon', 'Nagaon Town', 'Kaliabor', 'Dhing', 'Raha'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.isInitialSetup) {
      _autoDetectRegion();
    } else {
      _loadSavedRegion();
    }
  }

  Future<void> _loadSavedRegion() async {
    setState(() => _isAutoDetecting = true);

    try {
      final regionData = await RegionService.getStoredRegion();
      print('📖 Loading saved region: $regionData');
      setState(() {
        _selectedState = regionData['state'];
        _selectedCity = regionData['city'];
        _selectedVillage = (regionData['village'] != null &&
                regionData['village'].toString().isNotEmpty)
            ? regionData['village']
            : null;
        _detectedRegion = regionData['region'];
      });
    } catch (e) {
      print('Error loading saved region: $e');
    } finally {
      setState(() => _isAutoDetecting = false);
    }
  }

  Future<void> _autoDetectRegion() async {
    setState(() => _isAutoDetecting = true);

    try {
      // Use new LocationService for more accurate detection
      final locationService = LocationService();
      final locationData = await locationService.autoDetectLocation();

      if (locationData != null) {
        setState(() {
          _selectedState = locationData.state;
          _selectedCity = locationData.district.isNotEmpty
              ? locationData.district
              : locationData.city;
          _selectedVillage =
              locationData.village.isNotEmpty ? locationData.village : null;
          _detectedRegion = locationData.displayString;
        });
        print('✅ Auto-detected location: ${locationData.displayString}');
      } else {
        // Fallback to RegionService
        final regionData = await RegionService.autoDetectRegion();
        setState(() {
          _selectedState = regionData['state'];
          _selectedCity = regionData['city'];
          _detectedRegion = regionData['region'];
        });
      }
    } catch (e) {
      print('Error auto-detecting region: $e');
      // Fallback to manual selection
    } finally {
      setState(() => _isAutoDetecting = false);
    }
  }

  Future<void> _saveAndContinue() async {
    print('🚀 _saveAndContinue called');
    print('   State: $_selectedState');
    print('   City: $_selectedCity');

    if (_selectedState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your state')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final region = RegionService.getRegionFromState(_selectedState!);
      print('   Region: $region');

      // Get coordinates for the selected city
      double? latitude;
      double? longitude;

      if (_selectedCity != null) {
        final coords = _cityCoordinates[_selectedCity];
        if (coords != null) {
          latitude = coords['lat'];
          longitude = coords['lng'];
        } else {
          // Try geocoding if coordinates not found in static map
          try {
            List<Location> locations = await locationFromAddress(
              '$_selectedCity, $_selectedState, India',
            );
            if (locations.isNotEmpty) {
              latitude = locations.first.latitude;
              longitude = locations.first.longitude;
            }
          } catch (e) {
            // Ignore geocoding errors, coordinates will be null
          }
        }
      }

      await RegionService.saveRegion(
        region: region,
        state: _selectedState!,
        city: _selectedCity ?? '',
        village: _selectedVillage,
        latitude: latitude,
        longitude: longitude,
      );

      if (mounted) {
        if (widget.isInitialSetup) {
          // Mark first launch as complete
          await context.read<AppState>().completeFirstLaunch();

          // For initial setup, navigate directly to home screen
          widget.onComplete?.call();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          // For region change from home screen
          widget.onComplete?.call();
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving region: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isInitialSetup
          ? null
          : AppBar(
              title: const Text('Change Region'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  if (widget.isInitialSetup) const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Your Region',
                    style: AppTextStyles.headline1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us show you the most relevant local content',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            if (_isAutoDetecting)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Detecting your location...'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Selection Box - Always visible when location detected
                      if (_selectedState != null &&
                          _selectedCity != null &&
                          !_isEditMode) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade600),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Selection',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _selectedVillage != null
                                          ? '$_selectedVillage, ${_selectedCity ?? ''}, ${_selectedState ?? ''}'
                                          : '${_selectedCity ?? ''}, ${_selectedState ?? ''}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    _isEditMode = true;
                                  });
                                },
                                tooltip: 'Edit Location',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Edit Mode - Show dropdowns
                      if (_isEditMode || _selectedState == null) ...[
                        // Back button when in edit mode
                        if (_isEditMode) ...[
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  setState(() {
                                    _isEditMode = false;
                                  });
                                },
                                tooltip: 'Cancel',
                              ),
                              const Text(
                                'Edit Location',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        const Text(
                          'State *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: (_stateCities.containsKey(_selectedState))
                                  ? _selectedState
                                  : null,
                              isExpanded: true,
                              hint: const Text('Select your state'),
                              icon: const Icon(Icons.arrow_drop_down, size: 28),
                              items: _stateCities.keys.map((state) {
                                return DropdownMenuItem(
                                  value: state,
                                  child: Text(state),
                                );
                              }).toList(),
                              onChanged: (value) {
                                print('State selected: $value');
                                setState(() {
                                  _selectedState = value;
                                  _selectedCity = null;
                                  _selectedVillage = null;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'District',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: (_selectedState != null &&
                                      _selectedCity != null &&
                                      (_stateCities[_selectedState]
                                              ?.contains(_selectedCity) ??
                                          false))
                                  ? _selectedCity
                                  : null,
                              isExpanded: true,
                              hint: const Text('Select your district'),
                              icon: const Icon(Icons.arrow_drop_down, size: 28),
                              items: (_stateCities[_selectedState] ?? [])
                                  .map((city) {
                                return DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                );
                              }).toList(),
                              onChanged: _selectedState == null
                                  ? null
                                  : (value) {
                                      print('City selected: $value');
                                      setState(() {
                                        _selectedCity = value;
                                        _selectedVillage =
                                            null; // Reset village when city changes
                                      });
                                    },
                            ),
                          ),
                        ),

                        // Village/Town dropdown (optional)
                        if (_selectedCity != null &&
                            _cityVillages.containsKey(_selectedCity)) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Village/Town (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: (_selectedVillage != null &&
                                        (_cityVillages[_selectedCity]
                                                ?.contains(_selectedVillage) ??
                                            false))
                                    ? _selectedVillage
                                    : null,
                                isExpanded: true,
                                hint: const Text('Select your village/town'),
                                icon:
                                    const Icon(Icons.arrow_drop_down, size: 28),
                                items: (_cityVillages[_selectedCity] ?? [])
                                    .map((village) {
                                  return DropdownMenuItem(
                                    value: village,
                                    child: Text(village),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  print('Village selected: $value');
                                  setState(() => _selectedVillage = value);
                                },
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ], // Close Edit Mode section

                      // Region preview
                      if (_selectedState != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.map, color: Colors.blue.shade600),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your Region',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${RegionService.getRegionFromState(_selectedState!)} India',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

            // Continue button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading || _isAutoDetecting
                        ? null
                        : _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
