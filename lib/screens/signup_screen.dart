/*
Author: Soh Wei Meng (swmeng@yes.my)
Date: 12 September 2019
Sparta App
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../utils/validators.dart';
import '../widgets/error_dialog.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _isLoading = false;
  var _agreedToTOS = false;
  var _showTOSError = false;
  bool _valid = false;
  final _passwordController = TextEditingController();

  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'firstName': '',
    'lastName': '',
    'phoneNumber': '',
  };

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Auth>(
        context,
        listen: false,
      ).signup(
        _authData['email'],
        _authData['password'],
        _authData['firstName'],
        _authData['lastName'],
        _authData['phoneNumber'],
      );
      Navigator.of(context).pop();
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => ErrorDialog(
          ctx,
          'Error!',
          e.toString(),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setAgreedToTOS(bool newValue) {
    setState(() {
      _agreedToTOS = newValue;
    });
  }

  void onPhoneNumberChanged(PhoneNumber phoneNumber) {
    setState(() {
      _authData['phoneNumber'] = phoneNumber.phoneNumber;
    });
  }

  void onInputChanged(bool value) {
    setState(() {
      _valid = value;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xff7fb9e5), const Color(0xff394496)],
                  stops: [0, 0.9]),
            ),
          ),
          Positioned(
            child: SingleChildScrollView(
              child: Column(children: [
                AppBar(
                  title: const Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: deviceSize.height * 0.01,
                    horizontal: deviceSize.width * 0.1,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.email),
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validator.validateEmail,
                          onSaved: (value) {
                            _authData['email'] = value;
                          },
                        ),
                        SizedBox(
                          height: deviceSize.height * 0.01,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  icon: Icon(Icons.account_circle),
                                  labelText: 'First Name',
                                ),
                                keyboardType: TextInputType.text,
                                validator: Validator.validateName,
                                onSaved: (value) {
                                  _authData['firstName'] = value;
                                },
                              ),
                            ),
                            SizedBox(
                              width: deviceSize.width * 0.1,
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                ),
                                keyboardType: TextInputType.text,
                                validator: Validator.validateName,
                                onSaved: (value) {
                                  _authData['lastName'] = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: deviceSize.height * 0.01,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          controller: _passwordController,
                          validator: Validator.validatePassword,
                          onSaved: (value) {
                            _authData['password'] = value;
                          },
                        ),
                        SizedBox(
                          height: deviceSize.height * 0.01,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock),
                            labelText: 'Confirm Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          },
                        ),
                        SizedBox(
                          height: deviceSize.height * 0.01,
                        ),
                        InternationalPhoneNumberInput(
                            onInputChanged: onPhoneNumberChanged,
                            onInputValidated: onInputChanged,
                            inputDecoration: InputDecoration(
                              hintText: 'Enter phone number',
                              errorText: _valid ? null : 'Invalid',
                            )),
                        SizedBox(
                          height: deviceSize.height * 0.02,
                        ),
                        _showTOSError
                            ? Container(
                                width: deviceSize.width * 0.8,
                                child: Text(
                                  'You need to agree to the terms and conditions.',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 10,
                                  style: TextStyle(
                                    color: Theme.of(context).errorColor,
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: _agreedToTOS,
                              onChanged: _setAgreedToTOS,
                            ),
                            GestureDetector(
                              onTap: () => _setAgreedToTOS(!_agreedToTOS),
                              child: Container(
                                width: deviceSize.width * 0.65,
                                child: const Text(
                                  'I agree to the Terms of Services and Privacy Policy',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 10,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: deviceSize.height * 0.02,
                        ),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ButtonTheme(
                                minWidth: deviceSize.width * 0.75,
                                child: FlatButton(
                                  child: const Text('Sign Up'),
                                  onPressed: () {
                                    if (!_agreedToTOS) {
                                      setState(() {
                                        _showTOSError = true;
                                      });

                                      return;
                                    }
                                    _showTOSError = false;
                                    _submit();
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 8.0),
                                  color: Color(0x7f7df6fe),
                                  textColor: Theme.of(context)
                                      .primaryTextTheme
                                      .button
                                      .color,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
