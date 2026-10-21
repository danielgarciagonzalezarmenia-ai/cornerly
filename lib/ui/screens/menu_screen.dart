import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;

        return CupertinoPageScaffold(
          backgroundColor: const Color(0xFFF6F7F4),
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Menú'),
            backgroundColor: const Color(0xFFF6F7F4),
            previousPageTitle: 'Atrás',
          ),
          child: SafeArea(
            child: ListView(
              children: [
                // Perfil
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryGreen,
                        child: Text(
                          (profile?.name.isNotEmpty == true ? profile!.name[0] : 'C').toUpperCase(),
                          style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w700, fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(profile?.name ?? 'Usuario', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Saldo: \$${(profile?.balance ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _menuItem(context, 'Perfil', CupertinoIcons.person, () {}),
                _menuItem(context, 'Agregar / retirar saldo', CupertinoIcons.money_dollar, () {}),
                _menuItem(context, 'Moneda', CupertinoIcons.cart, () {}),
                _menuItem(context, 'Hora del recordatorio', CupertinoIcons.clock, () {}),
                _menuItem(context, 'Porcentaje de riesgo', CupertinoIcons.percent, () {}),
                _menuItem(context, 'Notificaciones', CupertinoIcons.bell, () {}),
                const Divider(height: 1),
                _menuItem(context, 'Acerca de', CupertinoIcons.info, () => _showAbout(context)),
                _menuItem(context, 'Juego responsable', CupertinoIcons.hand_raised, () => _showResponsibleGaming(context)),
                const Divider(height: 1),
                _menuItem(context, 'Borrar todos los datos', CupertinoIcons.trash, () => _confirmClear(context, provider), isDestructive: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return CupertinoListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.redLoss : AppColors.textPrimary),
      title: Text(title, style: TextStyle(fontSize: 16, color: isDestructive ? AppColors.redLoss : AppColors.textPrimary)),
      trailing: const Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  void _showAbout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Acerca de Cornerly'),
        content: const Text('Cornerly v1.0.0\nApp local de análisis de apuestas de corners de fútbol.\nSin backend, sin cuentas, todo en tu dispositivo.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Aceptar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showResponsibleGaming(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Juego responsable'),
        content: const Text('Cornerly es una herramienta de análisis, no garantiza resultados. Apuesta solo lo que puedas permitirte perder.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Entendido'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, AppProvider provider) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Borrar todos los datos'),
        content: const Text('Esta acción eliminará toda tu información local y no se puede deshacer.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Borrar todo'),
            onPressed: () {
              provider.clearAllData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
