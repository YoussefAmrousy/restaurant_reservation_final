// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_reservation_final/Restaurant/restaurant_navigation_bar.dart';
import 'package:restaurant_reservation_final/Screens/register_screen.dart';
import 'package:restaurant_reservation_final/Admin/Screens/admin_navbar.dart';
import 'package:restaurant_reservation_final/Services/auth_service.dart';
import 'package:restaurant_reservation_final/Services/shared_preference_service.dart';
import 'package:restaurant_reservation_final/user/Screens/user_navigation_bar.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SharedPreferenceService sharedPreferenceService = SharedPreferenceService();

  final coolGrey = const Color.fromARGB(255, 169, 169, 169);
  String? restaurant;

  Future<String> getRestaurantNameFromLocalStorage() async {
    var restaurantNameStored =
        await sharedPreferenceService.getStringFromLocalStorage('restaurant');
    return restaurantNameStored!;
  }

  submit() async {
    final form = _formKey.currentState;
    AuthService authService = AuthService();
    if (form!.validate()) {
      form.save();
      User? user = await authService.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
          ),
        );
        return;
      }
      String? userRole = await authService.getUserRole(user.uid);
      userRole ??= 'user';
      if (userRole == 'admin') {
        _navigateToRoleSpecificScreen('admin');
      } else if (userRole == 'restaurant') {
        restaurant = await getRestaurantNameFromLocalStorage();
        await _navigateToRoleSpecificScreen('restaurant', restaurant);
      } else {
        // await restaurantProvider.fetchRestaurants();
        _navigateToRoleSpecificScreen('user');
      }
    }
  }

  Future<void> _navigateToRoleSpecificScreen(String role,
      [String? restaurant]) async {
    switch (role) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminNavigationBar()),
        );
        break;
      case 'restaurant':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => RestaurantNavigationBar(
                    restaurant: restaurant,
                  )),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserNavigationBar(selectedIndex: 0,)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    width: 320,
                    height: 60,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    height: 100,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () async {
                        await submit();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(coolGrey),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
                  ),
                );
              },
              child: const Text("Create an account"),
            ),
          ],
        ),
      ),
    );
  }
}
