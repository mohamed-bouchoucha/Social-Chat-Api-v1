import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _response = 'Not tested yet';
  bool _isLoading = false;
  final Dio _dio = Dio();
  
  // Test different URLs
  final List<String> _urls = [
    'http://localhost:8080',
    'http://localhost:8080/health',
    'http://localhost:8080/api/test',
    'http://10.0.2.2:8080',           // For Android emulator
    'http://10.0.2.2:8080/health',
  ];

  Future<void> _testUrl(String url) async {
    setState(() {
      _isLoading = true;
      _response = 'Testing $url...';
    });

    try {
      final response = await _dio.get(
        url,
        options: Options(
          
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      setState(() {
        _response = '✅ $url\n'
                    'Status: ${response.statusCode}\n'
                    'Data: ${response.data}';
      });
    } on DioException catch (e) {
      setState(() {
        _response = '❌ $url\n';
        if (e.response != null) {
          _response += 'Status: ${e.response!.statusCode}\n';
          _response += 'Data: ${e.response!.data}';
        } else {
          _response += 'Error: ${e.message}\n';
          if (e.type == DioExceptionType.connectionError) {
            _response += '\nTroubleshooting:\n';
            _response += '1. Is Spring Boot running? (check terminal)\n';
            _response += '2. Try: http://10.0.2.2:8080 for Android emulator\n';
            _response += '3. Check firewall/antivirus settings';
          }
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAllUrls() async {
    for (final url in _urls) {
      await _testUrl(url);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _response = 'Testing login...';
    });

    try {
      final response = await _dio.post(
        'http://localhost:8080/api/auth/test-login',
        data: {
          'username': 'test',
          'password': 'test123',
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      setState(() {
        _response = '✅ Login Test\n'
                    'Status: ${response.statusCode}\n'
                    'Token: ${response.data['token']}';
      });
    } catch (e) {
      setState(() {
        _response = '❌ Login Test Failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test URLs (click to test):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // URL buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _urls.map((url) {
                return ElevatedButton(
                  onPressed: _isLoading ? null : () => _testUrl(url),
                  child: Text(url.split('/').last.isEmpty ? 'home' : url.split('/').last),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAllUrls,
              child: const Text('Test All URLs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: const Text('Test Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _response,
                      style: const TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}