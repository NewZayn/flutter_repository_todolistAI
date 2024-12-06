import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import '../service/audiorecorderservice.dart';
import 'package:wave/config.dart';

class AudioRecorderScreen extends StatefulWidget {
  final int userId;

  const AudioRecorderScreen({super.key, required this.userId});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  String? _recordingPath;
  bool _isUploading = false;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _startRecording() async {
    try {
      await _audioService.startRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      _handleError("Erro ao iniciar a gravação: $e");
    }
  }

  void _stopRecording() async {
    try {
      final path = await _audioService.stopRecording();
      if (path != null) {
        setState(() {
          _recordingPath = path;
          _isRecording = false;
        });
      }
    } catch (e) {
      _handleError("Erro ao parar a gravação: $e");
    }
  }

  void _uploadRecording() async {
    if (_recordingPath == null) {
      _handleError("Nenhum arquivo para enviar.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final apiUrl =
          "https://microservices-to-do-list-plr6.onrender.com/api/${widget.userId}/task/speech/recognize";
      final response =
          await _audioService.sendAudioToApi(_recordingPath!, apiUrl);
      _showMessage("Áudio enviado com sucesso: $response");
    } catch (e) {
      _handleError("Erro ao enviar áudio: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gravador de Áudio')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isRecording
                  ? WaveWidget(
                      size: const Size(300, 100),
                      config: CustomConfig(
                        gradients: [
                          [Colors.blue, Colors.lightBlue.shade200],
                          [Colors.lightBlue.shade200, Colors.blueAccent],
                        ],
                        durations: [3500, 1940],
                        heightPercentages: [0.20, 0.23],
                        blur: MaskFilter.blur(BlurStyle.solid, 10),
                      ),
                    )
                  : const Icon(Icons.mic, size: 120, color: Colors.blue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: _recordingPath != null
                      ? () => setState(() => _recordingPath = null)
                      : null,
                  icon: Icon(Icons.delete,
                      size: 36,
                      color: _recordingPath != null ? Colors.red : Colors.grey),
                  tooltip: "Excluir Gravação",
                ),
                IconButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 48,
                    color: Colors.blue,
                  ),
                  tooltip: _isRecording ? "Parar Gravação" : "Iniciar Gravação",
                ),
                IconButton(
                  onPressed: _isUploading ? null : _uploadRecording,
                  icon: _isUploading
                      ? const CircularProgressIndicator(color: Colors.blue)
                      : const Icon(Icons.check_circle,
                          size: 36, color: Colors.green),
                  tooltip: "Salvar Gravação",
                ),
              ],
            ),
          ),
          if (_recordingPath != null)
            Text(
              'Gravação salva em: ${_recordingPath!.split('/').last}',
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
