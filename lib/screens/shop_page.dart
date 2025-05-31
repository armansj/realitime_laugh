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
  List<String> _purchasedItems = [];
  bool _isLoading = true;
    late final List<ShopItem> _items;

  @override
  void initState() {
    super.initState();
    _initializeItems();
    _loadUserData();
  }
  void _initializeItems() {
    _items = [
      // Emoji Packs
      ShopItem(
        id: 'emoji_pack_faces',
        name: 'Happy Faces Pack',
        description: 'Collection of joyful face emojis',
        price: 50,
        category: 'Emoji Packs',
        type: ShopItemType.emojiPack,
        levelRequired: 5,
        emoji: '🤩', // Preview emoji
      ),
      ShopItem(
        id: 'emoji_pack_animals',
        name: 'Animal Pack',
        description: 'Cute animal emojis',
        price: 60,
        category: 'Emoji Packs',
        type: ShopItemType.emojiPack,
        levelRequired: 8,
        emoji: '🐶', // Preview emoji
      ),
      ShopItem(
        id: 'emoji_pack_cats',
        name: 'Cat Pack',
        description: 'Cat face expressions',
        price: 45,
        category: 'Emoji Packs',
        type: ShopItemType.emojiPack,
        levelRequired: 6,
        emoji: '😺', // Preview emoji
      ),
      ShopItem(
        id: 'emoji_pack_nature',
        name: 'Nature Pack',
        description: 'Beautiful nature emojis',
        price: 55,
        category: 'Emoji Packs',
        type: ShopItemType.emojiPack,
        levelRequired: 10,
        emoji: '🌸', // Preview emoji
      ),
      ShopItem(
        id: 'emoji_pack_food',
        name: 'Food Pack',
        description: 'Delicious food emojis',
        price: 40,
        category: 'Emoji Packs',
        type: ShopItemType.emojiPack,
        levelRequired: 3,
        emoji: '🍞', // Preview emoji
      ),
      ShopItem(
        id: 'emoji_pack_special',
        name: 'Special Pack',
        description: 'Unique special emojis',
        price: 75,
        category: 'Emoji Packs',
        type: ShopItemType.emojiPack,
        levelRequired: 15,
        emoji: '👽', // Preview emoji
      ),

      // Camera Filters (including none filter)
      ShopItem(
        id: 'none',
        name: 'No Filter',
        description: 'Remove all camera filters',
        price: 0,
        category: 'Camera Filters',
        type: ShopItemType.cameraFilter,
        levelRequired: 1,
        icon: Icons.clear,
        preview: 'Original camera view',
      ),
      ShopItem(
        id: 'beauty',
        name: 'Beauty Filter',
        description: 'Smooth and enhance your features',
        price: 50,
        category: 'Camera Filters',
        type: ShopItemType.cameraFilter,
        levelRequired: 4,
        icon: Icons.face,
        preview: 'Softens skin and enhances features',
      ),
      ShopItem(
        id: 'grayscale',
        name: 'Grayscale Filter',
        description: 'Classic black and white look',
        price: 30,
        category: 'Camera Filters',
        type: ShopItemType.cameraFilter,
        levelRequired: 2,
        icon: Icons.filter_b_and_w,
        preview: 'Vintage monochrome effect',
      ),
      ShopItem(
        id: 'warm',
        name: 'Warm Tone Filter',
        description: 'Cozy warm colors',
        price: 40,
        category: 'Camera Filters',
        type: ShopItemType.cameraFilter,
        levelRequired: 3,
        icon: Icons.wb_sunny,
        preview: 'Golden hour warmth',
      ),
      ShopItem(
        id: 'colorful_eyes',
        name: 'Colorful Eyes Filter',
        description: 'Make your eyes pop with color',
        price: 60,
        category: 'Camera Filters',
        type: ShopItemType.cameraFilter,
        levelRequired: 7,
        icon: Icons.visibility,
        preview: 'Enhanced eye colors',
      ),
      ShopItem(
        id: 'vintage',
        name: 'Vintage Filter',
        description: 'Classic retro film look',
        price: 45,
        category: 'Camera Filters',
        type: ShopItemType.cameraFilter,
        levelRequired: 5,
        icon: Icons.camera_alt,
        preview: 'Retro film aesthetic',
      ),
      ShopItem(
        id: 'cool',
        name: 'Cool Tone Filter',
        description: 'Fresh cool blue tones',
        price: 35,
        category: 'Camera Filters',
        type: ShopItemType.cameraFilter,
        levelRequired: 4,
        icon: Icons.ac_unit,
        preview: 'Cool blue atmosphere',
      ),

      // General Items
      ShopItem(
        id: 'hint_pack_small',
        name: 'Hint Pack (5)',
        description: 'Get 5 helpful hints for challenging levels',
        price: 100,
        icon: Icons.lightbulb,
        category: 'Hints',
        type: ShopItemType.general,
        levelRequired: 2,
      ),
      ShopItem(
        id: 'hint_pack_large',
        name: 'Hint Pack (15)',
        description: 'Get 15 helpful hints for challenging levels',
        price: 250,
        icon: Icons.lightbulb,
        category: 'Hints',
        type: ShopItemType.general,
        levelRequired: 8,
      ),
      ShopItem(
        id: 'time_boost',
        name: 'Time Boost',
        description: 'Get extra time for your next game',
        price: 50,
        icon: Icons.timer,
        category: 'Boosters',
        type: ShopItemType.general,
        levelRequired: 3,
      ),
      ShopItem(
        id: 'score_multiplier',
        name: 'Score Multiplier',
        description: 'Double your score for the next game',
        price: 150,
        icon: Icons.star,
        category: 'Boosters',
        type: ShopItemType.general,
        levelRequired: 10,
      ),
    ];
  }
  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      final purchasedItems = await _authService.getPurchasedItems();
      if (mounted) {
        setState(() {
          _userData = userData;
          _purchasedItems = purchasedItems;
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
                  _isLoading ? '...' : '${_userData?['stars'] ?? 5}',
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
            ..._items.map((item) => _buildShopItem(item)),
          ],
        ),
      ),
    );
  }  Widget _buildShopItem(ShopItem item) {
    final isOwned = _purchasedItems.contains(item.id) || item.price == 0; // Free items are automatically owned
    final userStars = _userData?['stars'] ?? 0;
    final userLevel = _userData?['userLevel'] ?? 1; // Get user level
    final canAfford = userStars >= item.price;
    final levelMet = userLevel >= item.levelRequired;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isOwned ? Border.all(color: Colors.green, width: 2) : 
                (!levelMet ? Border.all(color: Colors.grey, width: 2) : null),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: !levelMet ? 0.5 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row with icon, title, and price
            Row(
              children: [
                // Icon - different display based on item type
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isOwned 
                        ? Colors.green.withOpacity(0.2) 
                        : AppTheme.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildItemIcon(item, isOwned),
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
            ),            const SizedBox(height: 12),
            // Bottom row with category, level requirement, and buy button
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
                const SizedBox(width: 8),
                // Level requirement indicator
                if (item.levelRequired > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: levelMet ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: levelMet ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_outline,
                          size: 12,
                          color: levelMet ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Lv.${item.levelRequired}',
                          style: TextStyle(
                            fontSize: 10,
                            color: levelMet ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                _buildActionButton(item, isOwned, canAfford, levelMet),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }  void _purchaseItem(ShopItem item) {
    final userStars = _userData?['stars'] ?? 5;
    final userLevel = _userData?['userLevel'] ?? 1;
    
    if (userLevel < item.levelRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Level ${item.levelRequired} required to purchase this item!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
      // Handle free items - they don't need purchasing, just activate them
    if (item.price == 0) {
      switch (item.type) {
        case ShopItemType.cameraFilter:
          _toggleCameraFilter(item);
          return;
        case ShopItemType.profileEmoji:
          _setActiveProfileEmoji(item);
          return;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.name} is now available!'),
              backgroundColor: Colors.green,
            ),
          );
          return;
      }
    }
    
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
            children: [              Text('${item.description}\n'),
              if (item.type == ShopItemType.profileEmoji && item.emoji != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Preview: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(item.emoji!, style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
              if (item.type == ShopItemType.emojiPack && item.emoji != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text('Pack Preview: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(item.emoji!, style: TextStyle(fontSize: 24)),
                      Text(' + more!', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              if (item.type == ShopItemType.cameraFilter && item.preview != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.preview!)),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text('Price: ${item.price} stars'),
              Text('Your stars: $userStars'),
              Text('After purchase: ${userStars - item.price} stars'),
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
                  // Use the proper purchaseItem method that tracks ownership
                  bool purchaseSuccessful = await _authService.purchaseItem(item.id, item.price);
                  
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
                          content: Text('Purchase failed. You may not have enough stars or already own this item.'),
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

  Widget _buildItemIcon(ShopItem item, bool isOwned) {
    switch (item.type) {
      case ShopItemType.profileEmoji:
        return Center(
          child: Stack(
            children: [
              Text(
                item.emoji ?? '😀',
                style: const TextStyle(fontSize: 28),
              ),
              if (isOwned)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      case ShopItemType.cameraFilter:
        return Stack(
          children: [
            Icon(
              item.icon ?? Icons.camera_alt,
              color: isOwned ? Colors.green : AppTheme.accentOrange,
              size: 24,
            ),
            if (isOwned)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),          ],
        );
      case ShopItemType.emojiPack:
        return Center(
          child: Stack(
            children: [
              Text(
                item.emoji ?? '📦',
                style: const TextStyle(fontSize: 28),
              ),
              if (isOwned)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      case ShopItemType.general:
        return Icon(
          item.icon ?? Icons.shopping_bag,
          color: isOwned ? Colors.green : AppTheme.accentOrange,
          size: 24,
        );
    }
  }

  Widget _buildActionButton(ShopItem item, bool isOwned, bool canAfford, bool levelMet) {
    if (isOwned) {
      // Show different actions for owned items
      switch (item.type) {
        case ShopItemType.profileEmoji:
          return ElevatedButton(
            onPressed: () => _setActiveProfileEmoji(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Use',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );        case ShopItemType.cameraFilter:
          final isActiveFilter = _userData?['activeCameraFilter'] == item.id;
          return ElevatedButton(
            onPressed: () => _toggleCameraFilter(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActiveFilter ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              isActiveFilter ? 'Activated' : 'Apply',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );case ShopItemType.emojiPack:
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.green),
            ),
            child: const Text(
              'Owned',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        case ShopItemType.general:
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.green),
            ),
            child: const Text(
              'Owned',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
      }
    }    // Not owned - show buy button
    final canPurchase = canAfford && levelMet;
    String buttonText;
    if (!levelMet) {
      buttonText = 'Level ${item.levelRequired} required';
    } else if (item.price == 0) {
      // Free items show appropriate action text
      switch (item.type) {
        case ShopItemType.cameraFilter:
          buttonText = 'Apply';
          break;
        case ShopItemType.profileEmoji:
          buttonText = 'Use';
          break;
        default:
          buttonText = 'Get Free';
      }
    } else if (!canAfford) {
      buttonText = 'Not enough stars';
    } else {
      buttonText = 'Buy Now';
    }
    
    // For free items, user can always use them if level requirement is met
    final canInteract = item.price == 0 ? levelMet : canPurchase;
    
    return ElevatedButton(
      onPressed: canInteract ? () => _purchaseItem(item) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canInteract ? (item.price == 0 ? Colors.blue : AppTheme.accentOrange) : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _setActiveProfileEmoji(ShopItem item) async {
    try {
      await _authService.setActiveProfileEmoji(item.emoji!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile emoji changed to ${item.emoji}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to change profile emoji'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _toggleCameraFilter(ShopItem item) async {
    try {
      final currentActiveFilter = _userData?['activeCameraFilter'];
      
      // If this filter is already active, deactivate it (set to null)
      // If this filter is not active, activate it
      String? newFilterId = (currentActiveFilter == item.id) ? null : item.id;
      
      await _authService.setActiveCameraFilter(newFilterId);
      
      // Reload user data to update the UI
      await _loadUserData();
      
      if (mounted) {
        final message = (newFilterId == null) 
            ? '${item.name} deactivated'
            : '${item.name} activated!';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: (newFilterId == null) ? Colors.orange : Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to toggle filter'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final IconData? icon;
  final String category;
  final ShopItemType type;
  final String? emoji; // For emoji items
  final String? preview; // For filter preview
  final int levelRequired; // Required user level to purchase

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.icon,
    required this.category,
    required this.type,
    this.emoji,
    this.preview,
    this.levelRequired = 1, // Default to level 1
  });
}

enum ShopItemType {
  general,
  profileEmoji,
  emojiPack,
  cameraFilter,
}
