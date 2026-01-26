/// Community Help Service Layer
/// Manages help requests, volunteers, resources, and community assistance

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/community_help_model.dart';

class CommunityHelpService {
  static final CommunityHelpService _instance =
      CommunityHelpService._internal();
  factory CommunityHelpService() => _instance;
  CommunityHelpService._internal();

  // Mock data storage
  final List<HelpRequest> _helpRequests = [];
  final List<CommunityVolunteer> _volunteers = [];
  final List<HelpResponse> _responses = [];
  final List<ResourceShare> _resources = [];
  final List<CommunityBulletin> _bulletins = [];
  final List<CommunityGroup> _groups = [];
  final List<EmergencyAlert> _emergencyAlerts = [];

  // Stream controllers
  final _helpRequestsStreamController =
      StreamController<List<HelpRequest>>.broadcast();
  final _volunteersStreamController =
      StreamController<List<CommunityVolunteer>>.broadcast();

  Stream<List<HelpRequest>> get helpRequestsStream =>
      _helpRequestsStreamController.stream;
  Stream<List<CommunityVolunteer>> get volunteersStream =>
      _volunteersStreamController.stream;

  // Initialize mock data
  void initializeMockData() {
    if (_helpRequests.isNotEmpty) return;

    // Mock volunteers
    _volunteers.addAll([
      CommunityVolunteer(
        id: 'v1',
        name: 'Dr. Ramesh Kumar',
        photoUrl: 'https://i.pravatar.cc/150?img=12',
        bio:
            'Medical doctor with 15 years of experience. Available for medical emergencies.',
        skills: [
          HelpCategory.medical,
          HelpCategory.emergency,
          HelpCategory.elderly
        ],
        level: VolunteerLevel.certified,
        rating: 4.9,
        totalHelps: 234,
        points: 1250,
        badges: ['Hero', 'Life Saver', 'Top Helper'],
        location: 'Kukatpally, Hyderabad',
        latitude: 17.4948,
        longitude: 78.3985,
        isAvailable: true,
        isVerified: true,
        languages: ['English', 'Telugu', 'Hindi'],
        phone: '+91 9876543210',
        joinedAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      CommunityVolunteer(
        id: 'v2',
        name: 'Priya Sharma',
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        bio: 'Social worker specializing in childcare and education support.',
        skills: [
          HelpCategory.childcare,
          HelpCategory.education,
          HelpCategory.food
        ],
        level: VolunteerLevel.verified,
        rating: 4.8,
        totalHelps: 156,
        points: 890,
        badges: ['Helper', 'Educator'],
        location: 'Madhapur, Hyderabad',
        latitude: 17.4476,
        longitude: 78.3908,
        isAvailable: true,
        isVerified: true,
        languages: ['English', 'Telugu'],
        phone: '+91 9876543211',
        joinedAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      CommunityVolunteer(
        id: 'v3',
        name: 'Advocate Suresh',
        photoUrl: 'https://i.pravatar.cc/150?img=33',
        bio: 'Lawyer providing free legal consultation for community members.',
        skills: [HelpCategory.legal, HelpCategory.financial],
        level: VolunteerLevel.certified,
        rating: 4.7,
        totalHelps: 89,
        points: 520,
        badges: ['Legal Expert', 'Trusted Advisor'],
        location: 'Ameerpet, Hyderabad',
        latitude: 17.4399,
        longitude: 78.4483,
        isAvailable: false,
        isVerified: true,
        languages: ['English', 'Telugu', 'Hindi'],
        phone: '+91 9876543212',
        joinedAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      CommunityVolunteer(
        id: 'v4',
        name: 'Lakshmi Devi',
        photoUrl: 'https://i.pravatar.cc/150?img=45',
        bio:
            'Retired teacher volunteering for elderly care and food distribution.',
        skills: [
          HelpCategory.elderly,
          HelpCategory.food,
          HelpCategory.education
        ],
        level: VolunteerLevel.hero,
        rating: 5.0,
        totalHelps: 345,
        points: 2100,
        badges: ['Hero', 'Angel', 'Community Champion', 'Top Helper'],
        location: 'Gachibowli, Hyderabad',
        latitude: 17.4399,
        longitude: 78.3489,
        isAvailable: true,
        isVerified: true,
        languages: ['Telugu', 'Hindi'],
        phone: '+91 9876543213',
        joinedAt: DateTime.now().subtract(const Duration(days: 500)),
      ),
    ]);

    // Mock help requests
    _helpRequests.addAll([
      HelpRequest(
        id: 'h1',
        userId: 'u1',
        userName: 'Srinivas Rao',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=8',
        category: HelpCategory.medical,
        title: 'Need urgent blood donation - O+ blood group',
        description:
            'My father needs emergency surgery and requires O+ blood. Any donors available in Kukatpally area?',
        status: HelpRequestStatus.urgent,
        priority: HelpPriority.critical,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        location: 'KIMS Hospital, Kukatpally',
        latitude: 17.4948,
        longitude: 78.3985,
        isEmergency: true,
        tags: ['blood donation', 'O+', 'urgent'],
        responseCount: 3,
        contactPhone: '+91 9876543220',
      ),
      HelpRequest(
        id: 'h2',
        userId: 'u2',
        userName: 'Meera Patel',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=28',
        category: HelpCategory.transport,
        title: 'Need help with moving to new apartment',
        description:
            'Looking for volunteers or affordable movers to help shift belongings from Madhapur to Gachibowli this weekend.',
        status: HelpRequestStatus.open,
        priority: HelpPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        location: 'Madhapur, Hyderabad',
        latitude: 17.4476,
        longitude: 78.3908,
        tags: ['moving', 'transport', 'weekend'],
        responseCount: 1,
      ),
      HelpRequest(
        id: 'h3',
        userId: 'u3',
        userName: 'Anonymous',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=1',
        category: HelpCategory.food,
        title: 'Food assistance needed for family',
        description:
            'Due to recent job loss, need temporary food support for family of 4. Any help appreciated.',
        status: HelpRequestStatus.inProgress,
        priority: HelpPriority.high,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Ameerpet, Hyderabad',
        latitude: 17.4399,
        longitude: 78.4483,
        isAnonymous: true,
        tags: ['food', 'family', 'urgent'],
        responseCount: 2,
        responderId: 'v4',
        responderName: 'Lakshmi Devi',
      ),
      HelpRequest(
        id: 'h4',
        userId: 'u4',
        userName: 'Kiran Kumar',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=51',
        category: HelpCategory.lostAndFound,
        title: 'Lost golden retriever dog near Banjara Hills',
        description:
            'Our pet dog went missing near Banjara Hills Road No. 3. Brown collar with name tag "Bruno". Please contact if found.',
        status: HelpRequestStatus.open,
        priority: HelpPriority.high,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        location: 'Banjara Hills, Hyderabad',
        latitude: 17.4126,
        longitude: 78.4480,
        tags: ['lost pet', 'dog', 'golden retriever'],
        responseCount: 5,
        contactPhone: '+91 9876543221',
      ),
      HelpRequest(
        id: 'h5',
        userId: 'u5',
        userName: 'Rajesh Reddy',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=14',
        category: HelpCategory.education,
        title: 'Free tutoring needed for 10th class student',
        description:
            'Looking for volunteer teacher to help my daughter with Math and Science preparation for board exams.',
        status: HelpRequestStatus.resolved,
        priority: HelpPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Miyapur, Hyderabad',
        latitude: 17.4968,
        longitude: 78.3575,
        tags: ['education', 'tutoring', '10th class'],
        responseCount: 1,
        responderId: 'v2',
        responderName: 'Priya Sharma',
      ),
    ]);

    // Mock resources
    _resources.addAll([
      ResourceShare(
        id: 'r1',
        userId: 'u6',
        userName: 'Anand Rao',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=68',
        type: ResourceType.books,
        title: 'Engineering textbooks for donation',
        description:
            '15 engineering books (CSE & ECE) in good condition. Free for students who need them.',
        quantity: 15,
        location: 'JNTU, Hyderabad',
        latitude: 17.4932,
        longitude: 78.3914,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isAvailable: true,
      ),
      ResourceShare(
        id: 'r2',
        userId: 'u7',
        userName: 'Savita Sharma',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=38',
        type: ResourceType.clothes,
        title: 'Children\'s clothes (age 5-10)',
        description:
            'Gently used children\'s clothes, washed and ready to donate. Includes shirts, pants, and dresses.',
        quantity: 20,
        location: 'Kondapur, Hyderabad',
        latitude: 17.4691,
        longitude: 78.3654,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        isAvailable: true,
      ),
    ]);

    // Mock bulletins
    _bulletins.addAll([
      CommunityBulletin(
        id: 'b1',
        userId: 'u8',
        userName: 'Community Admin',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=60',
        title: 'Blood Donation Camp - This Sunday',
        description:
            'Red Cross is organizing a blood donation camp at Community Hall, Kukatpally on Sunday 10 AM to 4 PM. All donors welcome!',
        category: 'Event',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 3)),
        isPinned: true,
        viewCount: 234,
      ),
      CommunityBulletin(
        id: 'b2',
        userId: 'u9',
        userName: 'NGO Helping Hands',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=25',
        title: 'Free Skill Development Workshop',
        description:
            'Learn basic computer skills, resume writing, and interview techniques. Free workshop for unemployed youth on Saturday.',
        category: 'Training',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        expiresAt: DateTime.now().add(const Duration(days: 5)),
        isPinned: false,
        viewCount: 89,
      ),
    ]);

    // Mock groups
    _groups.addAll([
      CommunityGroup(
        id: 'g1',
        name: 'Kukatpally Residents',
        description:
            'Community group for all Kukatpally residents to discuss local issues and help each other.',
        adminId: 'u10',
        adminName: 'Ramesh Kumar',
        memberCount: 234,
        location: 'Kukatpally, Hyderabad',
        tags: ['residents', 'local', 'community'],
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        isPublic: true,
      ),
      CommunityGroup(
        id: 'g2',
        name: 'Women Safety Network',
        description:
            'Support group focused on women\'s safety, rights, and empowerment in the city.',
        adminId: 'u11',
        adminName: 'Priya Sharma',
        memberCount: 567,
        location: 'Hyderabad',
        tags: ['women', 'safety', 'support'],
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        isPublic: true,
      ),
    ]);

    _helpRequestsStreamController.add(_helpRequests);
    _volunteersStreamController.add(_volunteers);
  }

  // Fetch help requests
  Future<List<HelpRequest>> fetchHelpRequests({
    HelpCategory? category,
    HelpRequestStatus? status,
    HelpPriority? priority,
    double? maxDistance,
    String? sortBy, // 'recent', 'urgent', 'nearby'
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = List<HelpRequest>.from(_helpRequests);

    if (category != null) {
      filtered = filtered.where((r) => r.category == category).toList();
    }

    if (status != null) {
      filtered = filtered.where((r) => r.status == status).toList();
    }

    if (priority != null) {
      filtered = filtered.where((r) => r.priority == priority).toList();
    }

    // Sort
    if (sortBy == 'recent') {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortBy == 'urgent') {
      filtered.sort((a, b) {
        if (a.isEmergency && !b.isEmergency) return -1;
        if (!a.isEmergency && b.isEmergency) return 1;
        return b.priority.index.compareTo(a.priority.index);
      });
    }

    return filtered;
  }

  // Create help request
  Future<HelpRequest> createHelpRequest({
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required HelpCategory category,
    required String title,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    bool isAnonymous = false,
    bool isEmergency = false,
    HelpPriority priority = HelpPriority.medium,
    List<String> tags = const [],
    String? contactPhone,
    String? contactEmail,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final request = HelpRequest(
      id: 'h${_helpRequests.length + 1}',
      userId: userId,
      userName: isAnonymous ? 'Anonymous' : userName,
      userPhotoUrl:
          isAnonymous ? 'https://i.pravatar.cc/150?img=1' : userPhotoUrl,
      category: category,
      title: title,
      description: description,
      status: isEmergency ? HelpRequestStatus.urgent : HelpRequestStatus.open,
      priority: priority,
      createdAt: DateTime.now(),
      location: location,
      latitude: latitude,
      longitude: longitude,
      isAnonymous: isAnonymous,
      isEmergency: isEmergency,
      tags: tags,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
    );

    _helpRequests.add(request);
    _helpRequestsStreamController.add(_helpRequests);

    // If emergency, create alert
    if (isEmergency) {
      _createEmergencyAlert(request);
    }

    return request;
  }

  // Create emergency alert
  void _createEmergencyAlert(HelpRequest request) {
    final alert = EmergencyAlert(
      id: 'alert${_emergencyAlerts.length + 1}',
      userId: request.userId,
      userName: request.userName,
      userPhotoUrl: request.userPhotoUrl,
      type: HelpCategoryHelper.getName(request.category),
      description: request.title,
      latitude: request.latitude,
      longitude: request.longitude,
      createdAt: DateTime.now(),
      notifiedVolunteers: _volunteers.where((v) => v.isAvailable).length,
    );

    _emergencyAlerts.add(alert);
  }

  // Update request status
  Future<void> updateRequestStatus(
      String requestId, HelpRequestStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _helpRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final oldRequest = _helpRequests[index];
      _helpRequests[index] = HelpRequest(
        id: oldRequest.id,
        userId: oldRequest.userId,
        userName: oldRequest.userName,
        userPhotoUrl: oldRequest.userPhotoUrl,
        category: oldRequest.category,
        title: oldRequest.title,
        description: oldRequest.description,
        status: status,
        priority: oldRequest.priority,
        createdAt: oldRequest.createdAt,
        resolvedAt:
            status == HelpRequestStatus.resolved ? DateTime.now() : null,
        location: oldRequest.location,
        latitude: oldRequest.latitude,
        longitude: oldRequest.longitude,
        isAnonymous: oldRequest.isAnonymous,
        isEmergency: oldRequest.isEmergency,
        mediaUrls: oldRequest.mediaUrls,
        tags: oldRequest.tags,
        responseCount: oldRequest.responseCount,
        responderId: oldRequest.responderId,
        responderName: oldRequest.responderName,
        contactPhone: oldRequest.contactPhone,
        contactEmail: oldRequest.contactEmail,
      );
      _helpRequestsStreamController.add(_helpRequests);
    }
  }

  // Fetch volunteers
  Future<List<CommunityVolunteer>> fetchVolunteers({
    HelpCategory? skill,
    bool? isAvailable,
    double? maxDistance,
    String? sortBy, // 'rating', 'helps', 'nearby'
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = List<CommunityVolunteer>.from(_volunteers);

    if (skill != null) {
      filtered = filtered.where((v) => v.skills.contains(skill)).toList();
    }

    if (isAvailable != null && isAvailable) {
      filtered = filtered.where((v) => v.isAvailable).toList();
    }

    // Sort
    if (sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy == 'helps') {
      filtered.sort((a, b) => b.totalHelps.compareTo(a.totalHelps));
    }

    return filtered;
  }

  // Respond to help request
  Future<HelpResponse> respondToRequest({
    required String requestId,
    required String volunteerId,
    required String volunteerName,
    required String volunteerPhotoUrl,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final response = HelpResponse(
      id: 'resp${_responses.length + 1}',
      requestId: requestId,
      volunteerId: volunteerId,
      volunteerName: volunteerName,
      volunteerPhotoUrl: volunteerPhotoUrl,
      message: message,
      createdAt: DateTime.now(),
    );

    _responses.add(response);

    // Update response count
    final requestIndex = _helpRequests.indexWhere((r) => r.id == requestId);
    if (requestIndex != -1) {
      final oldRequest = _helpRequests[requestIndex];
      _helpRequests[requestIndex] = HelpRequest(
        id: oldRequest.id,
        userId: oldRequest.userId,
        userName: oldRequest.userName,
        userPhotoUrl: oldRequest.userPhotoUrl,
        category: oldRequest.category,
        title: oldRequest.title,
        description: oldRequest.description,
        status: oldRequest.status,
        priority: oldRequest.priority,
        createdAt: oldRequest.createdAt,
        resolvedAt: oldRequest.resolvedAt,
        location: oldRequest.location,
        latitude: oldRequest.latitude,
        longitude: oldRequest.longitude,
        isAnonymous: oldRequest.isAnonymous,
        isEmergency: oldRequest.isEmergency,
        mediaUrls: oldRequest.mediaUrls,
        tags: oldRequest.tags,
        responseCount: oldRequest.responseCount + 1,
        responderId: oldRequest.responderId,
        responderName: oldRequest.responderName,
        contactPhone: oldRequest.contactPhone,
        contactEmail: oldRequest.contactEmail,
      );
      _helpRequestsStreamController.add(_helpRequests);
    }

    return response;
  }

  // Fetch resources
  Future<List<ResourceShare>> fetchResources({ResourceType? type}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (type != null) {
      return _resources.where((r) => r.type == type && r.isAvailable).toList();
    }
    return _resources.where((r) => r.isAvailable).toList();
  }

  // Share resource
  Future<ResourceShare> shareResource({
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required ResourceType type,
    required String title,
    required String description,
    required int quantity,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final resource = ResourceShare(
      id: 'r${_resources.length + 1}',
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: type,
      title: title,
      description: description,
      quantity: quantity,
      location: location,
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now(),
    );

    _resources.add(resource);
    return resource;
  }

  // Fetch bulletins
  Future<List<CommunityBulletin>> fetchBulletins() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bulletins.where((b) => !b.isExpired).toList()
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  // Fetch groups
  Future<List<CommunityGroup>> fetchGroups() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _groups;
  }

  // Fetch responses for request
  Future<List<HelpResponse>> fetchResponses(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _responses.where((r) => r.requestId == requestId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void dispose() {
    _helpRequestsStreamController.close();
    _volunteersStreamController.close();
  }
}
