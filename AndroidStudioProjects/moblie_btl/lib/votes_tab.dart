// lib/ui/Home/TripDetails/Vote/votes_tab.dart
import 'package:flutter/material.dart';
import 'dart:math'; // Để sử dụng cho màu sắc ngẫu nhiên

// Giả định màu sắc từ các file khác
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

// --- 1. Dữ liệu mẫu ---
final List<Map<String, dynamic>> voteOptions = [
  {
    'id': 1,
    'location': 'Fushimi Inari Shrine',
    'imageUrl': 'https://example.com/fushimi_inari.jpg',
    'votes': ['Duy', 'Lộc', 'Quyên'],
  },
  {
    'id': 2,
    'location': 'Arashiyama Bamboo Grove',
    'imageUrl': 'https://example.com/arashiyama.jpg',
    'votes': ['Duy', 'Lộc'],
  },
  {
    'id': 3,
    'location': 'Kinkaku-ji Temple',
    'imageUrl': 'https://example.com/kinkaku_ji.jpg',
    'votes': ['Quyên'],
  },
  {
    'id': 4,
    'location': 'Tokyo Skytree',
    'imageUrl': 'https://example.com/tokyo_skytree.jpg',
    'votes': [],
  },
];

const String currentUser = 'Duy';

class VotesTabContent extends StatefulWidget {
  const VotesTabContent({super.key});

  @override
  State<VotesTabContent> createState() => _VotesTabContentState();
}

class _VotesTabContentState extends State<VotesTabContent> {
  void _toggleVote(int optionId) {
    setState(() {
      final option = voteOptions.firstWhere((opt) => opt['id'] == optionId);
      // *** SỬA LỖI 1: Ép kiểu an toàn ***
      // Lấy ra dưới dạng List<dynamic> trước
      final votesListDynamic = option['votes'] as List;
      // Sau đó chuyển đổi nó thành List<String>
      final votes = List<String>.from(votesListDynamic);

      if (votes.contains(currentUser)) {
        votes.remove(currentUser);
      } else {
        votes.add(currentUser);
      }

      // Gán lại danh sách đã thay đổi vào map
      option['votes'] = votes;

      voteOptions.sort(
        (a, b) =>
            (b['votes'] as List).length.compareTo((a['votes'] as List).length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    voteOptions.sort(
      (a, b) =>
          (b['votes'] as List).length.compareTo((a['votes'] as List).length),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: ListView.separated(
        itemCount: voteOptions.length,
        itemBuilder: (context, index) {
          return _buildVoteCard(voteOptions[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 15),
      ),
    );
  }

  Widget _buildVoteCard(Map<String, dynamic> option) {
    // *** SỬA LỖI 2: Ép kiểu an toàn (lặp lại) ***
    final votes = List<String>.from(option['votes'] as List);
    final bool hasVoted = votes.contains(currentUser);

    return GestureDetector(
      onTap: () => _toggleVote(option['id'] as int),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(15),
          border: hasVoted
              ? Border.all(color: accentGoldColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            _buildVoteProgress(votes.length, hasVoted),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option['location'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (votes.isNotEmpty) _buildVoterAvatars(votes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteProgress(int voteCount, bool hasVoted) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasVoted ? Icons.how_to_vote : Icons.how_to_vote_outlined,
          color: hasVoted ? accentGoldColor : Colors.white70,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          voteCount.toString(),
          style: TextStyle(
            color: hasVoted ? accentGoldColor : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVoterAvatars(List<String> voters) {
    final random = Random();
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];

    return SizedBox(
      height: 24,
      child: Stack(
        children: List.generate(min(voters.length, 4), (index) {
          return Positioned(
            left: (18.0 * index),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: colors[random.nextInt(colors.length)],
              child: Text(
                voters[index][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
