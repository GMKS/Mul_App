# 🛡️ Content Moderation System - Implementation Guide

## ✅ Implemented Features

### 1. Core Models

- **ContentReport Model** (`lib/models/report_model.dart`)
  - Report categories: Spam, Inappropriate, Misinformation, Copyright, Harassment, Violence, Hate Speech, Other
  - Report statuses: Pending, Under Review, Resolved, Dismissed
  - Content types: Devotional Video, Business Video, Regional Video, Business Post, Event, Comment, User
  - Privacy-first: Reporter identity confidential
  - Complete tracking: Reporter, content owner, admin actions, feedback

- **UserWarning Model** (`lib/models/warning_model.dart`)
  - Warning types: Spam, Inappropriate Content, Misinformation, Harassment, Other
  - Severity levels: Low (first warning), Medium (second), High (final), Ban
  - Educational approach: Escalating consequences
  - Temporary restrictions support
  - Appeal functionality ready

### 2. Moderation Service

- **ModerationService** (`lib/services/moderation_service.dart`)
  - Submit content reports with duplicate prevention
  - Get user's reports with status tracking
  - Admin report management with filtering
  - Update report status with feedback to reporters
  - Issue warnings to users with educational messages
  - Soft delete/restore content functionality
  - Community Guidelines included
  - Mock data for development

### 3. UI Components

- **ReportButton Widget** (`lib/widgets/report_button_widget.dart`)
  - One-tap reporting
  - Clear category selection with icons
  - Optional comment box
  - Content preview in dialog
  - Privacy notice included
  - Success/error feedback
  - Confirmation message
  - Reusable across all content types

---

## 📍 Where to Add Report Buttons

### Devotional Content

**File:** `lib/screens/devotional/devotional_feed_screen.dart`

**Location:** In `DevotionalVideoCard` widget (around line 1800+)

**Add to action buttons:**

```dart
// Add after share button
_buildActionButton(
  icon: Icons.flag_outlined,
  label: 'Report',
  onTap: () => _showReportDialog(),
  color: Colors.white,
),
```

**Add report dialog method:**

```dart
void _showReportDialog() {
  showDialog(
    context: context,
    builder: (context) => ReportDialog(
      contentId: widget.video.id,
      contentType: ReportedContentType.devotionalVideo,
      contentTitle: widget.video.title,
      contentOwnerId: widget.video.userId ?? 'unknown',
      contentOwnerName: widget.video.creatorName ?? 'Unknown',
      contentDescription: widget.video.description,
      contentThumbnail: widget.video.thumbnailUrl,
    ),
  );
}
```

### Business Feed Content

**File:** `lib/screens/business_feed_screen.dart`

**Locations:**

1. **Video Cards** - Add report button to video player overlay
2. **Offer Cards** - Add to offer detail modal
3. **Business Cards** - Add to business profile header

**Example for Video Card:**

```dart
// In _buildVideoCard method
Row(
  children: [
    IconButton(
      icon: const Icon(Icons.favorite_border),
      onPressed: () {},
    ),
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: () {},
    ),
    ReportButton(
      contentId: video.id,
      contentType: ReportedContentType.businessVideo,
      contentTitle: video.title,
      contentOwnerId: video.ownerId,
      contentOwnerName: business.name,
      contentThumbnail: video.thumbnailUrl,
      iconColor: Colors.white,
    ),
  ],
)
```

### Regional Feed Content

**File:** `lib/features/regional/widgets/regional_video_card.dart`

**Location:** In action buttons section (right side of video)

**Add to actions:**

```dart
// Add after share button
_ActionButton(
  icon: Icons.flag_outlined,
  label: 'Report',
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentId: video.id,
        contentType: ReportedContentType.regionalVideo,
        contentTitle: video.title,
        contentOwnerId: video.creatorId,
        contentOwnerName: video.creatorName,
        contentDescription: video.description,
        contentThumbnail: video.thumbnailUrl,
      ),
    );
  },
),
```

### Events

**File:** `lib/screens/events/event_detail_screen.dart`

**Location:** In AppBar actions or event details section

**Add report button:**

```dart
IconButton(
  icon: const Icon(Icons.flag_outlined),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentId: event.id,
        contentType: ReportedContentType.event,
        contentTitle: event.title,
        contentOwnerId: event.organizerId,
        contentOwnerName: event.organizerName,
        contentDescription: event.description,
        contentThumbnail: event.imageUrl,
      ),
    );
  },
)
```

---

## 🎯 Admin Moderation Enhancements

### Update Admin Moderation Screen

**File:** `lib/screens/admin/admin_moderation_screen.dart`

**Enhancements Needed:**

1. Integrate with real ContentReport data
2. Add "Send Feedback to Reporter" feature
3. Add "Issue Warning" functionality
4. Add "Soft Delete" and "Restore" actions
5. Show reporter information (confidential to admins only)
6. Add bulk actions for multiple reports

**Example Integration:**

```dart
// Replace mock data with real service calls
Future<void> _loadReports() async {
  final reports = await ModerationService.getAllReports(
    status: _selectedStatus,
    category: _selectedCategory,
  );
  setState(() {
    _reports = reports;
  });
}

// Add action handlers
Future<void> _resolveReport(ContentReport report) async {
  final success = await ModerationService.updateReportStatus(
    reportId: report.id,
    status: ReportStatus.resolved,
    adminId: _currentUser!.id,
    adminName: _currentUser!.name,
    adminAction: 'Content removed',
    feedbackToReporter: 'Thank you for reporting. We have removed this content.',
  );

  if (success) {
    await ModerationService.softDeleteContent(
      contentId: report.contentId,
      contentType: report.contentType,
      reason: 'Violates community guidelines',
    );
    _loadReports();
  }
}
```

