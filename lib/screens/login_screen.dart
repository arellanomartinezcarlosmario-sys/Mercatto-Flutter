import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool hide = true;

  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) { _msg('Escribe tu correo y contraseña.'); return; }
    setState(() => loading = true);
    try {
      final result = await ApiService.post('/api/auth/login', {'email': email.text.trim(), 'password': password.text, 'recordarme': true});
      if (result is Map && result['accessToken'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', result['accessToken'].toString());
        await prefs.setString('userEmail', email.text.trim());
        if (mounted) Navigator.pop(context, true);
      } else { _msg(result is Map ? (result['mensaje'] ?? 'No se pudo iniciar sesión.').toString() : 'Respuesta inesperada del servidor.'); }
    } catch (e) { _msg('No fue posible iniciar sesión: ${e.toString().replaceFirst('Exception: ', '')}'); }
    finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> register() async {
    final name = TextEditingController();
    final confirm = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Crear cuenta'),
      content: Form(key: formKey, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nombre completo'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe tu nombre' : null),
        TextFormField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo electrónico'), validator: (v) => (v == null || !v.contains('@')) ? 'Correo no válido' : null),
        TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña'), validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null),
        TextFormField(controller: confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar contraseña'), validator: (v) => v != password.text ? 'Las contraseñas no coinciden' : null),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')), FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true); }, child: const Text('Registrarme'))],
    ));
    if (accepted != true) { name.dispose(); confirm.dispose(); return; }
    setState(() => loading = true);
    try {
      final result = await ApiService.post('/api/auth/registro', {'nombre': name.text.trim(), 'email': email.text.trim(), 'password': password.text, 'rol': 'COMPRADOR', 'recordarme': true});
      if (result is Map && result['accessToken'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', result['accessToken'].toString());
        await prefs.setString('userEmail', email.text.trim());
        if (mounted) Navigator.pop(context, true);
      } else { _msg(result is Map ? (result['mensaje'] ?? 'No se pudo completar el registro.').toString() : 'Cuenta creada. Ahora inicia sesión.'); }
    } catch (e) { _msg('No fue posible registrarse: ${e.toString().replaceFirst('Exception: ', '')}'); }
    finally { name.dispose(); confirm.dispose(); if (mounted) setState(() => loading = false); }
  }
  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mi cuenta')),
    body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Icon(Icons.storefront_rounded, color: Color(0xFFE53935), size: 68), const SizedBox(height: 12),
      const Text('Bienvenido a Mercatto', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), const Text('Inicia sesión para continuar comprando.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)), const SizedBox(height: 28),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder())), const SizedBox(height: 14),
      TextField(controller: password, obscureText: hide, decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(hide ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => hide = !hide)))), const SizedBox(height: 22),
      FilledButton(onPressed: loading ? null : login, style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)), child: loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Iniciar sesión')), const SizedBox(height: 8), TextButton(onPressed: loading ? null : register, child: const Text('¿No tienes cuenta? Regístrate')), 
    ])))));
}
