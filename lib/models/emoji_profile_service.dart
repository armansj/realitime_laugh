import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmojiProfileService {
  static final EmojiProfileService _instance = EmojiProfileService._internal();
  factory EmojiProfileService() => _instance;
  EmojiProfileService._internal();
  // Default emojis available to all users (20 emojis)
  static const List<String> defaultEmojis = [
    '😂', '😄', '😆', '😊', '🙂', '😉', '😎', '🤓', '🤗', '🤪',
    '😋', '😜', '🤔', '🤨', '😐', '😑', '🙄', '😬', '😏', '😌'
  ];

  // Premium emojis that need to be purchased
  static const List<String> premiumEmojis = [
    // Face emojis
    '🤩', '🥳', '😇', '🤠', '🤡', '🥸', '😴', '🤤', '🤭', '🤫',
    '😔', '😪', '🤒', '🤕', '🤢', '🤮', '🤧', '🥵', '🥶', '🥴',
    '😵', '🤯', '😈', '👿', '👹', '👺', '🤖', '👽', '👻', '💀',
    
    // Cat emojis
    '😺', '😸', '😹', '😻', '😼', '😽', '🙀', '😿', '😾',
    
    // Animal emojis
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
    '🦁', '🐮', '🐷', '🐸', '🐵', '🙈', '🙉', '🙊', '🐒', '🦍',
    
    // Nature emojis
    '💐', '🌸', '💮', '🏵️', '🌹', '🥀', '🌺', '🌻', '🌼', '🌷',
    '🌱', '🪴', '🌲', '🌳', '🌴', '🌵', '🍄', '🌰',
    
    // Food emojis
    '🍞', '🥖', '🥨', '🥯', '🥞', '🧇', '🧀', '🍖', '🍗', '🥩',
    '🥓', '🍔', '🍟', '🍕', '🌭', '🥪', '🌮', '🌯', '🥙', '🧆'
  ];

  // All available emoji options for profile pictures
  static const List<String> availableEmojis = [
    ...defaultEmojis,
    ...premiumEmojis,
  ];

  // Get the current emoji profile picture
  Future<String> getEmojiProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('emoji_profile') ?? '😂'; // Default to laugh emoji
  }

  // Set emoji profile picture
  Future<void> setEmojiProfile(String emoji) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emoji_profile', emoji);
  }

  // Check if emoji exists in available list
  bool isValidEmoji(String emoji) {
    return availableEmojis.contains(emoji);
  }

  // Check if emoji is premium (requires purchase)
  bool isPremiumEmoji(String emoji) {
    return premiumEmojis.contains(emoji);
  }

  // Check if emoji is default (free for all users)
  bool isDefaultEmoji(String emoji) {
    return defaultEmojis.contains(emoji);
  }

  // Get emojis available to user based on their purchases
  List<String> getAvailableEmojis(List<String> purchasedItems) {
    List<String> available = List.from(defaultEmojis);
    
    // Define the mapping of shop items to emoji packs
    final Map<String, List<String>> emojiPacks = {
      'emoji_pack_faces': ['🤩', '🥳', '😇', '🤠', '🤡', '🥸', '😴', '🤤'],
      'emoji_pack_animals': ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'],
      'emoji_pack_cats': ['😺', '😸', '😹', '😻', '😼', '😽', '🙀', '😿'],
      'emoji_pack_nature': ['💐', '🌸', '💮', '🏵️', '🌹', '🥀', '🌺', '🌻'],
      'emoji_pack_food': ['🍞', '🥖', '🥨', '🥯', '🥞', '🧇', '🧀', '🍖'],
      'emoji_pack_special': ['😈', '👿', '👹', '👺', '🤖', '👽', '👻', '💀'],
    };
    
    // Add purchased emoji packs
    for (String itemId in purchasedItems) {
      if (emojiPacks.containsKey(itemId)) {
        available.addAll(emojiPacks[itemId]!);
      }
    }
    
    return available;
  }

  // Show emoji selection dialog
  Future<String?> showEmojiSelectionDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Text('😄'),
              SizedBox(width: 8),
              Text('Choose Your Profile'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: availableEmojis.length,
              itemBuilder: (context, index) {
                final emoji = availableEmojis[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(emoji);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Get random emoji (for fun features)
  String getRandomEmoji() {
    final random = DateTime.now().millisecondsSinceEpoch % availableEmojis.length;
    return availableEmojis[random];
  }

  // Get emojis by category
  List<String> getFaceEmojis() {
    return availableEmojis.where((emoji) => 
      ['😂', '😄', '😆', '😊', '🙂', '😉', '😎', '🤓', '🤗', '🤪',
       '😋', '😜', '🤩', '🥳', '😇', '🤠', '🤡', '🥸', '😴', '🤤'].contains(emoji)
    ).toList();
  }

  List<String> getAnimalEmojis() {
    return availableEmojis.where((emoji) => 
      ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
       '🦁', '🐮', '🐷', '🐸', '🐵', '🙈', '🙉', '🙊'].contains(emoji)
    ).toList();
  }

  List<String> getFoodEmojis() {
    return availableEmojis.where((emoji) => 
      ['🍞', '🥖', '🥨', '🥯', '🥞', '🧇', '🧀', '🍖', '🍗', '🥩',
       '🥓', '🍔', '🍟', '🍕', '🌭', '🥪', '🌮', '🌯'].contains(emoji)
    ).toList();
  }

  // Convert emoji to unicode string for Firestore storage
  String emojiToUnicode(String emoji) {
    if (emoji.isEmpty) return '';
    
    final runes = emoji.runes.toList();
    if (runes.isEmpty) return '';
    
    // Convert first rune to unicode hex format
    return '&#x${runes.first.toRadixString(16).toUpperCase()};';
  }

  // Convert unicode string back to emoji for display
  String unicodeToEmoji(String unicode) {
    if (unicode.isEmpty || !unicode.startsWith('&#x') || !unicode.endsWith(';')) {
      // If it's not in unicode format, assume it's already an emoji
      return unicode.isEmpty ? '😂' : unicode;
    }
    
    try {
      // Extract hex part: &#x1F642; -> 1F642
      final hexString = unicode.substring(3, unicode.length - 1);
      final codePoint = int.parse(hexString, radix: 16);
      return String.fromCharCode(codePoint);
    } catch (e) {
      // Return default emoji if conversion fails
      return '😂';
    }
  }
}
