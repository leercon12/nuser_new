/* import 'dart:math';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;

enum Direction { left, right }

class ARAndroidPage extends StatefulWidget {
  const ARAndroidPage({Key? key}) : super(key: key);

  @override
  State<ARAndroidPage> createState() => _ARAndroidPageState();
}

class _ARAndroidPageState extends State<ARAndroidPage> {
  ArCoreController? arCoreController;
  ArCoreNode? boxNode;
  ArCoreNode? floorMarker;
  ArCoreNode? anchorSphereNode;
  Vector3 boxSize = Vector3(0.1, 0.1, 0.1);
  Vector3? boxPosition;
  Vector3 boxRotation = Vector3.zero();
  String debugText = '';
  List<ArCoreNode> edgeNodes = [];
  bool isFloorDetected = false;
  Offset? _panStartLocation;
  Vector3? _boxStartPosition;
  Vector3? floorPosition;
  Vector3? boxAnchorPoint;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: ArCoreView(
                onArCoreViewCreated: onArCoreViewCreated,
                enableTapRecognizer: true,
                enableUpdateListener: true,
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: FloatingActionButton(
                child: Icon(Icons.arrow_back, color: setBlack),
                backgroundColor: setWhite,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (isFloorDetected && boxNode != null)
              Positioned(
                bottom: 40,
                child: SizedBox(
                  width: dw,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: setBlack.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildSizeControl('Width'),
                            SizedBox(height: 10),
                            _buildSizeControl('Height'),
                            SizedBox(height: 10),
                            _buildSizeControl('Length'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              right: 10,
              top: 80,
              child: FloatingActionButton(
                child: Icon(Icons.border_bottom, color: setWhite),
                backgroundColor: kBlueBssetColor,
                onPressed: detectFloor,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Row(
                children: [
                  FloatingActionButton(
                    child: Icon(Icons.rotate_right, color: setBlack),
                    backgroundColor: setWhite,
                    onPressed: () => rotateBox(Direction.left),
                  ),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    child: Icon(Icons.rotate_left, color: setBlack),
                    backgroundColor: setWhite,
                    onPressed: () => rotateBox(Direction.right),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Center(
                child: Text(
                  debugText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: setWhite,
                    backgroundColor: setBlack.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void rotateBox(Direction direction) {
    if (boxNode != null && boxAnchorPoint != null) {
      setState(() {
        double rotationAngle = (direction == Direction.left) ? 0.1 : -0.1;
        boxRotation.y += rotationAngle;

        // 앵커 위치 업데이트
        _updateAnchorSphere(boxAnchorPoint!);

        // 박스 위치 및 회전 업데이트
        updateBox();
      });
      setDebugText('박스가 회전되었습니다.');
    }
  }

  void addBox({required Vector3 position}) {
    if (floorPosition == null) {
      setDebugText('먼저 파란색 버튼으로 바닥을 감지해주세요.');
      return;
    }

    // 기준점 설정
    boxAnchorPoint = position;
    boxPosition = Vector3(
      position.x + boxSize.x / 2,
      position.y + boxSize.y / 2,
      position.z - boxSize.z / 2,
    );

    final material = ArCoreMaterial(
      color: Color(0xFFFFA500).withOpacity(0.5),
      metallic: 1.0,
    );

    final cube = ArCoreCube(
      materials: [material],
      size: boxSize,
    );

    boxNode = ArCoreNode(
      name: 'cargo_box',
      shape: cube,
      position: boxPosition,
      rotation: Vector4(0, 1, 0, boxRotation.y - pi / 2),
    );

    arCoreController?.addArCoreNode(boxNode!);
    _addEdgeLines(boxNode!, boxSize);
    _updateAnchorSphere(boxAnchorPoint!);
    setDebugText('박스가 추가되었습니다.');
  }

  void _updateAnchorSphere(Vector3 position) {
    if (anchorSphereNode != null) {
      arCoreController?.removeNode(nodeName: anchorSphereNode!.name!);
    }

    final material = ArCoreMaterial(color: kCyanA);
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.02,
    );

    anchorSphereNode = ArCoreNode(
      name: 'anchor_sphere',
      shape: sphere,
      position: position,
    );

    arCoreController?.addArCoreNode(anchorSphereNode!);
  }

  void _updateBoxSize({double? width, double? height, double? depth}) {
    if (boxPosition == null || floorPosition == null || boxAnchorPoint == null)
      return;

    setState(() {
      if (width != null) boxSize.x = width;
      if (height != null) boxSize.y = height;
      if (depth != null) boxSize.z = depth;

      // 박스의 새로운 위치 계산
      Matrix4 transform = Matrix4.identity()
        ..setTranslation(boxAnchorPoint!)
        ..rotateY(boxRotation.y)
        ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

      boxPosition = Vector3(
        transform.getTranslation().x,
        transform.getTranslation().y,
        transform.getTranslation().z,
      );

      updateBox();
    });

    setDebugText(
        '박스 크기가 변경되었습니다: 가로 ${boxSize.x.toStringAsFixed(2)}m x 세로 ${boxSize.z.toStringAsFixed(2)}m x 높이 ${boxSize.y.toStringAsFixed(2)}m');
  }

  Widget _buildSizeControl(String label) {
    String koreanLabel =
        label == 'Width' ? '가로' : (label == 'Height' ? '높이' : '세로');
    double currentValue = label == 'Width'
        ? boxSize.x
        : (label == 'Height' ? boxSize.y : boxSize.z);

    return Row(
      children: [
        Text(koreanLabel, style: TextStyle(color: setWhite)),
        Slider(
          value: currentValue,
          min: 0.01,
          max: 3.0,
          activeColor: setWhite,
          divisions: 299,
          label: koreanLabel,
          onChanged: (value) {
            if (label == 'Width') {
              _updateBoxSize(width: value);
            } else if (label == 'Height') {
              _updateBoxSize(height: value);
            } else {
              _updateBoxSize(depth: value);
            }
          },
        ),
        Text(
          '${currentValue.toStringAsFixed(2)}m',
          style: TextStyle(color: setWhite),
        ),
      ],
    );
  }

  void updateBox() {
    if (boxNode != null && boxPosition != null) {
      arCoreController?.removeNode(nodeName: boxNode!.name!);
      for (var node in edgeNodes) {
        arCoreController?.removeNode(nodeName: node.name!);
      }
      edgeNodes.clear();

      // 박스의 새로운 위치 계산
      Matrix4 transform = Matrix4.identity()
        ..setTranslation(boxAnchorPoint!)
        ..rotateY(boxRotation.y)
        ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

      boxPosition = Vector3(
        transform.getTranslation().x,
        transform.getTranslation().y,
        transform.getTranslation().z,
      );

      final material = ArCoreMaterial(
        color: Color(0xFFFFA500).withOpacity(0.5),
        metallic: 1.0,
      );

      final cube = ArCoreCube(
        materials: [material],
        size: boxSize,
      );

      boxNode = ArCoreNode(
        name: 'cargo_box',
        shape: cube,
        position: boxPosition,
        rotation: Vector4(0, 1, 0, boxRotation.y - pi / 2),
      );

      arCoreController?.addArCoreNode(boxNode!);
      _addEdgeLines(boxNode!, boxSize);
    }
  }

  void _addEdgeLines(ArCoreNode parentNode, Vector3 size) {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;
    final halfLength = size.z / 2;

    final vertices = [
      Vector3(-halfWidth, -halfHeight, -halfLength),
      Vector3(halfWidth, -halfHeight, -halfLength),
      Vector3(halfWidth, halfHeight, -halfLength),
      Vector3(-halfWidth, halfHeight, -halfLength),
      Vector3(-halfWidth, -halfHeight, halfLength),
      Vector3(halfWidth, -halfHeight, halfLength),
      Vector3(halfWidth, halfHeight, halfLength),
      Vector3(-halfWidth, halfHeight, halfLength),
    ];

    final frontEdges = [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 0]
    ];
    final backEdges = [
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 4]
    ];

    Matrix4 transform = Matrix4.identity()
      ..setTranslation(boxPosition!)
      ..rotateY(boxRotation.y);

    // 회전된 vertex 위치 계산
    final rotatedVertices = vertices.map((v) {
      final transformed = transform.transform3(v);
      return transformed;
    }).toList();

    _drawEdges(rotatedVertices, frontEdges, kBlueBssetColor, parentNode);
    _drawEdges(rotatedVertices, backEdges, kGreenFontColor, parentNode);
  }

  void _drawEdges(List<Vector3> vertices, List<List<int>> edges, Color color,
      ArCoreNode parentNode) {
    for (var edge in edges) {
      final start = vertices[edge[0]];
      final end = vertices[edge[1]];
      _drawEdge(start, end, color, parentNode);
    }
  }

  void _drawEdge(
      Vector3 start, Vector3 end, Color color, ArCoreNode parentNode) {
    final direction = end - start;
    final length = direction.length;
    final midPoint = (start + end) / 2;

    final material = ArCoreMaterial(color: color);
    final cylinder = ArCoreCylinder(
      materials: [material],
      radius: 0.001,
      height: length,
    );

    final node = ArCoreNode(
      shape: cylinder,
      position: midPoint,
      rotation: _quaternionBetween(Vector3(0, 1, 0), direction.normalized()),
    );

    arCoreController?.addArCoreNode(node);
    edgeNodes.add(node);
  }

  Vector4 _quaternionBetween(Vector3 start, Vector3 end) {
    start = start.normalized();
    end = end.normalized();

    final cosTheta = start.dot(end);
    final axis = start.cross(end);

    final s = sqrt((1 + cosTheta) * 2);
    final invs = 1 / s;

    return Vector4(
      axis.x * invs,
      axis.y * invs,
      axis.z * invs,
      s * 0.5,
    ).normalized();
  }

  void _onPanStart(DragStartDetails details) {
    if (boxNode == null) return;
    _panStartLocation = details.localPosition;
    _boxStartPosition = boxAnchorPoint;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartLocation == null ||
        boxAnchorPoint == null ||
        boxNode == null ||
        _boxStartPosition == null) return;

    final dx = details.localPosition.dx - _panStartLocation!.dx;
    final dy = details.localPosition.dy - _panStartLocation!.dy;
    final scale = 0.001;

    setState(() {
      boxAnchorPoint = Vector3(
        _boxStartPosition!.x + dx * scale,
        floorPosition!.y,
        _boxStartPosition!.z + dy * scale,
      );

      // 박스의 새로운 위치 계산
      Matrix4 transform = Matrix4.identity()
        ..setTranslation(boxAnchorPoint!)
        ..rotateY(boxRotation.y)
        ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

      boxPosition = Vector3(
        transform.getTranslation().x,
        transform.getTranslation().y,
        transform.getTranslation().z,
      );

      updateBox();
      _updateAnchorSphere(boxAnchorPoint!);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _panStartLocation = null;
    _boxStartPosition = null;
  }

  void onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController?.onPlaneDetected = _handlePlaneDetected;
    arCoreController?.onNodeTap = (name) {
      // 탭 이벤트 처리 필요시 구현
    };
    setDebugText(
        '상단의 파란색 버튼을 클릭하여 바닥을 설정하세요.\n빨간점이 바닥에 정상적으로 표시되어야 합니다.\n바닥을 다시 설정하시려면 파란색 버튼을 클릭하세요.');
  }

  void detectFloor() async {
    if (arCoreController != null) {
      setDebugText('바닥 감지 중...');
      isFloorDetected = false;
    } else {
      setDebugText('바닥을 감지할 수 없습니다. 다시 시도해주세요.');
    }
  }

  void _handlePlaneDetected(ArCorePlane plane) {
    if (!isFloorDetected) {
      setState(() {
        isFloorDetected = true;
        floorPosition = plane.centerPose?.translation ?? Vector3(0, 0, 0);
      });
      _addFloorMarker(floorPosition!);
      setDebugText('새로운 바닥이 감지되었습니다.\n원하시는 위치를 클릭하여 박스를 생성하세요.');
      if (boxNode != null) {
        _updateBoxPosition(floorPosition!);
      }
    }
  }

  void _addFloorMarker(Vector3 position) {
    if (floorMarker != null) {
      arCoreController?.removeNode(nodeName: floorMarker!.name!);
    }

    final material = ArCoreMaterial(color: kRedColor);
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.01,
    );

    floorMarker = ArCoreNode(
      name: 'floor_marker',
      shape: sphere,
      position: position,
    );

    arCoreController?.addArCoreNode(floorMarker!);
  }

  void _updateBoxPosition(Vector3 newFloorPosition) {
    if (boxNode != null && boxPosition != null) {
      setState(() {
        // 앵커 포인트의 y좌표만 새로운 바닥 높이로 조정
        boxAnchorPoint =
            Vector3(boxAnchorPoint!.x, newFloorPosition.y, boxAnchorPoint!.z);

        // 박스의 새로운 위치 계산
        Matrix4 transform = Matrix4.identity()
          ..setTranslation(boxAnchorPoint!)
          ..rotateY(boxRotation.y)
          ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

        boxPosition = Vector3(
          transform.getTranslation().x,
          transform.getTranslation().y,
          transform.getTranslation().z,
        );

        updateBox();
        _updateAnchorSphere(boxAnchorPoint!);
      });
      setDebugText('박스가 새로운 바닥에 맞춰 조정되었습니다.');
    }
  }

  void setDebugText(String text) {
    setState(() {
      debugText = text;
    });
  }
}
 */
