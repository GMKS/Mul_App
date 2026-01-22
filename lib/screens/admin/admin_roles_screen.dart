/// Role-Based Access Control Screen
/// Manage admin roles and permissions

import 'package:flutter/material.dart';

class AdminRolesScreen extends StatefulWidget {
  const AdminRolesScreen({super.key});

  @override
  State<AdminRolesScreen> createState() => _AdminRolesScreenState();
}

class _AdminRolesScreenState extends State<AdminRolesScreen> {
  final List<Map<String, dynamic>> _admins = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'Super Admin',
      'permissions': ['all'],
      'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'role': 'Moderator',
      'permissions': ['content_approval', 'moderation'],
      'lastActive': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': '3',
      'name': 'Bob Johnson',
      'email': 'bob@example.com',
      'role': 'Content Manager',
      'permissions': ['content_management', 'analytics'],
      'lastActive': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  final Map<String, List<String>> _rolePermissions = {
    'Super Admin': ['all'],
    'Moderator': ['content_approval', 'moderation', 'reports'],
    'Content Manager': ['content_management', 'analytics', 'notifications'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f1e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Roles & Permissions',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _showAddAdminDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRolesSummary(),
          Expanded(child: _buildAdminsList()),
        ],
      ),
    );
  }

  Widget _buildRolesSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1a1a2e),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Roles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rolePermissions.keys.map((role) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getRoleColor(role)),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    color: _getRoleColor(role),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _admins.length,
      itemBuilder: (context, index) {
        final admin = _admins[index];
        return _buildAdminCard(admin);
      },
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> admin) {
    final roleColor = _getRoleColor(admin['role']);
    final lastActive = admin['lastActive'] as DateTime;
    final timeDiff = DateTime.now().difference(lastActive);
    final isOnline = timeDiff.inHours < 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: roleColor.withOpacity(0.3),
                    child: Text(
                      admin['name'][0],
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10b981),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1a1a2e), width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      admin['email'],
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        admin['role'],
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: const Color(0xFF2a2a3e),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Edit Role',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'permissions',
                    child: Row(
                      children: [
                        Icon(Icons.security, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Permissions',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'activity',
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Activity Log',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Color(0xFFef4444)),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) =>
                    _handleAdminAction(value.toString(), admin),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2a2a3e)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (admin['permissions'] as List<String>).map((permission) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366f1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 12, color: Color(0xFF6366f1)),
                    const SizedBox(width: 4),
                    Text(
                      permission == 'all'
                          ? 'All Permissions'
                          : permission.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF6366f1),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Super Admin':
        return const Color(0xFF8b5cf6);
      case 'Moderator':
        return const Color(0xFFf59e0b);
      case 'Content Manager':
        return const Color(0xFF10b981);
      default:
        return const Color(0xFF6366f1);
    }
  }

  void _handleAdminAction(String action, Map<String, dynamic> admin) {
    switch (action) {
      case 'edit':
        _showEditRoleDialog(admin);
        break;
      case 'permissions':
        _showPermissionsDialog(admin);
        break;
      case 'activity':
        _showComingSoon();
        break;
      case 'remove':
        _removeAdmin(admin);
        break;
    }
  }

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title:
            const Text('Add New Admin', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2a2a3e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2a2a3e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
            ),
            child: const Text('Add Admin'),
          ),
        ],
      ),
    );
  }

  void _showEditRoleDialog(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Change Role', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _rolePermissions.keys.map((role) {
            return RadioListTile<String>(
              title: Text(role, style: const TextStyle(color: Colors.white)),
              value: role,
              groupValue: admin['role'],
              activeColor: const Color(0xFF6366f1),
              onChanged: (value) {
                setState(() {
                  admin['role'] = value;
                  admin['permissions'] = _rolePermissions[value]!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPermissionsDialog(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Permissions', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              admin['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${admin['role']}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Granted Permissions:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...(admin['permissions'] as List<String>).map(
              (permission) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: Color(0xFF10b981)),
                    const SizedBox(width: 8),
                    Text(
                      permission == 'all'
                          ? 'All Permissions'
                          : permission.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _removeAdmin(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title:
            const Text('Remove Admin', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove ${admin['name']}?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _admins.remove(admin);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Admin removed'),
                  backgroundColor: Color(0xFFef4444),
                ),
              );
            },
            child: const Text('Remove',
                style: TextStyle(color: Color(0xFFef4444))),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: Color(0xFF6366f1),
      ),
    );
  }
}
