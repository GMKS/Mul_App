// Subscription Plans Screen
// Shows available subscription plans, features comparison, and upgrade options

import 'package:flutter/material.dart';
import '../models/business_model.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  final BusinessModel? currentBusiness;

  const SubscriptionPlansScreen({super.key, this.currentBusiness});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  bool _showAnnualPricing = false;
  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan.freePlan,
    SubscriptionPlan.basicPlan,
    SubscriptionPlan.premiumPlan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        actions: [
          // Current plan indicator
          if (widget.currentBusiness?.subscriptionPlan != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      widget.currentBusiness!.subscriptionPlan!.tierName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Pricing Toggle
          _buildPricingToggle(),

          // Plans Grid
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                ..._plans.map((plan) => _buildPlanCard(plan)),
                const SizedBox(height: 16),
                _buildFeaturesComparison(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('Monthly', !_showAnnualPricing),
          ),
          Expanded(
            child: _buildToggleButton('Annual (Save 17%)', _showAnnualPricing),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAnnualPricing = text.contains('Annual');
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan =
        widget.currentBusiness?.subscriptionPlan?.id == plan.id;
    final canUpgrade = _canUpgradeToPlan(plan);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: plan.isPopular ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: plan.isPopular
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name & Badge
                Row(
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (plan.badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          plan.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // Pricing
                if (_showAnnualPricing && plan.annualPrice != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${plan.annualPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '/year',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            if (plan.annualSavingsPercent != null)
                              Text(
                                'Save ${plan.annualSavingsPercent!.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.price == 0
                            ? 'Free'
                            : '₹${plan.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (plan.price > 0)
                        const Padding(
                          padding: EdgeInsets.only(top: 8, left: 8),
                          child: Text(
                            '/month',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Highlights
                ...plan.highlights.map((highlight) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: plan.tier == SubscriptionTier.premium
                                ? Colors.purple
                                : Colors.blue,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              highlight,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => _handlePlanAction(plan, canUpgrade),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: plan.isPopular ? Colors.blue : null,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan
                          ? 'Current Plan'
                          : canUpgrade
                              ? 'Upgrade to ${plan.name}'
                              : plan.tier == SubscriptionTier.free
                                  ? 'Downgrade to Free'
                                  : 'Select Plan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Current Plan Indicator
                if (isCurrentPlan &&
                    widget.currentBusiness!.subscriptionExpiryDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Renews on ${_formatDate(widget.currentBusiness!.subscriptionExpiryDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Features Comparison',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFeatureRow('Featured Listing', [false, true, true]),
            _buildFeatureRow('Priority Ranking', [false, true, true]),
            _buildFeatureRow('Video Marketing', [false, false, true]),
            _buildFeatureRow('Advanced Analytics', [false, false, true]),
            _buildFeatureRow('Custom Branding', [false, false, true]),
            _buildFeatureRow('Remove Ads', [false, false, true]),
            _buildFeatureRow('Priority Support', [false, true, true]),
            _buildFeatureRow('Customer Insights', [false, false, true]),
            const SizedBox(height: 12),
            _buildLimitRow('Max Videos', ['0', '3', 'Unlimited']),
            _buildLimitRow('Max Offers', ['1', '5', 'Unlimited']),
            _buildLimitRow('Max Photos', ['5', '15', 'Unlimited']),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, List<bool> availability) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature, style: const TextStyle(fontSize: 14)),
          ),
          ...availability.map((available) => Expanded(
                child: Center(
                  child: Icon(
                    available ? Icons.check_circle : Icons.cancel,
                    color: available ? Colors.green : Colors.grey[300],
                    size: 20,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLimitRow(String feature, List<String> limits) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(feature, style: const TextStyle(fontSize: 14)),
          ),
          ...limits.map((limit) => Expanded(
                child: Center(
                  child: Text(
                    limit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: limit == 'Unlimited'
                          ? Colors.purple
                          : Colors.grey[700],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  bool _canUpgradeToPlan(SubscriptionPlan plan) {
    if (widget.currentBusiness?.subscriptionPlan == null) return true;

    final currentTier = widget.currentBusiness!.subscriptionPlan!.tier;
    final targetTier = plan.tier;

    return targetTier.index > currentTier.index;
  }

  void _handlePlanAction(SubscriptionPlan plan, bool isUpgrade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpgrade ? 'Upgrade Plan' : 'Change Plan'),
        content: Text(
          'You are about to ${isUpgrade ? 'upgrade' : 'change'} to ${plan.name} plan.\n\n'
          'Price: ${plan.price == 0 ? 'Free' : '₹${plan.price}/month'}\n\n'
          'This is a demo - actual payment integration would be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage(plan);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(SubscriptionPlan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully subscribed to ${plan.name} plan!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
