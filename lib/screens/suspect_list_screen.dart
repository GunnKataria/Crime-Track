import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/suspect_provider.dart';
import 'package:crime_management_system/widgets/suspect_card.dart';

class SuspectListScreen extends ConsumerStatefulWidget {
  const SuspectListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SuspectListScreen> createState() => _SuspectListScreenState();
}

class _SuspectListScreenState extends ConsumerState<SuspectListScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  int _displayedItemCount = 20;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }
  
  void _loadMoreItems() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _displayedItemCount += 10;
      });
      
      // Simulate loading delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final suspects = ref.watch(suspectProvider);
    
    // Filter suspects
    var filteredSuspects = suspects;
    
    if (_selectedFilter != 'all') {
      filteredSuspects = suspects.where((suspect) => suspect.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredSuspects = filteredSuspects.where((suspect) => 
        suspect.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        suspect.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Limit for infinite scrolling
    final displayedSuspects = filteredSuspects.take(_displayedItemCount).toList();
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search suspects...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedFilter == 'all',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Wanted'),
                        selected: _selectedFilter == 'wanted',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'wanted';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('In Custody'),
                        selected: _selectedFilter == 'in custody',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'in custody';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Cleared'),
                        selected: _selectedFilter == 'cleared',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'cleared';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: displayedSuspects.isEmpty
                ? const Center(
                    child: Text(
                      'No suspects found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: displayedSuspects.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayedSuspects.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final suspect = displayedSuspects[index];
                      return SuspectCard(
                        suspect: suspect,
                        onTap: () {
                          // Navigate to suspect detail screen
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add suspect screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
