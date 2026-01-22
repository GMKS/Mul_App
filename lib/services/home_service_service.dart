/// Home Services Service Layer
/// Manages home service bookings, providers, and related operations

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/home_service_model.dart';

class HomeServiceService {
  static final HomeServiceService _instance = HomeServiceService._internal();
  factory HomeServiceService() => _instance;
  HomeServiceService._internal();

  // Mock data storage
  final List<ServiceProvider> _providers = [];
  final List<ServiceBooking> _bookings = [];
  final List<ServiceReview> _reviews = [];
  final List<ServicePackage> _packages = [];
  final List<ServiceOffer> _offers = [];

  // Stream controllers
  final _providersStreamController =
      StreamController<List<ServiceProvider>>.broadcast();
  final _bookingsStreamController =
      StreamController<List<ServiceBooking>>.broadcast();

  Stream<List<ServiceProvider>> get providersStream =>
      _providersStreamController.stream;
  Stream<List<ServiceBooking>> get bookingsStream =>
      _bookingsStreamController.stream;

  // Initialize mock data
  void initializeMockData() {
    if (_providers.isNotEmpty) return;

    // Mock service providers
    _providers.addAll([
      ServiceProvider(
        id: 'p1',
        name: 'Rajesh Kumar',
        photoUrl: 'https://i.pravatar.cc/150?img=12',
        category: ServiceCategory.plumbing,
        specializations: [ServiceCategory.plumbing, ServiceCategory.waterTank],
        rating: 4.8,
        totalReviews: 234,
        completedJobs: 456,
        verificationLevel: VerificationLevel.certified,
        isBackgroundChecked: true,
        isCertified: true,
        languages: ['English', 'Telugu', 'Hindi'],
        experience: '8 years',
        pricePerHour: 350,
        isAvailable: true,
        location: 'Kukatpally, Hyderabad',
        distanceKm: 2.3,
        availableSlots: ['10:00 AM', '2:00 PM', '4:00 PM'],
        hasInsurance: true,
        offersGuarantee: true,
        guaranteeDays: 30,
      ),
      ServiceProvider(
        id: 'p2',
        name: 'Sunita Devi',
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        category: ServiceCategory.cleaning,
        specializations: [
          ServiceCategory.cleaning,
          ServiceCategory.deepCleaning
        ],
        rating: 4.9,
        totalReviews: 567,
        completedJobs: 789,
        verificationLevel: VerificationLevel.premium,
        isBackgroundChecked: true,
        isFemale: true,
        isEcoFriendly: true,
        languages: ['English', 'Telugu', 'Hindi'],
        experience: '5 years',
        pricePerHour: 250,
        isAvailable: true,
        location: 'Madhapur, Hyderabad',
        distanceKm: 3.1,
        availableSlots: ['9:00 AM', '11:00 AM', '3:00 PM'],
        hasInsurance: true,
        offersGuarantee: true,
        guaranteeDays: 15,
      ),
      ServiceProvider(
        id: 'p3',
        name: 'Mohan Electricals',
        photoUrl: 'https://i.pravatar.cc/150?img=33',
        category: ServiceCategory.electrical,
        specializations: [
          ServiceCategory.electrical,
          ServiceCategory.appliance
        ],
        rating: 4.7,
        totalReviews: 189,
        completedJobs: 312,
        verificationLevel: VerificationLevel.verified,
        isBackgroundChecked: true,
        isCertified: true,
        languages: ['English', 'Telugu'],
        experience: '10 years',
        pricePerHour: 400,
        isAvailable: true,
        location: 'Ameerpet, Hyderabad',
        distanceKm: 4.5,
        availableSlots: ['10:00 AM', '1:00 PM', '5:00 PM'],
        hasInsurance: true,
        offersGuarantee: true,
        guaranteeDays: 45,
      ),
      ServiceProvider(
        id: 'p4',
        name: 'Priya Pest Control',
        photoUrl: 'https://i.pravatar.cc/150?img=28',
        category: ServiceCategory.pestControl,
        specializations: [ServiceCategory.pestControl],
        rating: 4.6,
        totalReviews: 145,
        completedJobs: 267,
        verificationLevel: VerificationLevel.verified,
        isBackgroundChecked: true,
        isFemale: true,
        isEcoFriendly: true,
        languages: ['English', 'Telugu', 'Hindi'],
        experience: '6 years',
        pricePerHour: 500,
        isAvailable: false,
        location: 'Gachibowli, Hyderabad',
        distanceKm: 5.2,
        availableSlots: [],
        hasInsurance: true,
        offersGuarantee: true,
        guaranteeDays: 60,
      ),
      ServiceProvider(
        id: 'p5',
        name: 'AC Care Services',
        photoUrl: 'https://i.pravatar.cc/150?img=51',
        category: ServiceCategory.acRepair,
        specializations: [ServiceCategory.acRepair, ServiceCategory.appliance],
        rating: 4.8,
        totalReviews: 298,
        completedJobs: 501,
        verificationLevel: VerificationLevel.certified,
        isBackgroundChecked: true,
        isCertified: true,
        languages: ['English', 'Telugu', 'Hindi'],
        experience: '12 years',
        pricePerHour: 450,
        isAvailable: true,
        location: 'Banjara Hills, Hyderabad',
        distanceKm: 6.0,
        availableSlots: ['9:00 AM', '12:00 PM', '3:00 PM', '6:00 PM'],
        hasInsurance: true,
        offersGuarantee: true,
        guaranteeDays: 90,
      ),
    ]);

    // Mock bookings
    _bookings.addAll([
      ServiceBooking(
        id: 'b1',
        userId: 'u1',
        providerId: 'p1',
        provider: _providers[0],
        category: ServiceCategory.plumbing,
        serviceType: ServiceType.emergency,
        title: 'Pipe Leak Repair',
        description: 'Water leaking from kitchen pipe',
        scheduledDate: DateTime.now().add(const Duration(hours: 2)),
        timeSlot: '2:00 PM - 3:00 PM',
        address: 'Flat 302, Sai Residency, Kukatpally',
        latitude: 17.4948,
        longitude: 78.3985,
        estimatedCost: 850,
        status: BookingStatus.confirmed,
        paymentMethod: PaymentMethod.upi,
        isPaid: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isEmergency: true,
        providerPhone: '+91 9876543210',
        otp: '4521',
      ),
      ServiceBooking(
        id: 'b2',
        userId: 'u1',
        providerId: 'p2',
        provider: _providers[1],
        category: ServiceCategory.cleaning,
        serviceType: ServiceType.oneTime,
        title: 'Home Deep Cleaning',
        description: '3BHK apartment deep cleaning',
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '9:00 AM - 1:00 PM',
        address: 'Villa 45, Green Valley, Madhapur',
        latitude: 17.4476,
        longitude: 78.3908,
        estimatedCost: 2500,
        status: BookingStatus.pending,
        paymentMethod: PaymentMethod.cash,
        isPaid: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ]);

    // Mock reviews
    _reviews.addAll([
      ServiceReview(
        id: 'r1',
        bookingId: 'b1',
        userId: 'u2',
        userName: 'Srinivas Rao',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=8',
        providerId: 'p1',
        rating: 5.0,
        comment:
            'Excellent service! Very professional and punctual. Fixed the issue quickly.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerifiedBooking: true,
        helpfulCount: 23,
      ),
      ServiceReview(
        id: 'r2',
        bookingId: 'b2',
        userId: 'u3',
        userName: 'Lakshmi Devi',
        userPhotoUrl: 'https://i.pravatar.cc/150?img=45',
        providerId: 'p2',
        rating: 4.8,
        comment:
            'Very thorough cleaning. Used eco-friendly products. Highly recommend!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerifiedBooking: true,
        helpfulCount: 18,
      ),
    ]);

    // Mock packages
    _packages.addAll([
      ServicePackage(
        id: 'pkg1',
        category: ServiceCategory.cleaning,
        title: 'Monthly Home Care',
        description: 'Regular home cleaning service',
        monthlyPrice: 1999,
        annualPrice: 19990,
        servicesPerMonth: 4,
        features: [
          '4 cleaning sessions per month',
          'Eco-friendly products',
          'Flexible scheduling',
          'Satisfaction guaranteed',
        ],
        isPopular: true,
        discountPercent: 17,
      ),
      ServicePackage(
        id: 'pkg2',
        category: ServiceCategory.pestControl,
        title: 'Pest-Free Home',
        description: 'Quarterly pest control service',
        monthlyPrice: 499,
        annualPrice: 4990,
        servicesPerMonth: 1,
        features: [
          '4 services per year',
          'Safe for kids & pets',
          '60-day guarantee',
          'Free inspection',
        ],
        isPopular: false,
        discountPercent: 17,
      ),
    ]);

    // Mock offers
    _offers.addAll([
      ServiceOffer(
        id: 'off1',
        title: 'First Booking Offer',
        description: 'Get 50% off on your first home service booking',
        code: 'FIRST50',
        discountPercent: 50,
        maxDiscount: 500,
        minOrderValue: 500,
        validTill: DateTime.now().add(const Duration(days: 30)),
        isFirstTimeUser: true,
      ),
      ServiceOffer(
        id: 'off2',
        title: 'Weekend Special',
        description: '30% off on all cleaning services',
        code: 'CLEAN30',
        discountPercent: 30,
        maxDiscount: 300,
        minOrderValue: 1000,
        validTill: DateTime.now().add(const Duration(days: 7)),
        applicableCategories: [
          ServiceCategory.cleaning,
          ServiceCategory.deepCleaning
        ],
      ),
    ]);

    _providersStreamController.add(_providers);
    _bookingsStreamController.add(_bookings);
  }

  // Fetch providers by category
  Future<List<ServiceProvider>> fetchProviders({
    ServiceCategory? category,
    bool? isAvailable,
    double? maxDistance,
    bool? isEcoFriendly,
    bool? isFemale,
    String? sortBy, // 'rating', 'price', 'distance'
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = List<ServiceProvider>.from(_providers);

    if (category != null) {
      filtered = filtered
          .where((p) =>
              p.category == category || p.specializations.contains(category))
          .toList();
    }

    if (isAvailable != null && isAvailable) {
      filtered = filtered.where((p) => p.isAvailable).toList();
    }

    if (maxDistance != null) {
      filtered = filtered.where((p) => p.distanceKm <= maxDistance).toList();
    }

    if (isEcoFriendly != null && isEcoFriendly) {
      filtered = filtered.where((p) => p.isEcoFriendly).toList();
    }

    if (isFemale != null && isFemale) {
      filtered = filtered.where((p) => p.isFemale).toList();
    }

    // Sort
    if (sortBy == 'rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy == 'price') {
      filtered.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
    } else if (sortBy == 'distance') {
      filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }

    return filtered;
  }

  // Create booking
  Future<ServiceBooking> createBooking({
    required String userId,
    required String providerId,
    required ServiceCategory category,
    required ServiceType serviceType,
    required String title,
    required String description,
    required DateTime scheduledDate,
    required String timeSlot,
    required String address,
    required double latitude,
    required double longitude,
    required double estimatedCost,
    String? specialInstructions,
    bool isEmergency = false,
    List<String> mediaUrls = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final provider = _providers.firstWhere((p) => p.id == providerId);

    final booking = ServiceBooking(
      id: 'b${_bookings.length + 1}',
      userId: userId,
      providerId: providerId,
      provider: provider,
      category: category,
      serviceType: serviceType,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      address: address,
      latitude: latitude,
      longitude: longitude,
      estimatedCost: estimatedCost,
      status: BookingStatus.pending,
      paymentMethod: PaymentMethod.upi,
      isPaid: false,
      createdAt: DateTime.now(),
      specialInstructions: specialInstructions,
      isEmergency: isEmergency,
      mediaUrls: mediaUrls,
      otp: '${1000 + (_bookings.length * 1234) % 9000}',
    );

    _bookings.add(booking);
    _bookingsStreamController.add(_bookings);

    return booking;
  }

  // Fetch user bookings
  Future<List<ServiceBooking>> fetchUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bookings.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Update booking status
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final oldBooking = _bookings[index];
      _bookings[index] = ServiceBooking(
        id: oldBooking.id,
        userId: oldBooking.userId,
        providerId: oldBooking.providerId,
        provider: oldBooking.provider,
        category: oldBooking.category,
        serviceType: oldBooking.serviceType,
        title: oldBooking.title,
        description: oldBooking.description,
        scheduledDate: oldBooking.scheduledDate,
        timeSlot: oldBooking.timeSlot,
        address: oldBooking.address,
        latitude: oldBooking.latitude,
        longitude: oldBooking.longitude,
        estimatedCost: oldBooking.estimatedCost,
        finalCost: oldBooking.finalCost,
        status: status,
        paymentMethod: oldBooking.paymentMethod,
        isPaid: oldBooking.isPaid,
        createdAt: oldBooking.createdAt,
        completedAt: status == BookingStatus.completed ? DateTime.now() : null,
        mediaUrls: oldBooking.mediaUrls,
        specialInstructions: oldBooking.specialInstructions,
        isEmergency: oldBooking.isEmergency,
        trackingUrl: oldBooking.trackingUrl,
        providerPhone: oldBooking.providerPhone,
        providerLat: oldBooking.providerLat,
        providerLng: oldBooking.providerLng,
        otp: oldBooking.otp,
      );
      _bookingsStreamController.add(_bookings);
    }
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String reason) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // Fetch reviews for provider
  Future<List<ServiceReview>> fetchProviderReviews(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _reviews.where((r) => r.providerId == providerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Submit review
  Future<ServiceReview> submitReview({
    required String bookingId,
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String providerId,
    required double rating,
    required String comment,
    List<String> mediaUrls = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final review = ServiceReview(
      id: 'r${_reviews.length + 1}',
      bookingId: bookingId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      providerId: providerId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
      mediaUrls: mediaUrls,
      isVerifiedBooking: true,
    );

    _reviews.add(review);
    return review;
  }

  // Fetch packages
  Future<List<ServicePackage>> fetchPackages(
      {ServiceCategory? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (category != null) {
      return _packages.where((p) => p.category == category).toList();
    }
    return _packages;
  }

  // Fetch offers
  Future<List<ServiceOffer>> fetchOffers({ServiceCategory? category}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var offers = _offers.where((o) => !o.isExpired).toList();

    if (category != null) {
      offers = offers
          .where((o) =>
              o.applicableCategories.isEmpty ||
              o.applicableCategories.contains(category))
          .toList();
    }

    return offers;
  }

  // Search providers
  Future<List<ServiceProvider>> searchProviders(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();
    return _providers
        .where((p) =>
            p.name.toLowerCase().contains(lowerQuery) ||
            ServiceCategoryHelper.getName(p.category)
                .toLowerCase()
                .contains(lowerQuery) ||
            p.location.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void dispose() {
    _providersStreamController.close();
    _bookingsStreamController.close();
  }
}
