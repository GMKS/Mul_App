/// Feedback Service
/// Manages feedback, suggestions, polls, and voting operations

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  // Mock data storage
  final List<UserFeedback> _feedbackList = [];
  final List<CommunityPoll> _pollsList = [];
  final List<UserVote> _userVotes = [];
  final List<FeedbackComment> _comments = [];

  // Stream controllers
  final _feedbackStreamController =
      StreamController<List<UserFeedback>>.broadcast();
  final _pollsStreamController =
      StreamController<List<CommunityPoll>>.broadcast();

  Stream<List<UserFeedback>> get feedbackStream =>
      _feedbackStreamController.stream;
  Stream<List<CommunityPoll>> get pollsStream => _pollsStreamController.stream;

  // Initialize with mock data
  void initializeMockData(String city, String state) {
    _feedbackList.clear();
    _pollsList.clear();

    // Mock feedback items
    _feedbackList.addAll([
      UserFeedback(
        id: 'fb1',
        userId: 'user1',
        userName: 'Rajesh Kumar',
        type: FeedbackType.feature,
        title: 'Add Dark Mode Support',
        description:
            'It would be great to have a dark mode option for better viewing at night.',
        status: FeedbackStatus.planned,
        city: city,
        state: state,
        language: 'en',
        upvotes: 142,
        downvotes: 5,
        commentCount: 23,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: ['UI', 'Accessibility'],
      ),
      UserFeedback(
        id: 'fb2',
        userId: 'user2',
        userName: 'Priya Sharma',
        type: FeedbackType.bug,
        title: 'App crashes when uploading video',
        description:
            'The app crashes whenever I try to upload a video longer than 30 seconds.',
        status: FeedbackStatus.inProgress,
        city: city,
        state: state,
        language: 'en',
        upvotes: 89,
        downvotes: 2,
        commentCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        adminResponse:
            'We are working on this issue. Fix will be deployed in the next update.',
        adminResponseAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['Bug', 'Video'],
      ),
      UserFeedback(
        id: 'fb3',
        userId: 'user3',
        userName: 'Anonymous',
        isAnonymous: true,
        type: FeedbackType.service,
        title: 'Cab services are expensive',
        description:
            'The cab fares in our area are much higher than other apps.',
        status: FeedbackStatus.underReview,
        city: city,
        state: state,
        language: 'en',
        upvotes: 67,
        downvotes: 12,
        commentCount: 31,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['Service', 'Pricing'],
      ),
      UserFeedback(
        id: 'fb4',
        userId: 'user4',
        userName: 'Amit Patel',
        type: FeedbackType.safety,
        title: 'Need better street lighting near park',
        description:
            'The street lights near City Park are not working properly. Very unsafe at night.',
        status: FeedbackStatus.resolved,
        city: city,
        state: state,
        language: 'en',
        upvotes: 156,
        downvotes: 3,
        commentCount: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        adminResponse:
            'Municipal corporation has been notified and lights have been fixed.',
        adminResponseAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['Safety', 'Infrastructure'],
      ),
      UserFeedback(
        id: 'fb5',
        userId: 'user5',
        userName: 'Sneha Reddy',
        type: FeedbackType.improvement,
        title: 'Add voice search in Telugu',
        description: 'Please add voice search support in Telugu language.',
        status: FeedbackStatus.planned,
        city: city,
        state: state,
        language: 'te',
        upvotes: 203,
        downvotes: 8,
        commentCount: 56,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        tags: ['Feature', 'Language', 'Accessibility'],
      ),
    ]);

    // Mock polls
    _pollsList.addAll([
      CommunityPoll(
        id: 'poll1',
        title: 'Which new feature should we prioritize?',
        description:
            'Help us decide what to build next by voting for your favorite feature.',
        options: [
          PollOption(
              id: 'opt1', text: 'Dark Mode', votes: 456, color: Colors.blue),
          PollOption(
              id: 'opt2',
              text: 'Video Filters',
              votes: 312,
              color: Colors.purple),
          PollOption(
              id: 'opt3',
              text: 'Live Streaming',
              votes: 589,
              color: Colors.red),
          PollOption(
              id: 'opt4',
              text: 'Voice Messages',
              votes: 234,
              color: Colors.green),
        ],
        totalVotes: 1591,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        expiresAt: DateTime.now().add(const Duration(days: 9)),
        city: city,
        state: state,
      ),
      CommunityPoll(
        id: 'poll2',
        title: 'Rate your app experience',
        description: 'How satisfied are you with the app so far?',
        options: [
          PollOption(
              id: 'opt1',
              text: 'Excellent 😍',
              votes: 678,
              color: Colors.green),
          PollOption(
              id: 'opt2', text: 'Good 👍', votes: 423, color: Colors.blue),
          PollOption(
              id: 'opt3', text: 'Average 😐', votes: 156, color: Colors.orange),
          PollOption(id: 'opt4', text: 'Poor 😞', votes: 34, color: Colors.red),
        ],
        totalVotes: 1291,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        city: city,
        state: state,
      ),
    ]);

    _feedbackStreamController.add(_feedbackList);
    _pollsStreamController.add(_pollsList);
  }

  // Fetch feedback with filters
  Future<List<UserFeedback>> fetchFeedback({
    FeedbackType? type,
    FeedbackStatus? status,
    String? sortBy,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var filtered = List<UserFeedback>.from(_feedbackList);

    if (type != null) {
      filtered = filtered.where((f) => f.type == type).toList();
    }

    if (status != null) {
      filtered = filtered.where((f) => f.status == status).toList();
    }

    // Sort by upvotes (trending)
    if (sortBy == 'trending') {
      filtered.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    } else {
      // Sort by recent
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  // Submit new feedback
  Future<bool> submitFeedback({
    required String userId,
    required String userName,
    required FeedbackType type,
    required String title,
    required String description,
    required String city,
    required String state,
    required String language,
    bool isAnonymous = false,
    List<FeedbackMedia> media = const [],
    List<String> tags = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final feedback = UserFeedback(
      id: 'fb${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userName: isAnonymous ? 'Anonymous' : userName,
      type: type,
      title: title,
      description: description,
      media: media,
      status: FeedbackStatus.received,
      isAnonymous: isAnonymous,
      city: city,
      state: state,
      language: language,
      createdAt: DateTime.now(),
      tags: tags,
    );

    _feedbackList.insert(0, feedback);
    _feedbackStreamController.add(_feedbackList);

    return true;
  }

  // Vote on feedback
  Future<bool> voteFeedback(String feedbackId, String userId,
      {required bool isUpvote}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Remove existing vote
    _userVotes
        .removeWhere((v) => v.feedbackId == feedbackId && v.userId == userId);

    // Add new vote
    _userVotes.add(UserVote(
      userId: userId,
      feedbackId: feedbackId,
      isUpvote: isUpvote,
      votedAt: DateTime.now(),
    ));

    // Update feedback counts
    final index = _feedbackList.indexWhere((f) => f.id == feedbackId);
    if (index != -1) {
      final feedback = _feedbackList[index];
      final newUpvotes = isUpvote ? feedback.upvotes + 1 : feedback.upvotes;
      final newDownvotes =
          !isUpvote ? feedback.downvotes + 1 : feedback.downvotes;

      _feedbackList[index] = UserFeedback(
        id: feedback.id,
        userId: feedback.userId,
        userName: feedback.userName,
        userAvatar: feedback.userAvatar,
        type: feedback.type,
        title: feedback.title,
        description: feedback.description,
        media: feedback.media,
        status: feedback.status,
        isAnonymous: feedback.isAnonymous,
        city: feedback.city,
        state: feedback.state,
        language: feedback.language,
        upvotes: newUpvotes,
        downvotes: newDownvotes,
        commentCount: feedback.commentCount,
        createdAt: feedback.createdAt,
        updatedAt: feedback.updatedAt,
        adminResponse: feedback.adminResponse,
        adminResponseAt: feedback.adminResponseAt,
        tags: feedback.tags,
      );

      _feedbackStreamController.add(_feedbackList);
    }

    return true;
  }

  // Get user's vote for a feedback
  bool? getUserVote(String feedbackId, String userId) {
    final vote = _userVotes.firstWhere(
        (v) => v.feedbackId == feedbackId && v.userId == userId,
        orElse: () => UserVote(
              userId: '',
              feedbackId: '',
              isUpvote: false,
              votedAt: DateTime.now(),
            ));

    if (vote.userId.isEmpty) return null;
    return vote.isUpvote;
  }

  // Fetch polls
  Future<List<CommunityPoll>> fetchPolls({bool activeOnly = true}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var filtered = List<CommunityPoll>.from(_pollsList);

    if (activeOnly) {
      filtered = filtered.where((p) => p.isActive && !p.isExpired).toList();
    }

    return filtered;
  }

  // Vote on poll
  Future<bool> votePoll(String pollId, String userId, String optionId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _pollsList.indexWhere((p) => p.id == pollId);
    if (index == -1) return false;

    final poll = _pollsList[index];
    final updatedOptions = poll.options.map((opt) {
      if (opt.id == optionId) {
        return PollOption(
          id: opt.id,
          text: opt.text,
          votes: opt.votes + 1,
          color: opt.color,
        );
      }
      return opt;
    }).toList();

    _pollsList[index] = CommunityPoll(
      id: poll.id,
      title: poll.title,
      description: poll.description,
      options: updatedOptions,
      totalVotes: poll.totalVotes + 1,
      createdAt: poll.createdAt,
      expiresAt: poll.expiresAt,
      isActive: poll.isActive,
      allowMultipleVotes: poll.allowMultipleVotes,
      city: poll.city,
      state: poll.state,
    );

    _pollsStreamController.add(_pollsList);
    return true;
  }

  // Add comment to feedback
  Future<bool> addComment({
    required String feedbackId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final newComment = FeedbackComment(
      id: 'comment${DateTime.now().millisecondsSinceEpoch}',
      feedbackId: feedbackId,
      userId: userId,
      userName: userName,
      comment: comment,
      createdAt: DateTime.now(),
    );

    _comments.add(newComment);

    // Update comment count
    final index = _feedbackList.indexWhere((f) => f.id == feedbackId);
    if (index != -1) {
      final feedback = _feedbackList[index];
      _feedbackList[index] = UserFeedback(
        id: feedback.id,
        userId: feedback.userId,
        userName: feedback.userName,
        userAvatar: feedback.userAvatar,
        type: feedback.type,
        title: feedback.title,
        description: feedback.description,
        media: feedback.media,
        status: feedback.status,
        isAnonymous: feedback.isAnonymous,
        city: feedback.city,
        state: feedback.state,
        language: feedback.language,
        upvotes: feedback.upvotes,
        downvotes: feedback.downvotes,
        commentCount: feedback.commentCount + 1,
        createdAt: feedback.createdAt,
        updatedAt: feedback.updatedAt,
        adminResponse: feedback.adminResponse,
        adminResponseAt: feedback.adminResponseAt,
        tags: feedback.tags,
      );

      _feedbackStreamController.add(_feedbackList);
    }

    return true;
  }

  // Get comments for feedback
  Future<List<FeedbackComment>> getComments(String feedbackId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _comments.where((c) => c.feedbackId == feedbackId).toList();
  }

  void dispose() {
    _feedbackStreamController.close();
    _pollsStreamController.close();
  }
}
