import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/witness_provider.dart';
import 'package:crime_management_system/widgets/witness_card.dart';

class WitnessListScreen extends ConsumerStatefulWidget {
  const WitnessListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WitnessListScreen> createState() => _WitnessListScreenState();
}

class _WitnessListScreenState extends ConsumerState<WitnessListScreen> {
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
    final witnesses = ref.watch(witnessProvider);
    
    // Filter witnesses
    var filteredWitnesses = witnesses;
    
    if (_selectedFilter != 'all') {
      filteredWitnesses = witnesses.where((witness) => witness.credibilityRating == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredWitnesses = filteredWitnesses.where((witness) => 
        witness.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        witness.statement.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Limit for infinite scrolling
    final displayedWitnesses = filteredWitnesses.take(_displayedItemCount).toList();
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search witnesses...',
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
                        label: const Text('High Credibility'),
                        selected: _selectedFilter == 'high',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'high';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Medium Credibility'),
                        selected: _selectedFilter == 'medium',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'medium';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Low Credibility'),
                        selected: _selectedFilter == 'low',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'low';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Anonymous'),
                        selected: _selectedFilter == 'anonymous',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'anonymous';
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
            child: displayedWitnesses.isEmpty
                ? const Center(
                    child: Text(
                      'No witnesses found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: displayedWitnesses.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayedWitnesses.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final witness = displayedWitnesses[index];
                      return WitnessCard(
                        witness: witness,
                        onTap: () {
                          // Navigate to witness detail screen
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add witness screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
