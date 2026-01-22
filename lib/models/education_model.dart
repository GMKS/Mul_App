/// Education Models
/// Complete data models for Education Corner features

import 'package:flutter/material.dart';

// Education Levels
enum EducationLevel {
  kg,
  primary,
  middleSchool,
  highSchool,
  undergraduate,
  postgraduate,
  professional;

  String get displayName {
    switch (this) {
      case EducationLevel.kg:
        return 'Kindergarten';
      case EducationLevel.primary:
        return 'Primary (1-5)';
      case EducationLevel.middleSchool:
        return 'Middle School (6-8)';
      case EducationLevel.highSchool:
        return 'High School (9-12)';
      case EducationLevel.undergraduate:
        return 'Undergraduate';
      case EducationLevel.postgraduate:
        return 'Postgraduate';
      case EducationLevel.professional:
        return 'Professional Courses';
    }
  }
}

// Subject Categories
enum SubjectCategory {
  mathematics,
  science,
  english,
  socialStudies,
  languages,
  computer,
  arts,
  commerce,
  engineering,
  medical,
  law,
  management;

  String get displayName {
    switch (this) {
      case SubjectCategory.mathematics:
        return 'Mathematics';
      case SubjectCategory.science:
        return 'Science';
      case SubjectCategory.english:
        return 'English';
      case SubjectCategory.socialStudies:
        return 'Social Studies';
      case SubjectCategory.languages:
        return 'Languages';
      case SubjectCategory.computer:
        return 'Computer Science';
      case SubjectCategory.arts:
        return 'Arts & Humanities';
      case SubjectCategory.commerce:
        return 'Commerce';
      case SubjectCategory.engineering:
        return 'Engineering';
      case SubjectCategory.medical:
        return 'Medical Sciences';
      case SubjectCategory.law:
        return 'Law';
      case SubjectCategory.management:
        return 'Management';
    }
  }

  IconData get icon {
    switch (this) {
      case SubjectCategory.mathematics:
        return Icons.calculate;
      case SubjectCategory.science:
        return Icons.science;
      case SubjectCategory.english:
        return Icons.menu_book;
      case SubjectCategory.socialStudies:
        return Icons.public;
      case SubjectCategory.languages:
        return Icons.language;
      case SubjectCategory.computer:
        return Icons.computer;
      case SubjectCategory.arts:
        return Icons.palette;
      case SubjectCategory.commerce:
        return Icons.account_balance;
      case SubjectCategory.engineering:
        return Icons.engineering;
      case SubjectCategory.medical:
        return Icons.medical_services;
      case SubjectCategory.law:
        return Icons.gavel;
      case SubjectCategory.management:
        return Icons.business_center;
    }
  }
}

// Course/Learning Content
class Course {
  final String id;
  final String title;
  final String description;
  final SubjectCategory subject;
  final EducationLevel level;
  final String instructorName;
  final String? instructorPhoto;
  final String? thumbnailUrl;
  final double rating;
  final int reviewCount;
  final int enrolledStudents;
  final double price;
  final bool isFree;
  final List<String> topics;
  final List<CourseModule> modules;
  final String duration;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.level,
    required this.instructorName,
    this.instructorPhoto,
    this.thumbnailUrl,
    required this.rating,
    required this.reviewCount,
    required this.enrolledStudents,
    required this.price,
    required this.isFree,
    required this.topics,
    required this.modules,
    required this.duration,
    required this.createdAt,
    this.updatedAt,
  });
}

class CourseModule {
  final String id;
  final String title;
  final List<Lesson> lessons;
  final int orderIndex;

  const CourseModule({
    required this.id,
    required this.title,
    required this.lessons,
    required this.orderIndex,
  });
}

class Lesson {
  final String id;
  final String title;
  final String? description;
  final LessonType type;
  final String? videoUrl;
  final String? contentUrl;
  final String duration;
  final bool isCompleted;
  final int orderIndex;

  const Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.videoUrl,
    this.contentUrl,
    required this.duration,
    this.isCompleted = false,
    required this.orderIndex,
  });
}

enum LessonType {
  video,
  reading,
  quiz,
  assignment,
  live;

