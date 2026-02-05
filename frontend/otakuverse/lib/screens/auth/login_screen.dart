import 'package:flutter/material.dart';
import 'package:otakuverse/controllers/auth_controller.dart';
import 'package:otakuverse/core/utils/helpers.dart';
import 'package:otakuverse/screens/home_screen.dart';
import 'package:otakuverse/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}