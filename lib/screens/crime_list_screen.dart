import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/providers/auth_provider.dart';
import 'package:crime_management_system/screens/crime_detail_screen.dart';
import 'package:crime_management_system/screens/case_verification_screen.dart';
import 'package:crime_management_system/widgets/crime_list_item.dart';
import 'package:crime_management_system/models/crime.dart';

class CrimeListScreen extends ConsumerStatefulWidget {
  const CrimeListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CrimeListScreen> createState() => _CrimeListScreenState();
}

class _CrimeListScreenState extends ConsumerState<CrimeListScreen> {
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
  
  List<Crime> _getFilteredCrimes(List<Crime> crimes) {
    final isOfficer = ref.read(authProvider.notifier).isOfficer;
    final user = ref.read(authProvider);
    
    // First filter by user role
    List<Crime> filteredCrimes = crimes;
    if (isOfficer && user != null) {
      if (_selectedFilter == 'assigned') {
        filteredCrimes = crimes.where((crime) => crime.assignedOfficer == user.id).toList();
      } else if (_selectedFilter == 'pending_verification') {
        filteredCrimes = crimes.where((crime) => crime.status == 'pending_verification').toList();
      } else if (_selectedFilter == 'insufficient_evidence') {
        filteredCrimes = crimes.where((crime) => crime.status == 'insufficient_evidence').toList();
      }
    } else {
      
      filteredCrimes = crimes.where((crime) => 
        crime.reportedBy == user?.id || !crime.isAnonymous
      ).toList();
    }
    
    
    if (_selectedFilter == 'open') {
      filteredCrimes = filteredCrimes.where((crime) => crime.status == 'open').toList();
    } else if (_selectedFilter == 'investigating') {
      filteredCrimes = filteredCrimes.where((crime) => crime.status == 'investigating').toList();
    } else if (_selectedFilter == 'closed') {
      filteredCrimes = filteredCrimes.where((crime) => crime.status == 'closed').toList();
    }
    
    
    if (_searchQuery.isNotEmpty) {
      filteredCrimes = filteredCrimes.where((crime) => 
        crime.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        crime.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        crime.location.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    
    filteredCrimes.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    return filteredCrimes;
  }

  @override
  Widget build(BuildContext context) {
    final crimes = ref.watch(crimeProvider);
    final isOfficer = ref.read(authProvider.notifier).isOfficer;
    final filteredCrimes = _getFilteredCrimes(crimes);
    final displayedCrimes = filteredCrimes.take(_displayedItemCount).toList();
    
    // Count pending verification cases
    final pendingVerificationCount = isOfficer 
        ? crimes.where((crime) => crime.status == 'pending_verification').length 
        : 0;
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search crimes...',
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
                      if (isOfficer) ...[
                        FilterChip(
                          label: Row(
                            children: [
                              const Text('Pending Verification'),
                              if (pendingVerificationCount > 0) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    pendingVerificationCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          selected: _selectedFilter == 'pending_verification',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = 'pending_verification';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      FilterChip(
                        label: const Text('Open'),
                        selected: _selectedFilter == 'open',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'open';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Investigating'),
                        selected: _selectedFilter == 'investigating',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'investigating';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Closed'),
                        selected: _selectedFilter == 'closed',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'closed';
                          });
                        },
                      ),
                      if (isOfficer) ...[
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Insufficient Evidence'),
                          selected: _selectedFilter == 'insufficient_evidence',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = 'insufficient_evidence';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Assigned to Me'),
                          selected: _selectedFilter == 'assigned',
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = 'assigned';
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: displayedCrimes.isEmpty
                ? const Center(
                    child: Text(
                      'No crimes found',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: displayedCrimes.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayedCrimes.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final crime = displayedCrimes[index];
                      return CrimeListItem(
                        crime: crime,
                        onTap: () {
                          
                          if (isOfficer && crime.status == 'pending_verification') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CaseVerificationScreen(crimeId: crime.id),
                              ),
                            );
                          } else {
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CrimeDetailScreen(crimeId: crime.id),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
