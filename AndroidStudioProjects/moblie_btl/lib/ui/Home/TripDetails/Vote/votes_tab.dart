// lib/ui/Home/TripDetails/Vote/votes_tab.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moblie_btl/repository/vote_repository.dart';
import 'package:moblie_btl/models/vote_option.dart';
import 'dart:math';

// Color constants
const Color mainBlueColor = Color(0xFF153359);
const Color accentGoldColor = Color(0xFFEAD8B1);

class VotesTabContent extends StatefulWidget {
  final String tripId;
  final Map<String, dynamic> members;

  const VotesTabContent({
    super.key,
    required this.tripId,
    required this.members,
  });

  @override
  State<VotesTabContent> createState() => _VotesTabContentState();
}

class _VotesTabContentState extends State<VotesTabContent> {
  final VoteRepository _repository = VoteRepository();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Cache for member names
  Map<String, String> _memberNames = {};

  @override
  void initState() {
    super.initState();
    _loadMemberNames();
  }

  Future<void> _loadMemberNames() async {
    try {
      final names = await _repository.getMemberNames(
        widget.members.keys.toList().cast<String>(),
      );
      if (mounted) {
        setState(() {
          _memberNames = names;
        });
      }
    } catch (e) {
      // Ignore errors, will use fallback names
    }
  }

  Future<void> _toggleVote(String optionId) async {
    if (_currentUserId == null) return;

    try {
      await _repository.toggleVote(widget.tripId, optionId, _currentUserId!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi bình chọn: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<VoteOption>>(
      stream: _repository.watchVoteOptions(widget.tripId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final options = snapshot.data ?? [];

        // Sort by vote count (descending)
        options.sort((a, b) => b.votes.length.compareTo(a.votes.length));

        if (options.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.how_to_vote_outlined,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có địa điểm nào để bình chọn.\nNhấn "Add Location" để thêm!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
          child: ListView.separated(
            itemCount: options.length,
            itemBuilder: (context, index) {
              return _buildVoteCard(options[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 15),
          ),
        );
      },
    );
  }

  Widget _buildVoteCard(VoteOption option) {
    final bool hasVoted =
        _currentUserId != null && option.votes.contains(_currentUserId);

    return GestureDetector(
      onTap: () => _toggleVote(option.id),
      onLongPress: () => _showOptionsDialog(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(15),
          border: hasVoted
              ? Border.all(color: accentGoldColor, width: 2)
              : null,
        ),
        child: Row(
          children: [
            _buildVoteProgress(option.votes.length, hasVoted),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (option.description != null &&
                      option.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.description!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (option.votes.isNotEmpty) _buildVoterAvatars(option.votes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(VoteOption option) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: mainBlueColor,
        title: Text(
          option.location,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${option.votes.length} bình chọn',
              style: const TextStyle(color: Colors.white70),
            ),
            if (option.votes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Người đã bình chọn:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: option.votes.map((userId) { // Sửa ở đây
                  final name = _memberNames[userId] ?? 'Người dùng';
                  return Chip(
                    backgroundColor: accentGoldColor.withOpacity(0.2),
                    label: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Colors.white70)),
          ),
          // Only show delete if user created this option
          if (option.createdBy == _currentUserId)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _repository.deleteVoteOption(widget.tripId, option.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
        ],
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

  Widget _buildVoterAvatars(List<String> voterIds) {
    // Use consistent colors based on user ID hash
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    return SizedBox(
      height: 24,
      child: Stack(
        children:
            List.generate(min(voterIds.length, 4), (index) {
              final userId = voterIds[index]; // Sửa ở đây
              final name = _memberNames[userId] ?? 'U';
              final colorIndex = userId.hashCode.abs() % colors.length;

              return Positioned(
                left: (18.0 * index),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: colors[colorIndex],
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            })..addAll(
              voterIds.length > 4
                  ? [
                      Positioned(
                        left: (18.0 * 4),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey.shade600,
                          child: Text(
                            '+${voterIds.length - 4}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ]
                  : [],
            ),
      ),
    );
  }
}
