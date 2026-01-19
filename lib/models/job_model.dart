// Job Model with all modern features
// Includes filtering, expiry logic, and analytics

class JobModel {
  final String id;
  final String title;
  final String description;
  final String requirements;
  
  // Company Info
  final String companyName;
  final String? companyLogo;
  final String? companyId;
  
  // Location
  final String city;
  final String state;
  final String? exactLocation;
  final bool isRemote;
  final bool isHybrid;
  
  // Job Details
  final JobCategory category;
  final EmploymentType employmentType;
  final ExperienceLevel experienceLevel;
  final SalaryRange? salaryRange;
  final int numberOfOpenings;
  final List<String> skills;
  final List<String> benefits;
  
  // Dates
  final DateTime postedDate;
  final DateTime expiryDate;
  final DateTime? lastUpdated;
  
  // Contact & Application
  final String contactEmail;
  final String? contactPhone;
  final String? applyUrl;
  final bool easyApply; // One-click apply
  
  // Status & Analytics
  final JobStatus status;
  final bool isFeatured;
  final int viewsCount;
  final int applicationsCount;
  final int savedCount;
  
  // Monetization
  final bool isPremiumListing;
  final int priorityScore;
  
  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.companyName,
    this.companyLogo,
    this.companyId,
    required this.city,
    required this.state,
    this.exactLocation,
    this.isRemote = false,
    this.isHybrid = false,
    required this.category,
    required this.employmentType,
    required this.experienceLevel,
    this.salaryRange,
    this.numberOfOpenings = 1,
    required this.skills,
    this.benefits = const [],
    required this.postedDate,
    required this.expiryDate,
    this.lastUpdated,
    required this.contactEmail,
    this.contactPhone,
    this.applyUrl,
    this.easyApply = false,
    this.status = JobStatus.active,
    this.isFeatured = false,
    this.viewsCount = 0,
    this.applicationsCount = 0,
    this.savedCount = 0,
    this.isPremiumListing = false,
    this.priorityScore = 0,
  });

  // Check if job is expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  
  // Check if expiring soon (within 3 days)
  bool get isExpiringSoon {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }
  
  // Get days remaining
  int get daysRemaining {
    final days = expiryDate.difference(DateTime.now()).inDays;
    return days >= 0 ? days : 0;
  }
  
  // Get time ago text
  String get postedTimeAgo {
    final difference = DateTime.now().difference(postedDate);
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} months ago';
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hours ago';
    return 'Just now';
  }
  
  // Get location text
  String get locationText {
    if (isRemote) return 'Remote';
    if (isHybrid) return '$city (Hybrid)';
    return '$city, $state';
  }
  
  // Calculate priority score for sorting
  int calculatePriorityScore() {
    int score = 0;
    
    // Premium listing (50 points)
    if (isPremiumListing) score += 50;
    
    // Featured (30 points)
    if (isFeatured) score += 30;
    
    // Recency (0-10 points)
    final daysSincePosted = DateTime.now().difference(postedDate).inDays;
    score += (10 - daysSincePosted.clamp(0, 10));
    
    // Engagement (0-10 points)
    score += (viewsCount / 100).clamp(0, 10).toInt();
    
    return score;
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      requirements: json['requirements'] as String,
      companyName: json['companyName'] as String,
      companyLogo: json['companyLogo'] as String?,
      companyId: json['companyId'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      exactLocation: json['exactLocation'] as String?,
      isRemote: json['isRemote'] as bool? ?? false,
      isHybrid: json['isHybrid'] as bool? ?? false,
      category: JobCategory.values.firstWhere(
        (e) => e.toString() == 'JobCategory.${json['category']}',
        orElse: () => JobCategory.other,
      ),
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.toString() == 'EmploymentType.${json['employmentType']}',
        orElse: () => EmploymentType.fullTime,
      ),
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.toString() == 'ExperienceLevel.${json['experienceLevel']}',
        orElse: () => ExperienceLevel.midLevel,
      ),
      salaryRange: json['salaryRange'] != null
          ? SalaryRange.fromJson(json['salaryRange'] as Map<String, dynamic>)
          : null,
      numberOfOpenings: json['numberOfOpenings'] as int? ?? 1,
      skills: List<String>.from(json['skills'] as List),
      benefits: json['benefits'] != null
          ? List<String>.from(json['benefits'] as List)
          : [],
      postedDate: DateTime.parse(json['postedDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      contactEmail: json['contactEmail'] as String,
      contactPhone: json['contactPhone'] as String?,
      applyUrl: json['applyUrl'] as String?,
      easyApply: json['easyApply'] as bool? ?? false,
      status: JobStatus.values.firstWhere(
        (e) => e.toString() == 'JobStatus.${json['status']}',
        orElse: () => JobStatus.active,
      ),
      isFeatured: json['isFeatured'] as bool? ?? false,
      viewsCount: json['viewsCount'] as int? ?? 0,
      applicationsCount: json['applicationsCount'] as int? ?? 0,
      savedCount: json['savedCount'] as int? ?? 0,
      isPremiumListing: json['isPremiumListing'] as bool? ?? false,
      priorityScore: json['priorityScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'requirements': requirements,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'companyId': companyId,
      'city': city,
      'state': state,
      'exactLocation': exactLocation,
      'isRemote': isRemote,
      'isHybrid': isHybrid,
      'category': category.toString().split('.').last,
      'employmentType': employmentType.toString().split('.').last,
      'experienceLevel': experienceLevel.toString().split('.').last,
      'salaryRange': salaryRange?.toJson(),
      'numberOfOpenings': numberOfOpenings,
      'skills': skills,
      'benefits': benefits,
      'postedDate': postedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'applyUrl': applyUrl,
      'easyApply': easyApply,
      'status': status.toString().split('.').last,
      'isFeatured': isFeatured,
      'viewsCount': viewsCount,
      'applicationsCount': applicationsCount,
      'savedCount': savedCount,
      'isPremiumListing': isPremiumListing,
      'priorityScore': priorityScore,
    };
  }

  JobModel copyWith({
    bool? isFeatured,
    int? viewsCount,
    int? applicationsCount,
    int? savedCount,
    JobStatus? status,
  }) {
    return JobModel(
      id: id,
      title: title,
      description: description,
      requirements: requirements,
      companyName: companyName,
      companyLogo: companyLogo,
      companyId: companyId,
      city: city,
      state: state,
      exactLocation: exactLocation,
      isRemote: isRemote,
      isHybrid: isHybrid,
      category: category,
      employmentType: employmentType,
      experienceLevel: experienceLevel,
      salaryRange: salaryRange,
      numberOfOpenings: numberOfOpenings,
      skills: skills,
      benefits: benefits,
      postedDate: postedDate,
      expiryDate: expiryDate,
      lastUpdated: lastUpdated,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      applyUrl: applyUrl,
      easyApply: easyApply,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      viewsCount: viewsCount ?? this.viewsCount,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      savedCount: savedCount ?? this.savedCount,
      isPremiumListing: isPremiumListing,
      priorityScore: priorityScore,
    );
  }
}

