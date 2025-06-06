import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:i/view_model/tasks/task_view_model.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:i/service/audiorecorderservice.dart';
import 'package:provider/provider.dart';
import 'package:i/service/user_provider.dart';

class SpeakPage extends StatefulWidget {
  const SpeakPage({super.key});

  @override
  State<SpeakPage> createState() => _SpeakPageState();
}

class _SpeakPageState extends State<SpeakPage> {
  late AudioRecorder _audioRecorder;
  late TaskViewModel _taskService;
  bool _isRecording = false;
  String? _audioPath;
  bool _isUploading = false;
  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _taskService = Provider.of<TaskViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de microfone negada.')),
        );
        print("Permissão de microfone negada!");
        return;
      }

      final directory = await getTemporaryDirectory();
      final filePath = p.join(
        directory.path,
        'audio_${DateTime.now().millisecondsSinceEpoch}.wav',
      );
      print("🎙️ Iniciando gravação para: $filePath");

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000, // 16kHz é padrão para speech recognition
        bitRate: 128000, // Bitrate adequado
        numChannels: 1, // Mono
        autoGain: true, // Ajuste automático de ganho
        echoCancel: true, // Cancelamento de eco
        noiseSuppress: true, // Supressão de ruído
      );

      await _audioRecorder.start(config, path: filePath);

      setState(() {
        _isRecording = true;
        _audioPath = filePath;
      });
      print("✅ Gravação iniciada com configuração otimizada para speech.");
    } catch (e) {
      print('❌ Erro ao iniciar gravação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao iniciar gravação: $e')),
      );
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<bool> _stopRecording() async {
    try {
      print('🛑 Parando gravação...');
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _audioPath = path;
      });

      if (path != null) {
        // Aguardar um pouco para o arquivo ser finalizado
        await Future.delayed(const Duration(milliseconds: 1000));

        final file = File(path);
        final fileSize = await file.length();
        final fileExists = await file.exists();

        print("🎙️ Gravação parada. Áudio salvo em: $path");
        print("📏 Tamanho: $fileSize bytes");
        print("📁 Arquivo existe: $fileExists");

        // Verificar duração mínima (pelo menos 1 segundo de áudio)
        if (fileSize < 44100) {
          // Aproximadamente 1 segundo em 16kHz mono
          print(
              "⚠️ ATENÇÃO: Arquivo de áudio muito pequeno (menos de 1 segundo)!");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    '❌ Áudio muito curto. Grave por pelo menos 1 segundo.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return false;
        }

        if (fileSize == 0) {
          print("⚠️ ATENÇÃO: Arquivo de áudio está vazio!");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Erro: Arquivo de áudio vazio'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ Áudio gravado: ${(fileSize / 1024).toStringAsFixed(1)} KB'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        print("❌ Gravação parada, mas nenhum caminho de arquivo retornado.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erro ao salvar o áudio.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      print('❌ Erro ao parar gravação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao parar gravação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isRecording = false;
      });
      return false;
    }
  }

  Future<void> _sendAudio() async {
    if (_audioPath == null || _isUploading) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('❌ Nenhum áudio disponível ou envio em progresso.')),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;
      final token = userProvider.token;
      final baseUrl = 'https://aiproject-todolist-huq1.onrender.com/api';

      print('🚀 Iniciando envio do áudio...');
      print('👤 User ID: $userId');
      print('🌐 Base URL: $baseUrl');

      final audioFile = File(_audioPath!);

      // Verificar arquivo novamente antes do envio
      if (!await audioFile.exists()) {
        throw Exception('Arquivo não encontrado no momento do envio');
      }

      final fileSize = await audioFile.length();
      if (fileSize == 0) {
        throw Exception('Arquivo está vazio no momento do envio');
      }

      print(
          '📤 Enviando arquivo de ${(fileSize / 1024).toStringAsFixed(1)} KB...');

      final success = await AudioRecordService()
          .uploadAudioFile(audioFile, baseUrl, token, userId);

      if (success) {
        print('✅ Upload bem-sucedido! Recarregando tasks...');

        // Recarregar tasks
        await _taskService.loadTasks(userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Áudio processado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );

          // Limpar o áudio após sucesso
          setState(() {
            _audioPath = null;
          });
        }
      } else {
        throw Exception(
            'Falha no upload - verifique os logs para mais detalhes');
      }
    } catch (e) {
      print('❌ Erro completo ao enviar áudio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _stopRecordingAndSend() async {
    print('🔄 Iniciando processo de parar e enviar...');

    final recordingSuccess = await _stopRecording();

    if (recordingSuccess) {
      print('✅ Gravação bem-sucedida, enviando...');
      await _sendAudio();
    } else {
      print("❌ Não enviando áudio porque a gravação falhou");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Falha na gravação. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cores, ícones e texto baseados no estado
    Color micButtonBackgroundColor;
    Color micIconColor;
    IconData micIcon;
    String buttonText;

    if (_isUploading) {
      micButtonBackgroundColor = Colors.grey; // Fundo cinza durante o upload
      micIconColor = Colors.white; // Ícone branco
      micIcon = Icons.cloud_upload_outlined;
      buttonText = 'Processando...';
    } else if (_isRecording) {
      micButtonBackgroundColor = Theme.of(context)
          .colorScheme
          .error; // Fundo vermelho durante a gravação
      micIconColor = Colors.white; // Ícone branco
      micIcon = Icons.mic; // Ícone de microfone
      buttonText = 'Gravando... Solte para enviar';
    } else {
      // Estado ocioso: Botão verde com ícone preto
      micButtonBackgroundColor =
          const Color(0xFF50FA7B); // Verde (draculaGreen)
      micIconColor = const Color(
          0xFF282A36); // Preto/Cinza escuro (draculaCurrentLine) para o ícone
      micIcon = Icons.mic_none_outlined;
      buttonText = '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _isUploading
                ? 'Processando áudio...'
                : (_isRecording ? 'Ouvindo...' : 'Crie tasks falando!'),
            style: TextStyle(
                fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTapDown: (_) {
              if (!_isUploading) {
                _startRecording();
              }
            },
            onTapUp: (_) {
              if (_isRecording && !_isUploading) {
                _stopRecordingAndSend();
              }
            },
            onTapCancel: () {
              if (_isRecording && !_isUploading) {
                _stopRecordingAndSend();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: micButtonBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    micIcon,
                    color: micIconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  buttonText,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
