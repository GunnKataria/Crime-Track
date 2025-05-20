import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/evidence_provider.dart';
import 'package:crime_management_system/widgets/evidence_card.dart';

class EvidenceListScreen extends ConsumerStatefulWidget {
  const EvidenceListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EvidenceListScreen> createState() => _EvidenceListScreenState();
}

class _EvidenceListScreenState extends ConsumerState<EvidenceListScreen> {
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
    final evidences = ref.watch(evidenceProvider);
    
    // Filter evidences
    var filteredEvidences = evidences;
    
    if (_selectedFilter != 'all') {
      filteredEvidences = evidences.where((evidence) => evidence.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredEvidences = filteredEvidences.where((evidence) => 
        evidence.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        evidence.type.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Sort by collected date (newest first)
    filteredEvidences.sort((a, b) => b.collectedAt.compareTo(a.collectedAt));
    
    // Limit for infinite scrolling
    final displayedEvidences = filteredEvidences.take(_displayedItemCount).toList();
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search evidence...',
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
                        label: const Text('Collected'),
                        selected: _selectedFilter == 'collected',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'collected';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Analyzed'),
                        selected: _selectedFilter == 'analyzed',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'analyzed';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Stored'),
                        selected: _selectedFilter == 'stored',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'stored';
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
            child: displayedEvidences.isEmpty
                ? const Center(
                    child: Text(
                      'No evidence found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: displayedEvidences.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayedEvidences.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final evidence = displayedEvidences[index];
                      return EvidenceCard(
                        evidence: evidence,
                        onTap: () {
                          // Navigate to evidence detail screen
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add evidence screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
