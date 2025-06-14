import 'package:flutter/material.dart';

class InfoCatalogPage extends StatefulWidget {
  const InfoCatalogPage({super.key});

  @override
  State<InfoCatalogPage> createState() => _InfoCatalogPageState();
}

class _InfoCatalogPageState extends State<InfoCatalogPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToDetail(BuildContext context, String title, String description, List<String> imagePaths) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CatalogDetailPage(
          title: title,
          description: description,
          imagePaths: imagePaths,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogItems = [
      {
        'title': 'Healthy Potato',
        'subtitle': 'Ciri-ciri kentang sehat dan bebas penyakit.',
        'description': 'Kentang sehat adalah kentang yang tumbuh tanpa gejala penyakit, memiliki kulit mulus, warna cerah, dan tidak terdapat bercak atau busuk.',
        'imagePaths': ['assets/images/healthy.jpg'],
        'color': Colors.green,
        'icon': Icons.eco,
      },
      {
        'title': 'Early Blight',
        'subtitle': 'Penyakit bercak daun awal pada kentang.',
        'description': 'Early blight adalah penyakit yang disebabkan oleh jamur Alternaria solani. Gejalanya berupa bercak coklat kehitaman pada daun dengan lingkaran konsentris.',
        'imagePaths': ['assets/images/early.jpg'],
        'color': Colors.orange,
        'icon': Icons.warning,
      },
      {
        'title': 'Late Blight',
        'subtitle': 'Penyakit busuk daun dan umbi kentang.',
        'description': 'Late blight disebabkan oleh jamur Phytophthora infestans. Gejalanya berupa bercak coklat gelap pada daun, batang, dan umbi yang cepat meluas.',
        'imagePaths': ['assets/images/late.jpg'],
        'color': Colors.red,
        'icon': Icons.dangerous,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.library_books,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Katalog Informasi",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pelajari berbagai kondisi daun kentang",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            ...catalogItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return SlideTransition(
                position: _slideAnimations[index],
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: _CatalogCard(
                      title: item['title'] as String,
                      subtitle: item['subtitle'] as String,
                      color: item['color'] as Color,
                      icon: item['icon'] as IconData,
                      onTap: () => _navigateToDetail(
                        context,
                        item['title'] as String,
                        item['description'] as String,
                        item['imagePaths'] as List<String>,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _CatalogCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CatalogCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_CatalogCard> createState() => _CatalogCardState();
}

class _CatalogCardState extends State<_CatalogCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).colorScheme.brightness;
    final titleColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    final subtitleColor = brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    
    return GestureDetector(
      onTapDown: (_) {
        _hoverController.forward();
        setState(() => _isHovered = true);
      },
      onTapUp: (_) {
        _hoverController.reverse();
        setState(() => _isHovered = false);
        widget.onTap();
      },
      onTapCancel: () {
        _hoverController.reverse();
        setState(() => _isHovered = false);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isHovered ? 0.3 : 0.15),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: Offset(0, _isHovered ? 8 : 4),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).cardColor,
                        widget.color.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: widget.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: widget.color,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CatalogDetailPage extends StatelessWidget {
  final String title;
  final String description;
  final List<String> imagePaths;

  const CatalogDetailPage({
    required this.title,
    required this.description,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).colorScheme.brightness;
    final titleColor = brightness == Brightness.dark ? Colors.white : Colors.black;
    final descColor = brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (imagePaths.isNotEmpty)
                    Image.asset(
                      imagePaths.first,
                      fit: BoxFit.cover,
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Deskripsi",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 16,
                              color: descColor,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}