import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crime_management_system/providers/crime_provider.dart';
import 'package:crime_management_system/models/crime.dart';
import 'package:fl_chart/fl_chart.dart';

class CrimeMapScreen extends ConsumerStatefulWidget {
  const CrimeMapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CrimeMapScreen> createState() => _CrimeMapScreenState();
}

class _CrimeMapScreenState extends ConsumerState<CrimeMapScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  List<Crime> _getFilteredCrimes(List<Crime> crimes) {
    if (_selectedFilter == 'all') {
      return crimes;
    } else {
      return crimes.where((crime) => crime.type == _selectedFilter).toList();
    }
  }
  
  Map<String, int> _getCrimeTypeCount(List<Crime> crimes) {
    final Map<String, int> counts = {};
    
    for (final crime in crimes) {
      counts[crime.type] = (counts[crime.type] ?? 0) + 1;
    }
    
    return counts;
  }
  
  Map<String, int> _getCrimeStatusCount(List<Crime> crimes) {
    final Map<String, int> counts = {
      'open': 0,
      'investigating': 0,
      'closed': 0,
    };
    
    for (final crime in crimes) {
      counts[crime.status] = (counts[crime.status] ?? 0) + 1;
    }
    
    return counts;
  }
  
  List<PieChartSectionData> _getCrimeTypeSections(Map<String, int> counts) {
    final List<PieChartSectionData> sections = [];
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
    ];
    
    int i = 0;
    counts.forEach((type, count) {
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: count.toDouble(),
          title: '$type\n$count',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      i++;
    });
    
    return sections;
  }
  
  List<PieChartSectionData> _getCrimeStatusSections(Map<String, int> counts) {
    return [
      PieChartSectionData(
        color: Colors.red,
        value: counts['open']!.toDouble(),
        title: 'Open\n${counts['open']}',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: counts['investigating']!.toDouble(),
        title: 'Investigating\n${counts['investigating']}',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: counts['closed']!.toDouble(),
        title: 'Closed\n${counts['closed']}',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final crimes = ref.watch(crimeProvider);
    final filteredCrimes = _getFilteredCrimes(crimes);
    final crimeTypeCount = _getCrimeTypeCount(crimes);
    final crimeStatusCount = _getCrimeStatusCount(filteredCrimes);
    
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Crime Heatmap & Analytics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Heatmap'),
                    Tab(text: 'Charts'),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Types'),
                        selected: _selectedFilter == 'all',
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                        },
                      ),
                      ...crimeTypeCount.keys.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FilterChip(
                            label: Text(type),
                            selected: _selectedFilter == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = type;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Heatmap Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/heatmap_placeholder.png',
                        width: 300,
                        height: 300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Crime Heatmap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Showing ${filteredCrimes.length} crimes',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Note: This is a placeholder for the heatmap visualization.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Charts Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Crime Types Distribution',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: _getCrimeTypeSections(crimeTypeCount),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Case Status Distribution',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 300,
                                child: PieChart(
                                  PieChartData(
                                    sections: _getCrimeStatusSections(crimeStatusCount),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
