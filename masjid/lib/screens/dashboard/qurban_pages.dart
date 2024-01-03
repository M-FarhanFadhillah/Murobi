import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class QurbanPages extends StatefulWidget {
  const QurbanPages({Key? key}) : super(key: key);

  @override
  _QurbanPagesState createState() => _QurbanPagesState();
}

class _QurbanPagesState extends State<QurbanPages> {
  String selectedValue = 'Zakat';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: // Generated code for this cardRow Widget...
            Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width * 0.92,
            height: 210,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  blurRadius: 6,
                  color: Color(0x4B1A1F24),
                  offset: Offset(0, 2),
                )
              ],
              gradient: const LinearGradient(
                colors: [Color(0xFF00968A), Color(0xFFF2A384)],
                stops: [0, 1],
                begin: AlignmentDirectional(0.94, -1),
                end: AlignmentDirectional(-0.94, 1),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image.asset(
                        'assets/images/visa@3x.png',
                        width: 44,
                        height: 14,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 36, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Balance',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Lexend',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        '7,630',
                        style:
                            FlutterFlowTheme.of(context).displaySmall.override(
                                  fontFamily: 'Lexend',
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontSize: 32,
                                ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0149',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto Mono',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                      Text(
                        '06/25',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto Mono',
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
