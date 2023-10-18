// import 'package:flutter/material.dart';
// import 'package:masjid/models/LoginModel.dart';

// class LoginWidget extends StatefulWidget {
//   const LoginWidget({Key? key}) : super(key: key);

//   @override
//   _LoginWidgetState createState() => _LoginWidgetState();
// }

// class _LoginWidgetState extends State<LoginWidget> {
//   late LoginModel _model;

//   final scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//     _model = createModel(context, () => LoginModel());

//     _model.emailAddressController ??= TextEditingController();
//     _model.passwordController ??= TextEditingController();
//   }

//   @override
//   void dispose() {
//     _model.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _model.unfocusNode.canRequestFocus
//           ? FocusScope.of(context).requestFocus(_model.unfocusNode)
//           : FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: Colors.white,
//         body: Container(
//           height: double.infinity,
//           decoration: BoxDecoration(
//             color: Color(0xFF99D399),
//           ),
//           alignment: AlignmentDirectional(0.00, -1.00),
//           child: Stack(
//             children: [
//               SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 240, 0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.asset(
//                           'assets/images/image-1.png',
//                           width: 150,
//                           height: 150,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 160, 0),
//                       child: Text(
//                         'MASUK AKUN',
//                         style:
//                             FlutterFlowTheme.of(context).displaySmall.override(
//                                   fontFamily: 'Plus Jakarta Sans',
//                                   color: Colors.white,
//                                   fontSize: 25,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 205, 0),
//                       child: Text(
//                         'Selamat Datang\nKembali',
//                         style: FlutterFlowTheme.of(context).titleSmall,
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 16),
//                       child: Container(
//                         width: double.infinity,
//                         constraints: BoxConstraints(
//                           maxWidth: 570,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               blurRadius: 4,
//                               color: Color(0x33000000),
//                               offset: Offset(0, 2),
//                             )
//                           ],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Align(
//                           alignment: AlignmentDirectional(0.00, 0.00),
//                           child: Padding(
//                             padding:
//                                 EdgeInsetsDirectional.fromSTEB(32, 32, 32, 32),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.max,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       0, 0, 0, 16),
//                                   child: Container(
//                                     width: double.infinity,
//                                     child: TextFormField(
//                                       controller: _model.emailAddressController,
//                                       autofocus: true,
//                                       autofillHints: [AutofillHints.email],
//                                       obscureText: false,
//                                       decoration: InputDecoration(
//                                         labelText: 'Email/No.Telp',
//                                         labelStyle: FlutterFlowTheme.of(context)
//                                             .labelLarge
//                                             .override(
//                                               fontFamily: 'Plus Jakarta Sans',
//                                               color: Color(0xFF57636C),
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                         enabledBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFFF1F4F8),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFF4B39EF),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         errorBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFFE0E3E7),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         focusedErrorBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFFE0E3E7),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         filled: true,
//                                         fillColor: Color(0xFFF1F4F8),
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyLarge
//                                           .override(
//                                             fontFamily: 'Plus Jakarta Sans',
//                                             color: Color(0xFF101213),
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                       keyboardType: TextInputType.emailAddress,
//                                       validator: _model
//                                           .emailAddressControllerValidator
//                                           .asValidator(context),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       0, 0, 0, 16),
//                                   child: Container(
//                                     width: double.infinity,
//                                     child: TextFormField(
//                                       controller: _model.passwordController,
//                                       autofocus: true,
//                                       autofillHints: [AutofillHints.password],
//                                       obscureText: !_model.passwordVisibility,
//                                       decoration: InputDecoration(
//                                         labelText: 'Password',
//                                         labelStyle: FlutterFlowTheme.of(context)
//                                             .labelLarge
//                                             .override(
//                                               fontFamily: 'Plus Jakarta Sans',
//                                               color: Color(0xFF57636C),
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                         enabledBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFFF1F4F8),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         focusedBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFF4B39EF),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         errorBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFFE0E3E7),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         focusedErrorBorder: OutlineInputBorder(
//                                           borderSide: BorderSide(
//                                             color: Color(0xFFE0E3E7),
//                                             width: 2,
//                                           ),
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         filled: true,
//                                         fillColor: Color(0xFFF1F4F8),
//                                         suffixIcon: InkWell(
//                                           onTap: () => setState(
//                                             () => _model.passwordVisibility =
//                                                 !_model.passwordVisibility,
//                                           ),
//                                           focusNode:
//                                               FocusNode(skipTraversal: true),
//                                           child: Icon(
//                                             _model.passwordVisibility
//                                                 ? Icons.visibility_outlined
//                                                 : Icons.visibility_off_outlined,
//                                             color: Color(0xFF57636C),
//                                             size: 24,
//                                           ),
//                                         ),
//                                       ),
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyLarge
//                                           .override(
//                                             fontFamily: 'Plus Jakarta Sans',
//                                             color: Color(0xFF101213),
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                       validator: _model
//                                           .passwordControllerValidator
//                                           .asValidator(context),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       0, 0, 0, 16),
//                                   child: FFButtonWidget(
//                                     onPressed: () {
//                                       print('Button pressed ...');
//                                     },
//                                     text: 'Sign In',
//                                     options: FFButtonOptions(
//                                       width: double.infinity,
//                                       height: 44,
//                                       padding: EdgeInsetsDirectional.fromSTEB(
//                                           0, 0, 0, 0),
//                                       iconPadding:
//                                           EdgeInsetsDirectional.fromSTEB(
//                                               0, 0, 0, 0),
//                                       color: Color(0xFF4B39EF),
//                                       textStyle: FlutterFlowTheme.of(context)
//                                           .titleSmall
//                                           .override(
//                                             fontFamily: 'Plus Jakarta Sans',
//                                             color: Colors.white,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                       elevation: 3,
//                                       borderSide: BorderSide(
//                                         color: Colors.transparent,
//                                         width: 1,
//                                       ),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       16, 0, 16, 24),
//                                   child: Text(
//                                     'Or sign in with',
//                                     textAlign: TextAlign.center,
//                                     style: FlutterFlowTheme.of(context)
//                                         .labelMedium
//                                         .override(
//                                           fontFamily: 'Plus Jakarta Sans',
//                                           color: Color(0xFF57636C),
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       0, 0, 0, 16),
//                                   child: FFButtonWidget(
//                                     onPressed: () {
//                                       print('Button pressed ...');
//                                     },
//                                     text: 'Continue with Google',
//                                     icon: FaIcon(
//                                       FontAwesomeIcons.google,
//                                       size: 20,
//                                     ),
//                                     options: FFButtonOptions(
//                                       width: double.infinity,
//                                       height: 44,
//                                       padding: EdgeInsetsDirectional.fromSTEB(
//                                           0, 0, 0, 0),
//                                       iconPadding:
//                                           EdgeInsetsDirectional.fromSTEB(
//                                               0, 0, 0, 0),
//                                       color: Colors.white,
//                                       textStyle: FlutterFlowTheme.of(context)
//                                           .titleSmall
//                                           .override(
//                                             fontFamily: 'Plus Jakarta Sans',
//                                             color: Color(0xFF101213),
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                       elevation: 0,
//                                       borderSide: BorderSide(
//                                         color: Color(0xFFF1F4F8),
//                                         width: 2,
//                                       ),
//                                       borderRadius: BorderRadius.circular(12),
//                                       hoverColor: Color(0xFFF1F4F8),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       0, 0, 0, 16),
//                                   child: FFButtonWidget(
//                                     onPressed: () {
//                                       print('Button pressed ...');
//                                     },
//                                     text: 'Continue with Apple',
//                                     icon: FaIcon(
//                                       FontAwesomeIcons.apple,
//                                       size: 20,
//                                     ),
//                                     options: FFButtonOptions(
//                                       width: double.infinity,
//                                       height: 44,
//                                       padding: EdgeInsetsDirectional.fromSTEB(
//                                           0, 0, 0, 0),
//                                       iconPadding:
//                                           EdgeInsetsDirectional.fromSTEB(
//                                               0, 0, 0, 0),
//                                       color: Colors.white,
//                                       textStyle: FlutterFlowTheme.of(context)
//                                           .titleSmall
//                                           .override(
//                                             fontFamily: 'Plus Jakarta Sans',
//                                             color: Color(0xFF101213),
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                       elevation: 0,
//                                       borderSide: BorderSide(
//                                         color: Color(0xFFF1F4F8),
//                                         width: 2,
//                                       ),
//                                       borderRadius: BorderRadius.circular(12),
//                                       hoverColor: Color(0xFFF1F4F8),
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsetsDirectional.fromSTEB(
//                                       0, 12, 0, 12),
//                                   child: RichText(
//                                     textScaleFactor:
//                                         MediaQuery.of(context).textScaleFactor,
//                                     text: TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: 'Don\'t have an account?  ',
//                                           style: TextStyle(),
//                                         ),
//                                         TextSpan(
//                                           text: 'Sign Up here',
//                                           style: FlutterFlowTheme.of(context)
//                                               .bodyMedium
//                                               .override(
//                                                 fontFamily: 'Plus Jakarta Sans',
//                                                 color: Color(0xFF4B39EF),
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                         )
//                                       ],
//                                       style: FlutterFlowTheme.of(context)
//                                           .bodyMedium
//                                           .override(
//                                             fontFamily: 'Plus Jakarta Sans',
//                                             color: Color(0xFF101213),
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: EdgeInsetsDirectional.fromSTEB(245, 710, 0, 0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.asset(
//                     'assets/images/image-2.png',
//                     width: 150,
//                     height: 150,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
