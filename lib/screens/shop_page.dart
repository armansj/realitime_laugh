import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/auth_service.dart';
import '../l10n/app_localizations.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final List<ShopItem> _items = [
    ShopItem(
      id: 'hint_pack_small',
      name: 'Hint Pack (5)',
      description: 'Get 5 helpful hints for challenging levels',
      price: 100,
      icon: Icons.lightbulb,
      category: 'Hints',
    ),
    ShopItem(
      id: 'hint_pack_large',
      name: 'Hint Pack (15)',
      description: 'Get 15 helpful hints for challenging levels',
      price: 250,
      icon: Icons.lightbulb,
      category: 'Hints',
    ),
    ShopItem(
      id: 'time_boost',
      name: 'Time Boost',
      description: 'Get extra time for your next game',
      price: 50,
      icon: Icons.timer,
      category: 'Boosters',
    ),
    ShopItem(
      id: 'score_multiplier',
      name: 'Score Multiplier',
      description: 'Double your score for the next game',
      price: 150,
      icon: Icons.star,
      category: 'Boosters',
    ),
    ShopItem(
      id: 'premium_theme',
      name: 'Premium Theme',
      description: 'Unlock beautiful premium themes',
      price: 500,
      icon: Icons.palette,
      category: 'Themes',
    ),
    ShopItem(
      id: 'sound_pack',
      name: 'Sound Pack',
      description: 'Unlock new sound effects',      price: 200,
      icon: Icons.music_note,
      category: 'Audio',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.shop,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.accentOrange,
        foregroundColor: Colors.white,
        elevation: 0,        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: 18),                SizedBox(width: 4),                Text(
                  _isLoading ? '...' : '${_userData?['stars'] ?? 100}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.monetization_on, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  _isLoading ? '...' : '${_userData?['money'] ?? 0}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.accentOrange.withOpacity(0.1),
              AppTheme.primaryYellow.withOpacity(0.1),
            ],
          ),
        ),        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Star Purchase Section
            _buildStarPurchaseSection(l10n),
            
            const SizedBox(height: 20),
            
            // Shop Items Section
            Text(
              'Shop Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentOrange,
              ),
            ),
            const SizedBox(height: 12),
            
            // Shop Items
            ..._items.map((item) => _buildShopItem(item)).toList(),
          ],
        ),
      ),
    );
  }
  Widget _buildShopItem(ShopItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row with icon, title, and price
            Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppTheme.accentOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Price
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row with category and buy button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _purchaseItem(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }  void _purchaseItem(ShopItem item) {
    final userStars = _userData?['stars'] ?? 100;
    
    if (userStars < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough stars! You need ${item.price} stars.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item.description}\n'),
              Text('Price: ${item.price} stars'),
              Text('Your stars: $userStars'),
              Text('After purchase: ${userStars - item.price} stars'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  // Try to spend stars using the new method
                  bool purchaseSuccessful = await _authService.spendStars(item.price);
                  
                  if (purchaseSuccessful) {
                    // Reload user data
                    await _loadUserData();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully purchased ${item.name}!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Not enough stars for this purchase.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Purchase failed. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
              ),
              child: const Text('Buy'),
            ),
          ],
        );
      },
    );
  }
  Widget _buildStarPurchaseSection(AppLocalizations l10n) {
    final userMoney = _userData?['money'] ?? 0;
      // Star purchase options
    final starPackages = [
      {'stars': 50, 'money': 10, 'label': l10n.smallPackage},
      {'stars': 150, 'money': 25, 'label': l10n.mediumPackage},
      {'stars': 350, 'money': 50, 'label': l10n.largePackage},
      {'stars': 800, 'money': 100, 'label': l10n.megaPackage},
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),                Text(
                  l10n.purchaseStars,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Exchange your earned money for stars to buy shop items!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            // Star packages grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: starPackages.length,              itemBuilder: (context, index) {
                final package = starPackages[index];
                final canAfford = userMoney >= (package['money'] as int);
                
                return GestureDetector(
                  onTap: canAfford ? () => _purchaseStarPackage(package) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: canAfford ? AppTheme.primaryYellow.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: canAfford ? AppTheme.accentOrange : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: canAfford ? Colors.amber : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${package['stars']}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            package['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: canAfford ? AppTheme.accentOrange : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: canAfford ? Colors.green : Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${package['money']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: canAfford ? Colors.green : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseStarPackage(Map<String, dynamic> package) {
    final starsToBuy = package['stars'] as int;
    final moneyToSpend = package['money'] as int;
    final userMoney = _userData?['money'] ?? 0;
    
    if (userMoney < moneyToSpend) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough money! You need $moneyToSpend coins.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buy ${package['label']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You will receive:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('$starsToBuy stars'),
                ],
              ),
              const SizedBox(height: 16),
              Text('Cost:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.green, size: 20),
                  const SizedBox(width: 4),
                  Text('$moneyToSpend coins'),
                ],
              ),
              const SizedBox(height: 8),
              Text('After purchase: ${userMoney - moneyToSpend} coins'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                try {
                  // Purchase stars with money
                  bool purchaseSuccessful = await _authService.purchaseStars(starsToBuy, moneyToSpend);
                  
                  if (purchaseSuccessful) {
                    // Reload user data
                    await _loadUserData();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Successfully purchased $starsToBuy stars for $moneyToSpend coins!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase failed. Not enough money.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Buy Now'),
            ),
          ],
        );
      },
    );
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData icon;
  final String category;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
  });
}
