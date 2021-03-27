import 'package:flutter/material.dart';
import 'package:electura/provider_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:electura/screens/upload.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

final primaryColor = const Color(0xFF75A2EA);

enum AuthFormType { signIn, signUp }

class SignUpView extends StatefulWidget {
  final AuthFormType authFormType;

  SignUpView({Key key, @required this.authFormType}) : super(key: key);

  @override
  _SignUpViewState createState() =>
      _SignUpViewState(authFormType: this.authFormType);
}

class _SignUpViewState extends State<SignUpView> {
  AuthFormType authFormType;

  _SignUpViewState({this.authFormType});

  final formKey = GlobalKey<FormState>();
  String _email, _password, _name;
  bool _obscureText = true, _checkBox = false;
  final _emailTextController = new TextEditingController();
  final _passwordTextController = new TextEditingController();
  final _nameTextController = new TextEditingController();

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void switchFormState(String state) {
    formKey.currentState.reset();
    if (state == "signUp") {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }

  void submit() async {
    final form = formKey.currentState;
    form.save();

    try {
      final auth = Provider.of(context).auth;
      if (authFormType == AuthFormType.signIn) {
        String name = await auth.signInWithEmailAndPassword(_email, _password);

        print("Signed In with ID $name");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Upload(username: name)));
      } else {
        String uid =
            await auth.createUserWithEmailAndPassword(_email, _password, _name);
        print("Signed up with New ID $uid");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Upload(username: _name)));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: Colors.lightGreen[200],
        height: _height,
        width: _width,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SizedBox(height: _height * 0.05),
              buildHeaderText(),
              SizedBox(height: _height * 0.05),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: buildInputs() + buildButtons(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  AutoSizeText buildHeaderText() {
    String _headerText;
    if (authFormType == AuthFormType.signUp) {
      _headerText = "Create New Account";
    } else {
      _headerText = "Sign In";
    }
    return AutoSizeText(
      _headerText,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 35,
        color: Colors.white,
      ),
    );
  }

  Widget _togglebuttons() {
    return IconButton(
      icon: _obscureText ? Icon(MdiIcons.eyeOff) : Icon(MdiIcons.eye),
      onPressed: () => _toggle(),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];
    if (_checkBox) {
      _emailTextController.text = _email;
      _passwordTextController.text = _password;
    } else {
      _emailTextController.text = "";
      _passwordTextController.text = "";
    }
    _nameTextController.text = "";
    if (authFormType == AuthFormType.signUp){
       _emailTextController.text = "";
      _passwordTextController.text = "";
    }
    // if were in the sign up state add name
    if (authFormType == AuthFormType.signUp) {
      textFields.add(
        TextFormField(
          controller: _nameTextController,
          style: TextStyle(fontSize: 22.0),
          decoration: buildSignUpInputDecoration("Name"),
          onSaved: (value) => _name = value,
        ),
      );
      textFields.add(SizedBox(height: 20));
    }

    // add email & password
    textFields.add(
      TextFormField(
        controller: _emailTextController,
        style: TextStyle(fontSize: 22.0),
        decoration: buildSignUpInputDecoration("Email"),
        onSaved: (value) => _email = value,
      ),
    );
    textFields.add(SizedBox(height: 20));
    textFields.add(
      Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width - 90,
          child: TextFormField(
            controller: _passwordTextController,
            style: TextStyle(fontSize: 22.0),
            decoration: buildSignUpInputDecoration("Password"),
            obscureText: _obscureText,
            onSaved: (value) => _password = value,
          ),
        ),
        _togglebuttons(),
      ]),
    );
    textFields.add(SizedBox(height: 20));

    return textFields;
  }

  InputDecoration buildSignUpInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 0.0)),
      contentPadding:
          const EdgeInsets.only(left: 14.0, bottom: 10.0, top: 10.0),
    );
  }

  List<Widget> buildButtons() {
    String _switchButtonText, _newFormState, _submitButtonText;

    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = "Create New Account";
      _newFormState = "signUp";
      _submitButtonText = "Sign In";
      //_keepSignedIn ="Keep Me Signed In";
    } else {
      _switchButtonText = "Have an Account? Sign In";
      _newFormState = "signIn";
      _submitButtonText = "Sign Up";
    }

    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: RaisedButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.white,
          textColor: primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _submitButtonText,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          onPressed: submit,
        ),
      ),
      FlatButton(
        child: Text(
          _switchButtonText,
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          switchFormState(_newFormState);
        },
      ),
      if (authFormType == AuthFormType.signIn)
        Row(children: <Widget>[
          IconButton(
            color: Colors.red,
            icon: _checkBox
                ? Icon(Icons.check_box)
                : Icon(Icons.check_box_outline_blank_outlined),
            onPressed: () {
              setState(() {
                _checkBox = !_checkBox;
                if (_checkBox) {
                  _emailTextController.text = _email;
                  _passwordTextController.text = _password;
                } else {
                  _emailTextController.text = "";
                  _passwordTextController.text = "";
                }
              });
            },
          ),
          Text(
            "  Keep me signed in ",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          )
        ])
    ];
  }
}