  IconData get icon {
    switch (this) {
      case LessonType.video:
        return Icons.play_circle;
      case LessonType.reading:
        return Icons.article;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.assignment:
        return Icons.assignment;
      case LessonType.live:
        return Icons.live_tv;
    }
  }
}

// Tutor/Mentor Profile
class Tutor {
  final String id;
  final String name;
  final String? photoUrl;
  final String bio;
  final List<SubjectCategory> specializations;
  final List<EducationLevel> teachingLevels;
  final double rating;
  final int reviewCount;
  final int studentsTeaching;
  final double hourlyRate;
  final String experience;
  final List<String> qualifications;
  final String? phoneNumber;
  final String? email;
  final bool isVerified;
  final bool isAvailableNow;
  final List<String> languages;
  final String city;
  final String state;

  const Tutor({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.bio,
    required this.specializations,
    required this.teachingLevels,
    required this.rating,
    required this.reviewCount,
    required this.studentsTeaching,
    required this.hourlyRate,
    required this.experience,
    required this.qualifications,
    this.phoneNumber,
    this.email,
    required this.isVerified,
    required this.isAvailableNow,
    required this.languages,
    required this.city,
    required this.state,
  });
}

// School/College Profile
class Institution {
  final String id;
  final String name;
  final InstitutionType type;
  final String? logoUrl;
  final String? coverImageUrl;
  final String description;
  final String address;
  final String city;
  final String state;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final List<String> facilities;
  final List<String> affiliations;
  final String? principalName;
  final int? establishedYear;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final List<String> courses;
  final String? admissionProcess;
  final String? feesRange;

  const Institution({
    required this.id,
    required this.name,
    required this.type,
    this.logoUrl,
    this.coverImageUrl,
    required this.description,
    required this.address,
    required this.city,
    required this.state,
    this.pincode,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.website,
    required this.facilities,
    required this.affiliations,
    this.principalName,
    this.establishedYear,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.courses,
    this.admissionProcess,
    this.feesRange,
  });
}

enum InstitutionType {
  preschool,
  primarySchool,
  highSchool,
  college,
  university,
  coachingCenter,
  vocationalInstitute;

  String get displayName {
    switch (this) {
      case InstitutionType.preschool:
        return 'Preschool';
      case InstitutionType.primarySchool:
        return 'Primary School';
      case InstitutionType.highSchool:
        return 'High School';
      case InstitutionType.college:
        return 'College';
      case InstitutionType.university:
        return 'University';
      case InstitutionType.coachingCenter:
        return 'Coaching Center';
      case InstitutionType.vocationalInstitute:
        return 'Vocational Institute';
    }
  }
}

// Doubt/Question
class Doubt {
  final String id;
  final String question;
  final String? imageUrl;
  final SubjectCategory subject;
  final EducationLevel level;
  final String askedBy;
  final String? askedByPhoto;
  final DateTime askedAt;
  final List<Answer> answers;
  final int upvotes;
  final List<String> tags;
  final bool isResolved;

  const Doubt({
    required this.id,
    required this.question,
    this.imageUrl,
    required this.subject,
    required this.level,
    required this.askedBy,
    this.askedByPhoto,
    required this.askedAt,
    required this.answers,
    required this.upvotes,
    required this.tags,
    required this.isResolved,
  });
}

class Answer {
  final String id;
  final String answer;
  final String? imageUrl;
  final String answeredBy;
  final String? answeredByPhoto;
  final bool isTutor;
  final DateTime answeredAt;
  final int upvotes;
  final bool isAccepted;

  const Answer({
    required this.id,
    required this.answer,
    this.imageUrl,
    required this.answeredBy,
    this.answeredByPhoto,
    required this.isTutor,
    required this.answeredAt,
    required this.upvotes,
    required this.isAccepted,
  });
}

// Study Material
class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final MaterialType type;
  final SubjectCategory subject;
  final EducationLevel level;
  final String? fileUrl;
  final String? previewUrl;
  final int? pageCount;
  final String? fileSize;
  final String uploadedBy;
  final DateTime uploadedAt;
  final int downloads;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  const StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.subject,
    required this.level,
    this.fileUrl,
    this.previewUrl,
    this.pageCount,
    this.fileSize,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.downloads,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });
}

