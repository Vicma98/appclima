import 'package:app_clima/widgets/weather_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LocationForm extends StatefulWidget {
  const LocationForm({super.key});
  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();
  String _status = '';
  double? _temperature;
  bool _usingGps = false;
  final WeatherService _weatherService = WeatherService();

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  // Valida rango y formato
  String? _coordValidator(String? value, bool isLat) {
    if (value == null || value.trim().isEmpty) return 'Campo requerido';
    final v = double.tryParse(value.replaceAll(',', '.'));
    if (v == null) return 'Formato numérico inválido';
    if (isLat) {
      if (v < -90 || v > 90) return 'Latitud debe estar entre -90 y 90';
    } else {
      if (v < -180 || v > 180) return 'Longitud debe estar entre -180 y 180';
    }
    return null;
  }

  Future<void> _getGpsAndFill() async {
    setState(() { _status = 'Obteniendo ubicación...'; });
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() {
        _status = 'Permiso denegado. Ingresa coordenadas manualmente.';
        _usingGps = false;
      });
      return;
    }

    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      setState(() {
        _status = 'Servicio de ubicación deshabilitado. Actívalo o ingresa manualmente.';
        _usingGps = false;
      });
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _latController.text = pos.latitude.toString();
    _lonController.text = pos.longitude.toString();
    setState(() {
      _status = 'Ubicación obtenida (GPS).';
      _usingGps = true;
    });
  }

  Future<void> _fetchTemperature() async {
    if (!_formKey.currentState!.validate()) return;

    // Verificar conectividad
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      setState(() {
        _temperature = 17.0; // valor por defecto
        _status = 'Sin conectividad. Se devuelve temperatura por defecto (17°C).';
      });
      return;
    }

    final lat = double.parse(_latController.text.replaceAll(',', '.'));
    final lon = double.parse(_lonController.text.replaceAll(',', '.'));

    setState(() {
      _status = 'Consultando API...';
      _temperature = null;
    });

    try {
      final temp = await _weatherService.fetchTemperature(lat, lon);
      setState(() {
        _temperature = temp;
        _status = 'Temperatura obtenida correctamente';
      });
    } catch (e) {
      // Si hay error en petición devolvemos 17 y avisamos
      setState(() {
        _temperature = 17.0;
        _status = 'Error conectando API. Se muestra 17°C por defecto.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _getGpsAndFill,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Usar GPS'),
                ),
                Text(_usingGps ? 'GPS activo' : 'GPS no usado'),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Latitud', hintText: 'e.g. 6.2447'),
              validator: (v) => _coordValidator(v, true),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lonController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Longitud', hintText: 'e.g. -75.5748'),
              validator: (v) => _coordValidator(v, false),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTemperature,
              child: const Text('Consultar Temperatura'),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        Text(_status, style: const TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 12),
        if (_temperature != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Temperatura: ${_temperature!.toStringAsFixed(1)} °C',
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
      ],
    );
  }
}