---

## 📋 My Reports Screen for Users

### Create User Reports Screen

**File:** `lib/screens/my_reports_screen.dart` (needs to be created)

**Features:**

- List of user's submitted reports
- Status badges (Pending, Under Review, Resolved)
- View feedback from moderators
- Filter by status
- Empty state for no reports

**Example Structure:**

```dart
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<ContentReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final reports = await ModerationService.getUserReports(userId);
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? _buildEmptyState()
              : _buildReportsList(),
    );
  }

  Widget _buildReportsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(ContentReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: report.statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report.statusDisplayName,
                style: TextStyle(
                  color: report.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Content title
            Text(
              report.contentTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Report category
            Row(
              children: [
                Text(report.category.icon),
                const SizedBox(width: 8),
                Text(
                  report.categoryDisplayName,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            Text(
              'Reported ${_formatDate(report.createdAt)}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),

            // Feedback from moderators
            if (report.feedbackToReporter != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.admin_panel_settings, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Moderator Feedback',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.feedbackToReporter!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No reports submitted',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Help keep the community safe by reporting inappropriate content',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
```

### Add to Settings Screen

**File:** `lib/screens/settings_screen.dart`

**Add after Admin Panel section:**

```dart
// My Reports Section
_buildSection(
  title: 'My Reports',
  icon: Icons.flag,
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyReportsScreen(),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        children: [
          Icon(Icons.flag_outlined, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Reports',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Track your content reports',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        ],
      ),
    ),
  ),
),
```

---

## 🎓 Community Guidelines Screen

### Create Guidelines Screen

**File:** `lib/screens/community_guidelines_screen.dart` (needs to be created)

**Simple implementation:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/moderation_service.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
        backgroundColor: const Color(0xFF16213e),
      ),
      backgroundColor: const Color(0xFF1a1a2e),
      body: Markdown(
        data: ModerationService.communityGuidelines,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: Colors.white, fontSize: 14),
          h1: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          listBullet: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
```

### Link from Report Dialog

Add "View Guidelines" button in ReportDialog:

```dart
TextButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommunityGuidelinesScreen(),
      ),
    );
  },
  icon: const Icon(Icons.info_outline),
  label: const Text('View Community Guidelines'),
)
```

---

## 📊 Implementation Checklist

### ✅ Completed

- [x] ContentReport model with all fields
- [x] UserWarning model with severity levels
- [x] ModerationService with full functionality
- [x] ReportButton reusable widget
- [x] Report dialog with categories
- [x] Privacy-first design
- [x] Community Guidelines text
- [x] Mock data for development

### 📝 To Do

- [ ] Add ReportButton to Devotional feed videos
- [ ] Add ReportButton to Business feed videos/offers
- [ ] Add ReportButton to Regional feed videos
- [ ] Add ReportButton to Events
- [ ] Create MyReportsScreen
- [ ] Add MyReports link to Settings
- [ ] Create CommunityGuidelinesScreen
- [ ] Enhance AdminModerationScreen with new features
- [ ] Add Warning issuance UI for admins
- [ ] Create Appeal functionality
- [ ] Add moderation notifications
- [ ] Connect to Supabase tables
- [ ] Add unit tests

---

## 🗄️ Database Tables Needed

### content_reports

```sql
CREATE TABLE content_reports (
  id TEXT PRIMARY KEY,
  reporter_id TEXT NOT NULL,
  reporter_name TEXT NOT NULL,
  content_id TEXT NOT NULL,
  content_type TEXT NOT NULL,
  content_owner_id TEXT NOT NULL,
  content_owner_name TEXT NOT NULL,
  category TEXT NOT NULL,
  additional_comment TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL,
  reviewed_at TIMESTAMP,
  resolved_at TIMESTAMP,
  admin_id TEXT,
  admin_name TEXT,
  admin_action TEXT,
  admin_notes TEXT,
  feedback_to_reporter TEXT,
  is_anonymous BOOLEAN DEFAULT TRUE,
  content_title TEXT NOT NULL,
  content_description TEXT,
  content_thumbnail TEXT
);
```

### user_warnings

```sql
CREATE TABLE user_warnings (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_name TEXT NOT NULL,
  type TEXT NOT NULL,
  severity TEXT NOT NULL,
  reason TEXT NOT NULL,
  related_content_id TEXT,
  related_report_id TEXT,
  created_at TIMESTAMP NOT NULL,
  issued_by TEXT NOT NULL,
  issued_by_name TEXT NOT NULL,
  expires_at TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  user_response TEXT
);
```

---

## 🎉 Key Benefits

### For Users

✅ One-tap reporting - Simple and fast  
✅ Clear categories - Easy to understand  
✅ Status tracking - Know what's happening  
✅ Privacy protected - Identity confidential  
✅ Feedback received - Closure on reports

### For Admins

✅ Centralized dashboard - All reports in one place  
✅ Bulk actions - Efficient moderation  
✅ Educational warnings - Help users improve  
✅ Soft delete - Review before permanent action  
✅ Complete audit trail - Full transparency

### For Community

✅ Safe environment - Bad content removed quickly  
✅ No false positives - Human review required  
✅ Fair process - Warnings before bans  
✅ Education first - Help users learn  
✅ Respect maintained - No public shaming

---

**Next Steps:** Integrate report buttons into content screens and create My Reports screen for users!
