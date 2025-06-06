import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:async';

class AudioRecordService {
  Future<bool> uploadAudioFile(
      File audioFile, String url, String token, String userId) async {
    try {
      print('🔍 Verificando arquivo...');

      if (!await audioFile.exists()) {
        print('❌ Arquivo não existe');
        return false;
      }

      final fileSize = await audioFile.length();
      print('📏 Tamanho do arquivo: $fileSize bytes');

      if (fileSize == 0) {
        print('❌ Arquivo vazio');
        return false;
      }

      // Aguardar um pouco para garantir que o arquivo foi fechado corretamente
      await Future.delayed(const Duration(milliseconds: 500));

      final uri = Uri.parse('$url/$userId/task/speech/recognize');
      print('🌐 URL completa: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      print('🔑 Token: $token');
      print('👤 User ID: $userId');

      // Criar multipart file diretamente dos bytes
      final bytes = await audioFile.readAsBytes();
      print('📦 Bytes lidos: ${bytes.length}');

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'audio.wav',
        contentType: MediaType('audio', 'wav'),
      );

      request.files.add(multipartFile);

      print('📤 Enviando requisição...');
      print('📋 Headers: ${request.headers}');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout na requisição');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('📊 Status: ${response.statusCode}');
      print('📝 Response: ${response.body}');
      print('📋 Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Upload realizado com sucesso!');
        return true;
      } else {
        print('❌ Erro no servidor: ${response.statusCode}');
        print('❌ Corpo da resposta: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ Exceção durante upload: $e');
      print('📍 Stack trace: $stackTrace');
      return false;
    }
  }
}
