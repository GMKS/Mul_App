// Business Dashboard Screen
// Allows businesses to manage their subscription, toggle featured status, and view analytics

import 'package:flutter/material.dart';
import '../models/business_model.dart';
import 'subscription_plans_screen.dart';

class BusinessDashboardScreen extends StatefulWidget {
  final BusinessModel business;

  const BusinessDashboardScreen({super.key, required this.business});

  @override
  State<BusinessDashboardScreen> createState() =>
      _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  late BusinessModel _business;

  @override
  void initState() {
    super.initState();
    _business = widget.business;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Settings
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Business Header
          _buildBusinessHeader(),
          const SizedBox(height: 24),

          // Subscription Card
          _buildSubscriptionCard(),
          const SizedBox(height: 16),

          // Priority Score Card
          _buildPriorityScoreCard(),
          const SizedBox(height: 16),

          // Featured Toggle Card
          _buildFeaturedToggleCard(),
          const SizedBox(height: 16),

          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 16),

          // Feature Limits
          _buildFeatureLimits(),
        ],
      ),
    );
  }

  Widget _buildBusinessHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                    Text(_business.emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _business.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _business.category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (_business.isVerified)
              const Icon(Icons.verified, color: Colors.blue, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final plan = _business.subscriptionPlan;
    final hasActivePlan = _business.hasActiveSubscription;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: plan?.tier == SubscriptionTier.premium
                      ? Colors.purple
                      : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Subscription Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (plan != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.tierName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: plan.tier == SubscriptionTier.premium
                                ? Colors.purple
                                : plan.tier == SubscriptionTier.basic
                                    ? Colors.blue
                                    : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (hasActivePlan &&
                            _business.subscriptionExpiryDate != null)
                          Text(
                            'Expires: ${_formatDate(_business.subscriptionExpiryDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        if (hasActivePlan)
                          Text(
                            '${_business.subscriptionDaysRemaining} days remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: _business.subscriptionDaysRemaining < 7
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.price == 0 ? 'Free' : '₹${plan.price}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (plan.price > 0)
                        Text(
                          '/month',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubscriptionPlansScreen(currentBusiness: _business),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upgrade),
                  label: Text(
                    plan.tier == SubscriptionTier.premium
                        ? 'Manage Subscription'
                        : 'Upgrade Plan',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityScoreCard() {
    final score = _business.priorityScore;
    final maxScore = 100.0;
    final percentage = (score / maxScore * 100).clamp(0, 100);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Visibility Priority',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'out of $maxScore',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage >= 75
                              ? Colors.green
                              : percentage >= 50
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Score Breakdown:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildScoreItem(
              'Subscription Plan',
              _getSubscriptionPoints(),
              40,
              Icons.workspace_premium,
            ),
            _buildScoreItem(
              'Featured Status',
              _business.isFeatured ? 30 : 0,
              30,
              Icons.star,
            ),
            _buildScoreItem(
              'Engagement',
              (_business.engagementScore / 10000 * 20).clamp(0, 20),
              20,
              Icons.favorite,
            ),
            _buildScoreItem(
              'Verification',
              _business.isVerified ? 5 : 0,
              5,
              Icons.verified,
            ),
            _buildScoreItem(
              'Rating',
              _business.rating ?? 0,
              5,
              Icons.star_rate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(
      String label, double score, double max, IconData icon) {
    final percentage = (score / max * 100).clamp(0, 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                '${score.toStringAsFixed(1)}/$max',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 75
                  ? Colors.green
                  : percentage >= 50
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedToggleCard() {
    final canToggle = BusinessMonetization.canToggleFeatured(_business);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Featured Listing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: _business.isFeatured,
                  onChanged: canToggle
                      ? (value) {
                          setState(() {
                            final updated =
                                BusinessMonetization.toggleFeaturedStatus(
                              _business,
                              value,
                            );
                            if (updated != null) {
                              _business = updated;
                              _showMessage(
                                value
                                    ? 'Featured listing enabled!'
                                    : 'Featured listing disabled',
                                value ? Colors.green : Colors.grey,
                              );
                            } else {
                              _showMessage(
                                'Unable to toggle featured status',
                                Colors.red,
                              );
                            }
                          });
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!canToggle)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Upgrade to Basic or Premium to use featured listing',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionPlansScreen(
                                currentBusiness: _business),
                          ),
                        );
                      },
                      child: const Text('Upgrade'),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                _business.isFeatured
                    ? 'Your business is currently featured and appears at the top of search results.'
                    : 'Enable featured listing to boost your visibility and appear at the top of search results.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              if (_business.featuredDaysRemaining > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${_business.featuredDaysRemaining} featured days remaining this month',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.visibility,
                    _business.analytics?.profileViews.toString() ?? '0',
                    'Profile Views',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.favorite,
                    _business.engagementScore.toString(),
                    'Engagement',
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.star,
                    _business.rating?.toStringAsFixed(1) ?? 'N/A',
                    'Rating',
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.people,
                    _business.followers?.toString() ?? '0',
                    'Followers',
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureLimits() {
    if (_business.subscriptionPlan == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feature Limits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLimitItem(
              Icons.videocam,
              'Videos',
              BusinessMonetization.getFeatureLimitText(_business, 'videos'),
            ),
            _buildLimitItem(
              Icons.local_offer,
              'Offers',
              BusinessMonetization.getFeatureLimitText(_business, 'offers'),
            ),
            _buildLimitItem(
              Icons.photo,
              'Photos',
              BusinessMonetization.getFeatureLimitText(_business, 'photos'),
            ),
            _buildLimitItem(
              Icons.star,
              'Featured Days',
              BusinessMonetization.getFeatureLimitText(
                  _business, 'featured_days'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitItem(IconData icon, String label, String limit) {
    final isUnlimited = limit.contains('Unlimited');
    final needsUpgrade = limit.contains('Upgrade');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            limit,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isUnlimited
                  ? Colors.green
                  : needsUpgrade
                      ? Colors.orange
                      : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  double _getSubscriptionPoints() {
    if (_business.subscriptionPlan == null) return 0;
    switch (_business.subscriptionPlan!.tier) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.basic:
        return 20;
      case SubscriptionTier.premium:
        return 40;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
