/*import 'package:flutter/material.dart';
import 'package:hemacostos/ui/screens/calculo_costos_screen.dart';
import 'package:hemacostos/ui/screens/generar_presupuesto_screen.dart';
import 'package:hemacostos/ui/screens/historial_presupuesto_screen.dart';
import 'package:hemacostos/ui/screens/historial_calculos_screen.dart';
import 'package:hemacostos/ui/screens/insumos_screen.dart';
import 'package:hemacostos/ui/screens/recetas_screen.dart';
import 'package:hemacostos/ui/theme/app_theme.dart';*/
/*
/// Pantalla principal ; Jerarquia visual 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        title: const Text("HeMa Costos 🧁"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HERO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_outlined, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Calculá tus costos",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Creá recetas, calculá precios y generá presupuestos profesionales.",
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 28),



          _SectionTitle("Cómo funciona"),
          const SizedBox(height: 12),
          _WorkflowRow(),

          const SizedBox(height: 28),

            const Text(
              "Gestión",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [

                _MenuCard(
                  title: 'Insumos',
                  icon: Icons.inventory_2_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InsumosScreen())),
                ),

                _MenuCard(
                  title: 'Recetas',
                  icon: Icons.menu_book_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecetasScreen())),
                ),

                _MenuCard(
                  title: 'Costos',
                  icon: Icons.calculate_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CalculoCostosScreen())),
                ),

                _MenuCard(
                  title: 'Historial',
                  icon: Icons.history_outlined,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistorialCalculosScreen())),
                ),
              ],
            ),

            const SizedBox(height: 1),

            const Text(
              "Herramientas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _PrimaryActionCard(
              title: "Generar Presupuesto PDF",
              subtitle: "Crea presupuestos listos para enviar a tus clientes.",
              icon: Icons.picture_as_pdf_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GenerarPresupuestoScreen(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _SecondaryActionCard(
              title: "Historial de presupuestos",
              icon: Icons.picture_as_pdf_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistorialPresupuestoScreen(),
                ),
              ),
            ),

            const SizedBox(height: 222),
          ],

        ),
      ),
    );
  }
}

class _SecondaryActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SecondaryActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
      ),
    );
  }
}

// WORKFLOW ROW
class _WorkflowRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = <Map<String, dynamic>>[
      {'icon': Icons.inventory_2_outlined, 'label': 'Insumos'},
      {'icon': Icons.menu_book_outlined, 'label': 'Recetas'},
      {'icon': Icons.calculate_outlined, 'label': 'Costos'},
      {'icon': Icons.picture_as_pdf_outlined, 'label': 'PDF'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _WorkflowStepTile(
                icon: steps[i]['icon'] as IconData,
                label: steps[i]['label'] as String,
              ),
            ),
            if (i < steps.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: AppColors.textMuted,
                ),
              ),
          ]
        ],
      ),
    );
  }
}


// WORKFLOW STEP TILE
class _WorkflowStepTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WorkflowStepTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryDark),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Section Title
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}



class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });



  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13),
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16)
          ],
        ),
      ),
    );
  }
}
*/

// HOME SCREEN V2 (con workflow row y nuevo diseño)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hemacostos/ui/screens/calculo_costos_screen.dart';
import 'package:hemacostos/ui/screens/generar_presupuesto_screen.dart';
import 'package:hemacostos/ui/screens/historial_presupuesto_screen.dart';
import 'package:hemacostos/ui/screens/historial_calculos_screen.dart';
import 'package:hemacostos/ui/screens/insumos_screen.dart';
import 'package:hemacostos/ui/screens/recetas_screen.dart';
import 'package:hemacostos/ui/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionTitle('Cómo funciona'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(child: _WorkflowStrip()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionTitle('Gestión'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    _MenuCard(
                      title: 'Insumos',
                      subtitle: 'Materias primas',
                      emoji: '📦',
                      tintColor: AppColors.surfaceVariant,
                      onTap: () => _push(context, const InsumosScreen()),
                    ),
                    _MenuCard(
                      title: 'Recetas',
                      subtitle: 'Tus productos',
                      emoji: '🍰',
                      tintColor: const Color(0xFFFFF0EA),
                      onTap: () => _push(context, const RecetasScreen()),
                    ),
                    _MenuCard(
                      title: 'Costos',
                      subtitle: 'Con margen',
                      emoji: '💰',
                      tintColor: const Color(0xFFFDE8EE),
                      onTap: () => _push(context, const CalculoCostosScreen()),
                    ),
                    _MenuCard(
                      title: 'Historial',
                      subtitle: 'Cálculos previos',
                      emoji: '🕓',
                      tintColor: const Color(0xFFF3EDF8),
                      onTap: () =>
                          _push(context, const HistorialCalculosScreen()),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _SectionTitle('Herramientas'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _PrimaryActionCard(
                    title: 'Generar presupuesto PDF',
                    subtitle: 'Listo para enviar al cliente',
                    emoji: '📄',
                    onTap: () =>
                        _push(context, const GenerarPresupuestoScreen()),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                sliver: SliverToBoxAdapter(
                  child: _SecondaryActionCard(
                    title: 'Historial de presupuestos',
                    emoji: '🗂️',
                    onTap: () =>
                        _push(context, const HistorialPresupuestoScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

// ─── Hero header ──────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, topPadding + 18, 22, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            Color(0xFFFADDDF),
            AppColors.background,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Círculo decorativo
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -16,
            left: 60,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appbar inline
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withOpacity(0.16),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Transform.scale(
                        scale: 1.7,
                        child: Image.asset(
                          'assets/images/hemacostos_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'HeMa Costos',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Vendé con\n',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'margen real.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Tu taller de costos artesanales',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Workflow strip ───────────────────────────────────────────────────────────

class _WorkflowStrip extends StatelessWidget {
  static const _steps = [
    {'emoji': '📦', 'label': 'Insumos'},
    {'emoji': '🍰', 'label': 'Recetas'},
    {'emoji': '💰', 'label': 'Costos'},
    {'emoji': '📄', 'label': 'PDF'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant, width: 1),
      ),
      child: Row(
        children: [
          for (int i = 0; i < _steps.length; i++) ...[
            Expanded(child: _WorkflowStep(_steps[i])),
            if (i < _steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _WorkflowStep extends StatelessWidget {
  final Map<String, String> data;
  const _WorkflowStep(this.data);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(data['emoji']!, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          data['label']!,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      ),
    );
  }
}

// ─── Menu card ────────────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Color tintColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.tintColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.primaryLight.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.surfaceVariant, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tintColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Primary action card ──────────────────────────────────────────────────────

class _PrimaryActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final VoidCallback onTap;

  const _PrimaryActionCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.78),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.white.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Secondary action card ────────────────────────────────────────────────────

class _SecondaryActionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;

  const _SecondaryActionCard({
    required this.title,
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primaryLight.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceVariant, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 17)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}