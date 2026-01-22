import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CommunitySupportScreen extends StatefulWidget {
  const CommunitySupportScreen({super.key});

  @override
  State<CommunitySupportScreen> createState() => _CommunitySupportScreenState();
}

class _CommunitySupportScreenState extends State<CommunitySupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityHelp),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
                icon: const Icon(Icons.volunteer_activism),
                text: l10n.helpAndSupport),
            Tab(
                icon: const Icon(Icons.report_problem),
                text: l10n.reportIssues),
            Tab(
                icon: const Icon(Icons.account_balance),
                text: l10n.civicServices),
            Tab(icon: const Icon(Icons.payment), text: l10n.billPayments),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHelpSupportTab(),
          _buildReportIssuesTab(),
          _buildCivicServicesTab(),
          _buildBillPaymentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionDialog(),
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Quick Action'),
      ),
    );
  }

  Widget _buildHelpSupportTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Blood Donation Section
        _buildSectionHeader(
            'Blood Donation Requests', Icons.bloodtype, Colors.red),
        const SizedBox(height: 12),
        _buildBloodDonationCard(
          bloodGroup: 'O+',
          patientName: 'Ramesh Kumar',
          hospital: 'Apollo Hospital, Jubilee Hills',
          urgency: 'Urgent',
          unitsNeeded: 2,
          contact: '+91 98765 43210',
          postedDate: '2 hours ago',
        ),
        const SizedBox(height: 12),
        _buildBloodDonationCard(
          bloodGroup: 'AB-',
          patientName: 'Priya Sharma',
          hospital: 'Care Hospital, Banjara Hills',
          urgency: 'Critical',
          unitsNeeded: 3,
          contact: '+91 98765 43211',
          postedDate: '5 hours ago',
        ),
        const SizedBox(height: 24),

        // Volunteer Opportunities
        _buildSectionHeader(
            'Volunteer Opportunities', Icons.groups, Colors.blue),
        const SizedBox(height: 12),
        _buildVolunteerCard(
          title: 'Food Distribution Drive',
          organization: 'Hope Foundation',
          location: 'Kukatpally, 8 km',
          date: 'Tomorrow, 9 AM - 1 PM',
          volunteersNeeded: 15,
          volunteersJoined: 8,
          description: 'Help distribute food to underprivileged communities',
        ),
        const SizedBox(height: 12),
        _buildVolunteerCard(
          title: 'Beach Cleaning Activity',
          organization: 'Green Hyderabad',
          location: 'Hussain Sagar Lake',
          date: 'Sunday, 6 AM - 10 AM',
          volunteersNeeded: 25,
          volunteersJoined: 12,
          description: 'Join us to clean and beautify our lake',
        ),
        const SizedBox(height: 24),

        // Help for Elderly/Disabled
        _buildSectionHeader('Help Needed', Icons.accessibility, Colors.orange),
        const SizedBox(height: 12),
        _buildHelpRequestCard(
          title: 'Senior Citizen Needs Grocery Help',
          requester: 'Mrs. Lakshmi (78 yrs)',
          location: 'Madhapur, 3 km',
          helpType: 'Shopping Assistance',
          description: 'Need someone to help with weekly grocery shopping',
          urgency: 'Normal',
        ),
        const SizedBox(height: 12),
        _buildHelpRequestCard(
          title: 'Wheelchair User Needs Transport',
          requester: 'Mr. Suresh (disabled)',
          location: 'Hitech City, 5 km',
          helpType: 'Transportation',
          description: 'Need wheelchair-accessible vehicle for hospital visit',
          urgency: 'Urgent',
        ),
      ],
    );
  }

  Widget _buildReportIssuesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Report New Issue Button
        Card(
          elevation: 4,
          color: Colors.red.shade50,
          child: InkWell(
            onTap: () => _showReportIssueDialog(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_alert,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report a Civic Issue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Garbage, Potholes, Water Supply, etc.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Recent Reports
        _buildSectionHeader('Recent Reports', Icons.assignment, Colors.blue),
        const SizedBox(height: 12),
        _buildIssueReportCard(
          title: 'Garbage Not Collected',
          location: 'Street 12, Madhapur',
          category: 'Waste Management',
          status: 'In Progress',
          reportedBy: 'You',
          reportedDate: '2 days ago',
          upvotes: 24,
        ),
        const SizedBox(height: 12),
        _buildIssueReportCard(
          title: 'Large Pothole on Main Road',
          location: 'Hitech City Main Road',
          category: 'Road Maintenance',
          status: 'Acknowledged',
          reportedBy: 'Anonymous',
          reportedDate: '1 week ago',
          upvotes: 156,
        ),
        const SizedBox(height: 12),
        _buildIssueReportCard(
          title: 'Streetlight Not Working',
          location: 'Near Park, Gachibowli',
          category: 'Electricity',
          status: 'Resolved',
          reportedBy: 'Ramesh K.',
          reportedDate: '3 weeks ago',
          upvotes: 45,
        ),
        const SizedBox(height: 12),
        _buildIssueReportCard(
          title: 'Water Supply Irregular',
          location: 'Banjara Hills Sector 3',
          category: 'Water Supply',
          status: 'Under Review',
          reportedBy: 'Priya S.',
          reportedDate: '5 days ago',
          upvotes: 89,
        ),
      ],
    );
  }

  Widget _buildCivicServicesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Municipality Contacts
        _buildSectionHeader('Municipality Contacts', Icons.phone, Colors.blue),
        const SizedBox(height: 12),
        _buildContactCard(
          department: 'Municipal Corporation',
          contactPerson: 'Helpdesk',
          phone: '040-1234-5678',
          email: 'help@ghmc.gov.in',
          timings: 'Mon-Sat, 10 AM - 6 PM',
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          department: 'Water Board',
          contactPerson: 'Customer Care',
          phone: '040-2345-6789',
          email: 'complaints@hmwssb.gov.in',
          timings: '24/7 Emergency',
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          department: 'Electricity Board',
          contactPerson: 'Faults & Complaints',
          phone: '040-3456-7890',
          email: 'support@tssouthernpower.com',
          timings: '24/7',
        ),
        const SizedBox(height: 24),

        // Government Schemes
        _buildSectionHeader(
            'Local Government Schemes', Icons.card_giftcard, Colors.green),
        const SizedBox(height: 12),
        _buildSchemeCard(
          schemeName: 'Ration Card Subsidy',
          eligibility: 'Below Poverty Line families',
          benefits: 'Free rice and essentials monthly',
          howToApply: 'Visit nearest Mee Seva center with documents',
        ),
        const SizedBox(height: 12),
        _buildSchemeCard(
          schemeName: 'Pension for Elderly',
          eligibility: 'Senior citizens above 60 years',
          benefits: '₹2,000 per month',
          howToApply: 'Online application at govt portal',
        ),
        const SizedBox(height: 12),
        _buildSchemeCard(
          schemeName: 'Free Healthcare Scheme',
          eligibility: 'All residents',
          benefits: 'Free treatment up to ₹5 lakhs',
          howToApply: 'Register at any government hospital',
        ),
      ],
    );
  }

  Widget _buildBillPaymentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Pay Options
        _buildSectionHeader('Quick Pay', Icons.flash_on, Colors.orange),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickPayCard(
                'Electricity',
                Icons.bolt,
                Colors.yellow.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickPayCard(
                'Water',
                Icons.water_drop,
                Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickPayCard(
                'Gas',
                Icons.local_fire_department,
                Colors.orange.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Utility Bills
        _buildSectionHeader('Your Bills', Icons.receipt_long, Colors.purple),
        const SizedBox(height: 12),
        _buildBillCard(
          utilityType: 'Electricity',
          provider: 'TS Southern Power',
          accountNumber: 'ELEC-12345678',
          amount: '₹2,450',
          dueDate: 'Due in 5 days',
          status: 'Pending',
        ),
        const SizedBox(height: 12),
        _buildBillCard(
          utilityType: 'Water',
          provider: 'HMWSSB',
          accountNumber: 'WATER-87654321',
          amount: '₹680',
          dueDate: 'Due in 12 days',
          status: 'Pending',
        ),
        const SizedBox(height: 12),
        _buildBillCard(
          utilityType: 'Gas',
          provider: 'IOCL Gas',
          accountNumber: 'GAS-45678912',
          amount: '₹1,250',
          dueDate: 'Paid on Jan 15',
          status: 'Paid',
        ),
        const SizedBox(height: 24),

        // Recharge Services
        _buildSectionHeader(
            'Recharge & Top-up', Icons.phone_android, Colors.green),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRechargeCard(
                'Mobile',
                Icons.phone_android,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRechargeCard(
                'DTH',
                Icons.tv,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRechargeCard(
                'Broadband',
                Icons.wifi,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBloodDonationCard({
    required String bloodGroup,
    required String patientName,
    required String hospital,
    required String urgency,
    required int unitsNeeded,
    required String contact,
    required String postedDate,
  }) {
    final isUrgent = urgency == 'Critical' || urgency == 'Urgent';
    return Card(
      elevation: isUrgent ? 4 : 2,
      color: isUrgent ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bloodGroup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        hospital,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isUrgent ? Colors.red.shade700 : Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_hospital,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '$unitsNeeded units needed',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  postedDate,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makeCall(contact),
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pledgeDonation(bloodGroup, patientName),
                    icon: const Icon(Icons.favorite, size: 18),
                    label: const Text('Donate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerCard({
    required String title,
    required String organization,
    required String location,
    required String date,
    required int volunteersNeeded,
    required int volunteersJoined,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.groups, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        organization,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$volunteersJoined / $volunteersNeeded volunteers',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: volunteersJoined / volunteersNeeded,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _joinVolunteer(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Join'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRequestCard({
    required String title,
    required String requester,
    required String location,
    required String helpType,
    required String description,
    required String urgency,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgency == 'Urgent'
                        ? Colors.red.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgency,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: urgency == 'Urgent'
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              requester,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  helpType,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _offerHelp(title, requester),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Offer Help'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueReportCard({
    required String title,
    required String location,
    required String category,
    required String status,
    required String reportedBy,
    required String reportedDate,
    required int upvotes,
  }) {
    Color statusColor;
    switch (status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Acknowledged':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'By $reportedBy',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  ' • $reportedDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  onPressed: () => _upvoteIssue(title),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                Text(
                  '$upvotes',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String department,
    required String contactPerson,
    required String phone,
    required String email,
    required String timings,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              department,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              contactPerson,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(phone, style: const TextStyle(fontSize: 14)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => _makeCall(phone),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(timings, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemeCard({
    required String schemeName,
    required String eligibility,
    required String benefits,
    required String howToApply,
  }) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.card_giftcard, color: Colors.green.shade700),
        ),
        title: Text(
          schemeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSchemeDetail('Eligibility', eligibility),
                const SizedBox(height: 8),
                _buildSchemeDetail('Benefits', benefits),
                const SizedBox(height: 8),
                _buildSchemeDetail('How to Apply', howToApply),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _applyForScheme(schemeName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                    ),
                    child: const Text('Apply Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildQuickPayCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _quickPay(title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard({
    required String utilityType,
    required String provider,
    required String accountNumber,
    required String amount,
    required String dueDate,
    required String status,
  }) {
    final isPaid = status == 'Paid';
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        utilityType,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        provider,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isPaid ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPaid
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Account: $accountNumber',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dueDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPaid
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPaid)
                  ElevatedButton(
                    onPressed: () => _payBill(utilityType, amount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pay Now'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _recharge(title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bloodtype, color: Colors.red),
              title: const Text('Request Blood'),
              onTap: () {
                Navigator.pop(context);
                _requestBlood();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                _showReportIssueDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism, color: Colors.blue),
              title: const Text('Offer Help'),
              onTap: () {
                Navigator.pop(context);
                _offerGeneralHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Civic Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select issue type:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Garbage',
                'Potholes',
                'Water Supply',
                'Electricity',
                'Streetlight',
                'Other'
              ].map((type) {
                return FilterChip(
                  label: Text(type),
                  onSelected: (selected) {
                    Navigator.pop(context);
                    _submitIssueReport(type);
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _makeCall(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phone...')),
    );
  }

  void _pledgeDonation(String bloodGroup, String patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pledge Blood Donation'),
        content: Text(
            'Donate $bloodGroup blood for $patient?\n\nYou will be contacted by hospital staff.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Thank you! Hospital will contact you.')),
              );
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _joinVolunteer(String activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Joined: $activity')),
    );
  }

  void _offerHelp(String title, String requester) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Offering help for: $title')),
    );
  }

  void _upvoteIssue(String issue) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Issue upvoted!')),
    );
  }

  void _applyForScheme(String scheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applying for: $scheme')),
    );
  }

  void _quickPay(String utilityType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $utilityType payment...')),
    );
  }

  void _payBill(String utilityType, String amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paying $amount for $utilityType')),
    );
  }

  void _recharge(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type recharge opening...')),
    );
  }

  void _requestBlood() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Blood request form opening...')),
    );
  }

  void _submitIssueReport(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reporting $type issue...')),
    );
  }

  void _offerGeneralHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help offer form opening...')),
    );
  }
}
