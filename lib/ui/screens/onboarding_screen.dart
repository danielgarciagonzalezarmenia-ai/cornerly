import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _currency = 'COP';
  String _currencySymbol = '\$';
  String _experience = 'Principiante';
  double _riskPct = 5.0;
  String _reminderTime = '10:00';
  bool _notifications = false;

  final List<String> _currencies = const ['COP', 'USD', 'EUR', 'BRL', 'MXN'];
  final Map<String, String> _currencySymbols = const {
    'COP': '\$', 'USD': '\$', 'EUR': '\u20AC', 'BRL': 'R\$', 'MXN': '\$',
  };
  final List<String> _experiences = const ['Principiante', 'Intermedio', 'Avanzado'];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 6) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    final provider = context.read<AppProvider>();
    await provider.createProfile(
      name: _nameController.text.trim(),
      currency: _currency,
      currencySymbol: _currencySymbol,
      balance: balance,
      experience: _experience,
      riskMaxPct: _riskPct,
      reminderTime: _reminderTime,
    );
    await provider.completeOnboarding();
  }

  Widget _buildStep(int index, Widget child) => _step == index ? child : const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F7F4),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Bienvenido a Cornerly'),
        backgroundColor: const Color(0xFFF6F7F4),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_step + 1) / 7,
                    backgroundColor: const Color(0xFFE6E6E6),
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildStep(0, _buildTextStep(
                            '¿Cómo te llamas?',
                            'Este nombre se usará para saludarte en la app.',
                            _nameController,
                          )),
                          _buildStep(1, _buildTextStep(
                            '¿Cuál es tu saldo total actual para apuestas?',
                            'Ingresa el monto en tu moneda.',
                            _balanceController,
                            keyboardType: TextInputType.number,
                          )),
                          _buildStep(2, _buildSelectorStep(
                            '¿En qué moneda manejas tu saldo?',
                            'COP',
                            _currencies,
                            (v) {
                              setState(() {
                                _currency = v!;
                                _currencySymbol = _currencySymbols[v]!;
                              });
                            },
                            _currency,
                          )),
                          _buildStep(3, _buildSelectorStep(
                            '¿Qué experiencia tienes apostando?',
                            'Selecciona tu nivel.',
                            _experiences,
                            (v) => setState(() => _experience = v!),
                            _experience,
                          )),
                          _buildStep(4, _buildSliderStep(
                            '¿Qué porcentaje máximo de tu saldo quieres arriesgar por combinada?',
                            'Se usará como advertencia, no como bloqueo.',
                            _riskPct,
                            (v) => setState(() => _riskPct = v),
                          )),
                          _buildStep(5, _buildTimeStep(
                            '¿A qué hora quieres el recordatorio diario?',
                            'Te avisaremos para que analices los partidos.',
                            _reminderTime,
                            (v) => setState(() => _reminderTime = v),
                          )),
                          _buildStep(6, _buildBoolStep(
                            'Permiso de notificaciones',
                            'Cornerly te enviará recordatorios y avisos de tus combinadas.',
                            _notifications,
                            (v) => setState(() => _notifications = v!),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 56,
                child: CupertinoButton.filled(
                  onPressed: _step < 6 ? _next : _finish,
                  child: Text(_step < 6 ? 'Continuar' : 'Comenzar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextStep(String title, String subtitle, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: controller,
          keyboardType: keyboardType,
          placeholder: 'Ingresa aquí',
          padding: const EdgeInsets.all(16),
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSelectorStep(String title, String subtitle, List<String> options, ValueChanged<String?> onChanged, String current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        CupertinoSegmentedControl<String>(
          children: {for (final o in options) o: Text(o)},
          onValueChanged: onChanged,
          groupValue: current,
        ),
      ],
    );
  }

  Widget _buildSliderStep(String title, String subtitle, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('${value.toInt()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(width: 12),
            Expanded(
              child: CupertinoSlider(
                min: 1, max: 50, divisions: 49,
                value: value, onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeStep(String title, String subtitle, String current, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            final picked = await showCupertinoModalPopup<DateTime>(
              context: context,
              builder: (_) => CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2024, 1, 1, 10, 0),
                onDateTimeChanged: (dt) {},
                minuteInterval: 1,
              ),
            );
            if (picked != null) {
              final h = picked.hour.toString().padLeft(2, '0');
              final m = picked.minute.toString().padLeft(2, '0');
              onChanged('$h:$m');
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6E6E6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hora del recordatorio', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
                Text(current, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                const Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoolStep(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