// Job Category Enum
enum JobCategory {
  it,
  retail,
  healthcare,
  education,
  hospitality,
  finance,
  manufacturing,
  construction,
  logistics,
  marketing,
  sales,
  customerService,
  other,
}

extension JobCategoryExtension on JobCategory {
  String get displayName {
    switch (this) {
      case JobCategory.it:
        return 'IT & Software';
      case JobCategory.retail:
        return 'Retail';
      case JobCategory.healthcare:
        return 'Healthcare';
      case JobCategory.education:
        return 'Education';
      case JobCategory.hospitality:
        return 'Hospitality';
      case JobCategory.finance:
        return 'Finance';
      case JobCategory.manufacturing:
        return 'Manufacturing';
      case JobCategory.construction:
        return 'Construction';
      case JobCategory.logistics:
        return 'Logistics';
      case JobCategory.marketing:
        return 'Marketing';
      case JobCategory.sales:
        return 'Sales';
      case JobCategory.customerService:
        return 'Customer Service';
      case JobCategory.other:
        return 'Other';
    }
  }
}

// Employment Type Enum
enum EmploymentType {
  fullTime,
  partTime,
  contract,
  internship,
  freelance,
}

extension EmploymentTypeExtension on EmploymentType {
  String get displayName {
    switch (this) {
      case EmploymentType.fullTime:
        return 'Full-Time';
      case EmploymentType.partTime:
        return 'Part-Time';
      case EmploymentType.contract:
        return 'Contract';
      case EmploymentType.internship:
        return 'Internship';
      case EmploymentType.freelance:
        return 'Freelance';
    }
  }
}

