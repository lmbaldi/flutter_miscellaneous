import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:app/utils/constants.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:app/model/usuario.dart';
import 'api_response.dart';

import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart';


class UploadApi {

  static Future<ApiResponse> upload(Usuario user, File imageFile) async {

    var instanceImagePng = jpegToPng(imageFile);

    instanceImagePng.then((img) async {
      var stream = new ByteStream(DelegatingStream.typed(img.openRead()));
      var length = await img.length();
      String baseName = path.basename(img.path);
      var uri = Uri.parse( baseURL + "usuario/foto");
      var multipartRequest = new MultipartRequest('POST', uri);
      multipartRequest.headers['token'] = user.usuarioToken;
      multipartRequest.fields['usuario_id'] = user.usuarioId;

      var file = new MultipartFile('foto', stream, length, filename: baseName);
      multipartRequest.files.add(file);

      try {
        final streamedResponse = await multipartRequest.send();

        final response = await Response.fromStream(streamedResponse).timeout(
          Duration(seconds: 120),
          onTimeout: _onTimeOut,
        );

        if (response.body == null || response.body.isEmpty) {
          return ApiResponse.error(msg: "Não foi possível salvar a foto");
        }

        return ApiResponse.ok();
      } catch (error) {
        return ApiResponse.error(msg: "Não foi possível fazer o upload");
      }
    });
  }

  static FutureOr<Response> _onTimeOut() {
    throw SocketException("Não foi possível se comunicar com o servidor.");
  }

  static jpegToPng(File imageFile) async {
    //diretorio temporario
    final tempDir = await getTemporaryDirectory();

    // lê uma imagem jpeg image de um arquivo
    Image image = decodeImage(imageFile.readAsBytesSync());

    Image thumbnail = copyResize(image, width: 400, height: 400);

    // salva o thumbnail como um PNG.
    File compressedImage = new File('${tempDir.path}/user.png')
      ..writeAsBytesSync(encodePng(thumbnail));

    return compressedImage;
  }

}
