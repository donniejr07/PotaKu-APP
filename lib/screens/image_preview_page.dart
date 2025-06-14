import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class ImagePreviewPage extends StatefulWidget {
  final File imageFile;
  const ImagePreviewPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  String? _predictionResult;
  String? _diseaseClass;
  bool _isLoading = false;
  Map<String, dynamic>? _diseaseInfo;

  @override
  void initState() {
    super.initState();
    _loadDiseaseInfo();
  }

  Future<void> _loadDiseaseInfo() async {
    final String jsonString = await rootBundle.loadString('assets/data/disease.json');
    setState(() {
      _diseaseInfo = json.decode(jsonString);
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _diseaseClass = null;
    });
    
    try {
      final uri = Uri.parse('https://potaku-api.up.railway.app/predict');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath('file', widget.imageFile.path),
      );
      
      // Add headers for better compatibility
      request.headers.addAll({
        'User-Agent': 'PotaKu-App/1.0',
        'Accept': 'application/json',
        'Connection': 'keep-alive',
      });
      
      var response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 60));
        },
      );
      
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = json.decode(respStr);
        double confidence = 0;
        if (data['confidence'] is int) {
          confidence = (data['confidence'] as int).toDouble();
        } else if (data['confidence'] is double) {
          confidence = data['confidence'];
        } else if (data['confidence'] is String) {
          confidence = double.tryParse(data['confidence']) ?? 0;
        }
        setState(() {
          if (confidence < 90) {
            _predictionResult = 'Gambar yang diinput bukan daun';
            _diseaseClass = null;
          } else {
            _predictionResult = '${data['class']} (Confidence: ${confidence.toStringAsFixed(2)}%)';
            _diseaseClass = data['class'];
          }
        });
      } else {
        setState(() {
          _predictionResult = 'Upload gagal: ${response.statusCode}';
        });
      }
      
    } catch (e) {
      setState(() {
        if (e is SocketException) {
          _predictionResult = 'Koneksi gagal. Periksa koneksi internet Anda.';
        } else if (e is TimeoutException) {
          _predictionResult = 'Request timeout. Coba lagi.';
        } else {
          _predictionResult = 'Terjadi error: $e';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDiseaseInfoCard() {
    if (_diseaseClass == null) {
      return const SizedBox.shrink();
    }

    if (_diseaseInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Debug: Print the received class and available keys
    // Debug: Check disease class and available keys
    
    Map<String, dynamic>? info;
    
    // Try multiple matching strategies
    String diseaseClassLower = _diseaseClass!.toLowerCase();
    
    // Strategy 1: Direct key match
    if (_diseaseInfo!.containsKey(_diseaseClass)) {
      info = _diseaseInfo![_diseaseClass];
      // Direct match found
    }
    // Strategy 2: Try with Potato___ prefix
    else if (_diseaseInfo!.containsKey('Potato___$_diseaseClass')) {
      info = _diseaseInfo!['Potato___$_diseaseClass'];
      // Match found with Potato___ prefix
    }
    // Strategy 3: Convert spaces to underscores and add Potato___ prefix
    else {
      String normalizedKey = 'Potato___${_diseaseClass!.replaceAll(' ', '_')}';
      if (_diseaseInfo!.containsKey(normalizedKey)) {
        info = _diseaseInfo![normalizedKey];
        // Match found with normalized key
      }
      // Strategy 4: Fuzzy matching
      else {
        for (String key in _diseaseInfo!.keys) {
          String keyLower = key.toLowerCase();
          // Remove Potato___ prefix for comparison
          String keyWithoutPrefix = keyLower.replaceAll('potato___', '').replaceAll('_', ' ');
          
          if (keyWithoutPrefix.contains(diseaseClassLower) || 
              diseaseClassLower.contains(keyWithoutPrefix) ||
              keyLower.contains(diseaseClassLower.replaceAll(' ', '_'))) {
            info = _diseaseInfo![key];
            // Fuzzy match found
            break;
          }
        }
      }
    }
    
    if (info == null) {
      // No match found for disease class
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Informasi untuk "$_diseaseClass" tidak ditemukan.\nKeys tersedia: ${_diseaseInfo!.keys.join(", ")}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    
    final brightness = Theme.of(context).colorScheme.brightness;
    final cardColor = brightness == Brightness.dark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = brightness == Brightness.dark ? Colors.white : Colors.black87;
    final subtitleColor = brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _diseaseClass!.toLowerCase().contains('healthy') ? Icons.check_circle : Icons.warning,
                  color: _diseaseClass!.toLowerCase().contains('healthy') ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info['name']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoSection(
              'Penyebab:',
              info['causes']!,
              Icons.search,
              textColor,
              subtitleColor,
            ),
            const SizedBox(height: 12),
            
            _buildInfoSection(
              'Gejala:',
              info['symptoms']!,
              Icons.visibility,
              textColor,
              subtitleColor,
            ),
            const SizedBox(height: 12),
            
            _buildInfoSection(
              _diseaseClass!.toLowerCase().contains('healthy') ? 'Perawatan:' : 'Penanganan:',
              info['treatment']!,
              _diseaseClass!.toLowerCase().contains('healthy') ? Icons.agriculture : Icons.medical_services,
              textColor,
              subtitleColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon, Color textColor, Color subtitleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: subtitleColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            title: const Text('Preview Gambar'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 350,
                      child: AspectRatio(
                        aspectRatio: 4/3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_predictionResult != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.green[50],
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700], size: 32),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                "Hasil: $_predictionResult",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Text(
                      "Belum ada hasil",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _uploadImage,
                    icon: const Icon(Icons.upload),
                    label: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tampilkan informasi penyakit jika ada hasil diagnosa
            _buildDiseaseInfoCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}