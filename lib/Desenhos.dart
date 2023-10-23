import 'dart:async';


import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;

class Desenhos extends StatefulWidget {
  const Desenhos({super.key});

  @override
  State<Desenhos> createState() => _DesenhosState();
}

class _DesenhosState extends State<Desenhos> {

  Completer<GoogleMapController> controller = Completer();
  Set<Polygon> listaPoligonos = {};
  Set<Polyline> listaLinhas = {};

  desenharLinhas(){
    Set<Polyline> linhas={};
    Polyline linha1 = Polyline(
        polylineId: PolylineId("linha1"),
      color: Colors.red,
      width: 10,
      points: [
        LatLng(-23.354648956611964, -51.1626084061888),
        LatLng(-23.35482703386468, -51.1623557946712),
        LatLng(-23.354967838965077, -51.16244150215039),
      ],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.bevel,
    );
    linhas.add(linha1);
    setState(() {
      listaLinhas = linhas;
    });
  }

  desenharPoligonos(){
    Set<Polygon> poligonos = {};

    Polygon poligono1  = Polygon(
        fillColor: Color.fromRGBO(30, 60, 200, 0.5),
        strokeColor: Colors.blue,
        strokeWidth: 1,
        polygonId: PolygonId("poligono1"),
    points: [
      LatLng(-23.354648956611964, -51.1626084061888),
      LatLng(-23.35482703386468, -51.1623557946712),
      LatLng(-23.354967838965077, -51.16244150215039),
      LatLng(-23.35529500318027, -51.16199492107463),
      LatLng(-23.356385300947498, -51.16302293892591),
      LatLng(-23.355612098862746, -51.163902703495665),
      LatLng(-23.354622196623296, -51.162990752417265),
      LatLng(-23.354774868594607, -51.16277081127482),
      LatLng(-23.35464189624235, -51.162625971985904),

    ],
      consumeTapEvents: true,
      onTap: (){
          print("Poligono 1 clicado");
      }
    );
    poligonos.add(poligono1);

    setState(() {
      listaPoligonos = poligonos;
    });
  }


  onMapCreated(GoogleMapController googleMapController){
    controller.complete(googleMapController);
  }

  mudarCamera()async{
    GoogleMapController googleMapController = await controller.future;
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(-23.35408414696365, -51.16187364175645),
            zoom: 18))
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    desenharPoligonos();
    desenharLinhas();
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
          initialCameraPosition: CameraPosition(
            target: LatLng(-23.353733701845652, -51.16115037142859),
            zoom: 17,
            tilt: 50,
            //bearing: 50,
          ),
          onMapCreated: onMapCreated,
          polygons: listaPoligonos,
          polylines: listaLinhas,
        ),
      ),

    );
  }
}