// Experience Level Enum
enum ExperienceLevel {
  fresher,
  entryLevel,
  midLevel,
  seniorLevel,
  executive,
}

extension ExperienceLevelExtension on ExperienceLevel {
  String get displayName {
    switch (this) {
      case ExperienceLevel.fresher:
        return 'Fresher';
      case ExperienceLevel.entryLevel:
        return '1-2 years';
      case ExperienceLevel.midLevel:
        return '3-5 years';
      case ExperienceLevel.seniorLevel:
        return '5+ years';
      case ExperienceLevel.executive:
        return 'Executive';
    }
  }
}

// Job Status Enum
enum JobStatus {
  active,
  expired,
  closed,
  draft,
}

// Salary Range Model
class SalaryRange {
  final double min;
  final double max;
  final String currency;
  final SalaryPeriod period;

  SalaryRange({
    required this.min,
    required this.max,
    this.currency = 'INR',
    this.period = SalaryPeriod.monthly,
  });

  String get displayText {
    if (min == max) {
      return '₹${_formatSalary(min)}/${period.displayName}';
    }
    return '₹${_formatSalary(min)} - ₹${_formatSalary(max)}/${period.displayName}';
  }

  String _formatSalary(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  factory SalaryRange.fromJson(Map<String, dynamic> json) {
    return SalaryRange(
      min: json['min'] as double,
      max: json['max'] as double,
      currency: json['currency'] as String? ?? 'INR',
      period: SalaryPeriod.values.firstWhere(
        (e) => e.toString() == 'SalaryPeriod.${json['period']}',
        orElse: () => SalaryPeriod.monthly,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'currency': currency,
      'period': period.toString().split('.').last,
    };
  }
}

enum SalaryPeriod {
  monthly,
  annual,
}

extension SalaryPeriodExtension on SalaryPeriod {
  String get displayName {
    switch (this) {
      case SalaryPeriod.monthly:
        return 'month';
      case SalaryPeriod.annual:
        return 'year';
    }
  }
}

// Job Application Model
class JobApplication {
  final String id;
  final String jobId;
  final String applicantName;
  final String applicantEmail;
  final String? applicantPhone;
  final String? resumeUrl;
  final String? coverLetter;
  final DateTime appliedDate;
  final ApplicationStatus status;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.applicantName,
    required this.applicantEmail,
    this.applicantPhone,
    this.resumeUrl,
    this.coverLetter,
    required this.appliedDate,
    this.status = ApplicationStatus.pending,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      applicantName: json['applicantName'] as String,
      applicantEmail: json['applicantEmail'] as String,
      applicantPhone: json['applicantPhone'] as String?,
      resumeUrl: json['resumeUrl'] as String?,
      coverLetter: json['coverLetter'] as String?,
      appliedDate: DateTime.parse(json['appliedDate'] as String),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == 'ApplicationStatus.${json['status']}',
        orElse: () => ApplicationStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhone': applicantPhone,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'appliedDate': appliedDate.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }
}

enum ApplicationStatus {
  pending,
  reviewed,
  shortlisted,
  rejected,
  accepted,
}
