import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/role.dart';
import '../../../domain/entities/permission.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1015),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16171E),
          title: const Text(
            'Quản lý Tài khoản & Phân quyền',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFF66FCF1),
            labelColor: Color(0xFF66FCF1),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Tài khoản', icon: Icon(Icons.people)),
              Tab(text: 'Phân quyền', icon: Icon(Icons.security)),
            ],
          ),
        ),
        body: Consumer<AccountProvider>(
          builder: (context, accountProvider, child) {
            if (accountProvider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF66FCF1)));
            }

            if (accountProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi: ${accountProvider.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => accountProvider.fetchAllData(),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1)),
                      child: const Text('Thử lại', style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildUsersTab(context, accountProvider),
                _buildRolesTab(context, accountProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, AccountProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách người dùng',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];
                // Lấy các role của user này
                final userRoleIds = provider.userRoles
                    .where((ur) => ur.userId == user.id)
                    .map((ur) => ur.roleId)
                    .toList();
                final userRolesList = provider.roles
                    .where((r) => userRoleIds.contains(r.id))
                    .map((r) => r.name)
                    .join(', ');

                return Card(
                  color: const Color(0xFF16171E),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF66FCF1).withOpacity(0.2),
                      child: const Icon(Icons.person, color: Color(0xFF66FCF1)),
                    ),
                    title: Text(user.fullName, style: const TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('Roles: ${userRolesList.isEmpty ? "Chưa có" : userRolesList}', 
                          style: const TextStyle(color: Color(0xFF66FCF1), fontSize: 12)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.manage_accounts, color: Colors.white),
                      onPressed: () => _showAssignRoleDialog(context, provider, user),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab(BuildContext context, AccountProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Danh sách Role
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Vai trò (Roles)',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF66FCF1)),
                      onPressed: () => _showCreateRoleDialog(context, provider),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.roles.length,
                    itemBuilder: (context, index) {
                      final role = provider.roles[index];
                      return Card(
                        color: const Color(0xFF16171E),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(role.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(role.description, style: const TextStyle(color: Colors.grey)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                onPressed: () => _showDeleteRoleConfirm(context, provider, role),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                            ],
                          ),
                          onTap: () => _showAssignPermissionDialog(context, provider, role),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Danh sách Permission
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quyền hạn (Permissions)',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Color(0xFF66FCF1)),
                      onPressed: () => _showCreatePermissionDialog(context, provider),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.permissions.length,
                    itemBuilder: (context, index) {
                      final permission = provider.permissions[index];
                      return Card(
                        color: const Color(0xFF16171E),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(permission.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(permission.description, style: const TextStyle(color: Colors.grey)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            onPressed: () => _showDeletePermissionConfirm(context, provider, permission),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignRoleDialog(BuildContext context, AccountProvider provider, User user) {
    bool isProcessing = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: Text('Gán vai trò cho ${user.fullName}', style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.roles.length,
                  itemBuilder: (context, index) {
                    final role = provider.roles[index];
                    final hasRole = provider.userRoles.any((ur) => ur.userId == user.id && ur.roleId == role.id);
                    
                    return CheckboxListTile(
                      title: Text(role.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(role.description, style: const TextStyle(color: Colors.grey)),
                      value: hasRole,
                      activeColor: const Color(0xFF66FCF1),
                      checkColor: Colors.black,
                      onChanged: isProcessing ? null : (value) async {
                        setState(() => isProcessing = true);
                        try {
                          if (value == true) {
                            await provider.assignRoleToUser(user.id, role.id);
                          } else {
                            await provider.removeRoleFromUser(user.id, role.id);
                          }
                        } finally {
                          if (context.mounted) setState(() => isProcessing = false);
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing ? null : () => Navigator.pop(ctx),
                  child: const Text('Đóng', style: TextStyle(color: Color(0xFF66FCF1))),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showAssignPermissionDialog(BuildContext context, AccountProvider provider, Role role) {
    bool isProcessing = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: Text('Gán quyền cho vai trò ${role.name}', style: const TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 500,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.permissions.length,
                  itemBuilder: (context, index) {
                    final permission = provider.permissions[index];
                    final hasPermission = provider.rolePermissions.any((rp) => rp.roleId == role.id && rp.permissionId == permission.id);
                    
                    return CheckboxListTile(
                      title: Text(permission.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(permission.description, style: const TextStyle(color: Colors.grey)),
                      value: hasPermission,
                      activeColor: const Color(0xFF66FCF1),
                      checkColor: Colors.black,
                      onChanged: isProcessing ? null : (value) async {
                        setState(() => isProcessing = true);
                        try {
                          if (value == true) {
                            await provider.assignPermissionToRole(role.id, permission.id);
                          } else {
                            await provider.removePermissionFromRole(role.id, permission.id);
                          }
                        } finally {
                          if (context.mounted) setState(() => isProcessing = false);
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing ? null : () => Navigator.pop(ctx),
                  child: const Text('Đóng', style: TextStyle(color: Color(0xFF66FCF1))),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showCreateRoleDialog(BuildContext context, AccountProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: const Text('Thêm Vai trò mới', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Tên Role (VD: Manager)'),
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    enabled: !isSaving,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameController.text.isNotEmpty) {
                      setState(() => isSaving = true);
                      try {
                        await provider.createRole(nameController.text, descController.text);
                        if (context.mounted) Navigator.pop(ctx);
                      } finally {
                        if (context.mounted) setState(() => isSaving = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1)),
                  child: isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('Lưu', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showCreatePermissionDialog(BuildContext context, AccountProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: const Text('Thêm Quyền mới', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Tên Permission (VD: Permissions.Movies.Create)'),
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                    enabled: !isSaving,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (nameController.text.isNotEmpty) {
                      setState(() => isSaving = true);
                      try {
                        await provider.createPermission(nameController.text, descController.text);
                        if (context.mounted) Navigator.pop(ctx);
                      } finally {
                        if (context.mounted) setState(() => isSaving = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF66FCF1)),
                  child: isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('Lưu', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          }
        );
      },
    );
  }
  void _showDeleteRoleConfirm(BuildContext context, AccountProvider provider, Role role) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: const Text('Xóa Vai trò', style: TextStyle(color: Colors.white)),
              content: Text('Bạn có chắc chắn muốn xóa vai trò "${role.name}" không?', style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isDeleting ? null : () async {
                    setState(() => isDeleting = true);
                    try {
                      await provider.deleteRole(role.id);
                      if (context.mounted) Navigator.pop(ctx);
                    } finally {
                      if (context.mounted) setState(() => isDeleting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: isDeleting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Xóa', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDeletePermissionConfirm(BuildContext context, AccountProvider provider, Permission permission) {
    bool isDeleting = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16171E),
              title: const Text('Xóa Quyền', style: TextStyle(color: Colors.white)),
              content: Text('Bạn có chắc chắn muốn xóa quyền "${permission.name}" không?', style: const TextStyle(color: Colors.white)),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isDeleting ? null : () async {
                    setState(() => isDeleting = true);
                    try {
                      await provider.deletePermission(permission.id);
                      if (context.mounted) Navigator.pop(ctx);
                    } finally {
                      if (context.mounted) setState(() => isDeleting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: isDeleting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Xóa', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