enum MaterialType {
  pdf,
  notes,
  questionPaper,
  solution,
  ebook,
  presentation;

  String get displayName {
    switch (this) {
      case MaterialType.pdf:
        return 'PDF Document';
      case MaterialType.notes:
        return 'Study Notes';
      case MaterialType.questionPaper:
        return 'Question Paper';
      case MaterialType.solution:
        return 'Solutions';
      case MaterialType.ebook:
        return 'E-Book';
      case MaterialType.presentation:
        return 'Presentation';
    }
  }

  IconData get icon {
    switch (this) {
      case MaterialType.pdf:
        return Icons.picture_as_pdf;
      case MaterialType.notes:
        return Icons.note;
      case MaterialType.questionPaper:
        return Icons.quiz;
      case MaterialType.solution:
        return Icons.check_circle;
      case MaterialType.ebook:
        return Icons.menu_book;
      case MaterialType.presentation:
        return Icons.slideshow;
    }
  }
}

// Live Class
class LiveClass {
  final String id;
  final String title;
  final String description;
  final SubjectCategory subject;
  final EducationLevel level;
  final String teacherName;
  final String? teacherPhoto;
  final DateTime scheduledAt;
  final String duration;
  final bool isLive;
  final String? meetingUrl;
  final int participantCount;
  final int maxParticipants;
  final bool isFree;
  final double? price;
  final List<String> topics;

  const LiveClass({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.level,
    required this.teacherName,
    this.teacherPhoto,
    required this.scheduledAt,
    required this.duration,
    required this.isLive,
    this.meetingUrl,
    required this.participantCount,
    required this.maxParticipants,
    required this.isFree,
    this.price,
    required this.topics,
  });
}

// Progress Tracking
class StudentProgress {
  final String studentId;
  final Map<SubjectCategory, SubjectProgress> subjectProgress;
  final int totalCoursesEnrolled;
  final int coursesCompleted;
  final int totalLessonsCompleted;
  final int totalQuizzesTaken;
  final double overallAccuracy;
  final int studyStreak;
  final DateTime lastActiveAt;

  const StudentProgress({
    required this.studentId,
    required this.subjectProgress,
    required this.totalCoursesEnrolled,
    required this.coursesCompleted,
    required this.totalLessonsCompleted,
    required this.totalQuizzesTaken,
    required this.overallAccuracy,
    required this.studyStreak,
    required this.lastActiveAt,
  });
}

class SubjectProgress {
  final SubjectCategory subject;
  final int totalLessons;
  final int completedLessons;
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final String timeSpent;

  const SubjectProgress({
    required this.subject,
    required this.totalLessons,
    required this.completedLessons,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    required this.timeSpent,
  });

  double get completionPercentage =>
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;
}

// Quiz/Assessment
class Quiz {
  final String id;
  final String title;
  final SubjectCategory subject;
  final EducationLevel level;
  final String? description;
  final int totalQuestions;
  final int duration; // in minutes
  final List<Question> questions;
  final int? totalMarks;
  final int? passingMarks;

  const Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    this.description,
    required this.totalQuestions,
    required this.duration,
    required this.questions,
    this.totalMarks,
    this.passingMarks,
  });
}

class Question {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final dynamic correctAnswer; // Can be String, int, or List<int>
  final int marks;
  final String? explanation;
  final String? imageUrl;

  const Question({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.marks,
    this.explanation,
    this.imageUrl,
  });
}

enum QuestionType {
  multipleChoice,
  multipleAnswer,
  trueFalse,
  fillInBlank,
  shortAnswer;

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.multipleAnswer:
        return 'Multiple Answer';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fillInBlank:
        return 'Fill in the Blank';
      case QuestionType.shortAnswer:
        return 'Short Answer';
    }
  }
}

// AI Chat Message
class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final ChatMessageType type;

  const ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.type = ChatMessageType.text,
  });
}

enum ChatMessageType {
  text,
  image,
  equation,
  code;

  IconData get icon {
    switch (this) {
      case ChatMessageType.text:
        return Icons.text_fields;
      case ChatMessageType.image:
        return Icons.image;
      case ChatMessageType.equation:
        return Icons.functions;
      case ChatMessageType.code:
        return Icons.code;
    }
  }
}
