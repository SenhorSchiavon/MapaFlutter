import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
class RecuperarPosicao extends StatefulWidget {
  const RecuperarPosicao({super.key});

  @override
  State<RecuperarPosicao> createState() => _RecuperarPosicaoState();
}

class _RecuperarPosicaoState extends State<RecuperarPosicao> {

  Completer<GoogleMapController> controller = Completer();
  late CameraPosition localCamera;

  Set<Marker> listaMarcadores ={};

  onMapCreated(GoogleMapController googleMapController){
    controller.complete(googleMapController);
  }



  localizarDispositivo() async{
    bool servicosAtivos;
    LocationPermission permissao;

    servicosAtivos = await Geolocator.isLocationServiceEnabled();
    if(!servicosAtivos){
      return Future.error("Serviços de localização desabilitadas");
    }
    permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        return Future.error("Permissão para erro, acesso negado.");
      }
    }
    if(permissao == LocationPermission.deniedForever){
      return Future.error("Permissão para acesso a localização negada");
    }
    Position posicao = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    criarMarcadores(posicao);
    setState(() {
      localCamera = CameraPosition(target: LatLng(posicao.latitude,posicao.longitude),
      zoom: 17);
    });
    mudarCamera(localCamera);
  }

  mudarCamera(CameraPosition localCamera)async{
    GoogleMapController googleMapController = await controller.future;
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(localCamera)
    );
  }

Future<Uint8List> getBytesFromAsset(String path, int width) async{
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
    targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))! .buffer.asUint8List();
}

  criarMarcadores(Position posicao)async{
    Set<Marker> marcadoresLocal = {};
    Marker marcador1 = Marker(markerId: MarkerId("Marcador 1"),
    position: LatLng(posicao.latitude, posicao.longitude),
    infoWindow: InfoWindow(
      title: "Entrada IDR"
    ));

    // Marker marcador2 = Marker(markerId: MarkerId("Marcador 1"),
    //     position: LatLng(-23.356037785881362, -51.16338334188537),
    //     infoWindow: InfoWindow(
    //         title: "Estamos aqui"
    //     ),
    //     icon: BitmapDescriptor.defaultMarkerWithHue(
    //     BitmapDescriptor.hueAzure,
    // ),
    //   onTap: (){
    //   print("Marcador Clicado");
    //   }
    // );
    //
    // // final iconePersonalizado = await BitmapDescriptor.fromAssetImage(
    // //     ImageConfiguration(
    // //       size: Size(100,100)),
    // //       'imagens/logo.png');
    //
    // final Uint8List iconePersonalizado = await getBytesFromAsset('imagens/logo.png', 100);
    // Marker marcador3 = Marker(markerId: MarkerId("Marcador 1"),
    //     position: LatLng(-23.3553691640305, -51.1629774677351 ),
    //     infoWindow: InfoWindow(
    //         title: "IDR-PARANÁ LONDRINA"
    //     ),
    //     icon: BitmapDescriptor.fromBytes(iconePersonalizado),
    //
    //     onTap: (){
    //       print("Marcador Clicado");
    //     }
    // );

    marcadoresLocal.add(marcador1);
    // marcadoresLocal.add(marcador2);
    // marcadoresLocal.add(marcador3);
    setState(() {
      listaMarcadores = marcadoresLocal;
    });
  }

  ouvirLocalizacao() async{
    var configuracaoLocalizacao = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );
     Geolocator.getPositionStream( locationSettings: configuracaoLocalizacao)
    .listen((Position position){
      setState(() {
        localCamera = CameraPosition(target: LatLng(position.longitude,position.latitude),zoom: 16);
        mudarCamera(localCamera);
        criarMarcadores(position);
      });
     });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //criarMarcadores();
    localizarDispositivo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mapas"),
      ),
      body: Container(
        child: GoogleMap(
          mapType: MapType.satellite,
          initialCameraPosition: localCamera,
          onMapCreated: onMapCreated,
          markers:  listaMarcadores,
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.account_circle),
      //   onPressed: mudarCamera,
      //   backgroundColor: Colors.red,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
