/// Community Guidelines Screen
/// Shows app's community guidelines and rules

import 'package:flutter/material.dart';
import '../../services/moderation_service.dart';

class CommunityGuidelinesScreen extends StatelessWidget {
  const CommunityGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Color(0xFF16213e),
        title: Text('Community Guidelines'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield, size: 48, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Our Community',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Safe, Respectful, Inclusive',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Guidelines Content
            _buildGuidelineSection(
              icon: Icons.favorite,
              title: 'Be Respectful',
              description:
                  'Treat everyone with kindness and respect. No harassment, hate speech, or bullying.',
              examples: [
                '✓ Engage in constructive discussions',
                '✓ Respect different viewpoints',
                '✗ Personal attacks or insults',
                '✗ Discriminatory language',
              ],
            ),

            _buildGuidelineSection(
              icon: Icons.security,
              title: 'Keep It Safe',
              description: 'Help us maintain a safe environment for all users.',
              examples: [
                '✓ Report inappropriate content',
                '✓ Protect your privacy',
                '✗ Sharing harmful content',
                '✗ Violence or threats',
              ],
            ),

            _buildGuidelineSection(
              icon: Icons.verified_user,
              title: 'Be Authentic',
              description: 'Share genuine content and be yourself.',
              examples: [
                '✓ Post original content',
                '✓ Give credit to creators',
                '✗ Spam or fake accounts',
                '✗ Misleading information',
              ],
            ),

            _buildGuidelineSection(
              icon: Icons.gavel,
              title: 'Follow the Law',
              description: 'Comply with all applicable laws and regulations.',
              examples: [
                '✓ Respect intellectual property',
                '✓ Follow local laws',
                '✗ Copyright infringement',
                '✗ Illegal activities',
              ],
            ),

            _buildGuidelineSection(
              icon: Icons.child_care,
              title: 'Protect Minors',
              description: 'Ensure content is appropriate for all ages.',
              examples: [
                '✓ Family-friendly content',
                '✓ Age-appropriate language',
                '✗ Adult/explicit content',
                '✗ Endangering minors',
              ],
            ),

            SizedBox(height: 24),

            // Full Guidelines Text
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2a2a3e),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detailed Guidelines',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    ModerationService.communityGuidelines,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Consequences Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFef4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFef4444).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFFef4444)),
                      SizedBox(width: 8),
                      Text(
                        'Violations & Consequences',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildConsequenceRow('1st Violation', 'Warning + Education'),
                  _buildConsequenceRow(
                      '2nd Violation', 'Temporary Restrictions'),
                  _buildConsequenceRow('3rd Violation', 'Final Warning'),
                  _buildConsequenceRow('4th Violation', 'Account Suspension'),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Report Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // User can then report content
                },
                icon: Icon(Icons.flag),
                label: Text('Report Violations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9B59B6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Contact Support
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Open support/contact page
                },
                child: Text(
                  'Questions? Contact Support',
                  style: TextStyle(color: Color(0xFF9B59B6)),
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineSection({
    required IconData icon,
    required String title,
    required String description,
    required List<String> examples,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF9B59B6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Color(0xFF9B59B6), size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          ...examples.map((example) {
            final isPositive = example.startsWith('✓');
            return Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPositive ? '✓' : '✗',
                    style: TextStyle(
                      color: isPositive ? Color(0xFF10b981) : Color(0xFFef4444),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      example.substring(2), // Remove ✓ or ✗
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildConsequenceRow(String violation, String consequence) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFFef4444).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              violation,
              style: TextStyle(
                color: Color(0xFFef4444),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.arrow_forward,
              size: 16, color: Colors.white.withOpacity(0.5)),
          SizedBox(width: 12),
          Text(
            consequence,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
