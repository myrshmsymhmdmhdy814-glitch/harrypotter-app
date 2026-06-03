import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class HorcruxGameScreen extends StatefulWidget {
  final VoidCallback onBack;
  const HorcruxGameScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<HorcruxGameScreen> createState() => _HorcruxGameScreenState();
}

class _HorcruxGameScreenState extends State<HorcruxGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late AppProvider _appProvider;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _appProvider = context.read<AppProvider>();
    _appProvider.resetGame();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _playDestroyAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('بازی هورکراکس‌ها'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Consumer<AppProvider>(
                builder: (context, provider, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'امتیاز',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 10,
                                ),
                      ),
                      Text(
                        '${provider.gameScore}',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryDark,
              Color(0xFF0A0E16),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              final allDestroyed =
                  provider.horcruxes.every((h) => h.isDestroyed);

              if (allDestroyed) {
                return _buildGameWon(context, provider);
              }

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${provider.destroyedHorcruxes}/${provider.horcruxes.length}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.accentGold,
                                  ),
                            ),
                            Text(
                              'هورکراکس‌های نابود شده',
                              style:
                                  Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: provider.destroyedHorcruxes /
                                provider.horcruxes.length,
                            minHeight: 8,
                            backgroundColor: AppTheme.borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: provider.horcruxes.length,
                      itemBuilder: (context, index) {
                        return _buildHorcruxCard(
                          context,
                          provider.horcruxes[index],
                          provider,
                          index,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHorcruxCard(
    BuildContext context,
    dynamic horcrux,
    AppProvider provider,
    int index,
  ) {
    final isDestroyed = horcrux.isDestroyed;

    return GestureDetector(
      onTap: isDestroyed
          ? null
          : () {
              _playDestroyAnimation();
              provider.destroyHorcrux(horcrux.id);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  Future.delayed(Duration(milliseconds: 1500), () {
                    if (mounted) Navigator.pop(context);
                  });
                  return Center(
                    child: Icon(
                      Icons.whatshot,
                      size: 100,
                      color: AppTheme.accentRed,
                    )
                        .animate()
                        .fadeIn()
                        .scale(begin: Offset(0.5, 0.5), duration: 500.ms),
                  );
                },
              );
            },
      child: Card(
        elevation: isDestroyed ? 0 : 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDestroyed ? AppTheme.accentRed : AppTheme.accentGold,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDestroyed
                  ? [
                      AppTheme.accentRed.withOpacity(0.2),
                      AppTheme.accentRed.withOpacity(0.05),
                    ]
                  : [
                      AppTheme.secondaryDark,
                      AppTheme.accentGold.withOpacity(0.1),
                    ],
            ),
          ),
          child: Stack(
            children: [
              if (isDestroyed)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: AppTheme.accentRed,
                    ),
                  ),
                ),
              if (!isDestroyed)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.diamond,
                      size: 60,
                      color: AppTheme.accentGold,
                    )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: index * 100))
                        .scale(delay: Duration(milliseconds: index * 100)),
                    SizedBox(height: 16),
                    Text(
                      horcrux.nameFarsi,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.accentGold,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'سختی: ${horcrux.difficulty}',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.accentGold,
                                ),
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: AppTheme.secondaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    horcrux.nameFarsi,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    horcrux.descriptionFarsi,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                    textAlign: TextAlign.right,
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryDark,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppTheme.accentGold,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'راهنمایی:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          horcrux.hint,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: Text('بستن'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.info),
                      label: Text('اطلاعات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: index * 100),
          duration: 600.ms,
        )
        .slideY(
          begin: 0.3,
          delay: Duration(milliseconds: index * 100),
          duration: 600.ms,
        );
  }

  Widget _buildGameWon(BuildContext context, AppProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            size: 100,
            color: AppTheme.accentGold,
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: Offset(0.3, 0.3),
                duration: 800.ms,
                curve: Curves.elasticOut,
              ),
          SizedBox(height: 24),
          Text(
            'تبریک!',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 48),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, delay: 400.ms),
          SizedBox(height: 12),
          Text(
            'همه هورکراکس‌ها را نابود کردید',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentGold, width: 2),
              color: AppTheme.accentGold.withOpacity(0.1),
            ),
            child: Column(
              children: [
                Text(
                  'امتیاز نهایی',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 8),
                Text(
                  '${provider.gameScore}',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 48),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 800.ms, duration: 600.ms)
              .scale(begin: Offset(0.8, 0.8), delay: 800.ms),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              provider.resetGame();
              setState(() {});
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Text('بازی دوباره'),
            ),
          )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 600.ms)
              .slideY(begin: 0.3, delay: 1000.ms),
        ],
      ),
    );
  }
}
