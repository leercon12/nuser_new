import 'dart:math';
import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter_mixcall_normaluser_new/setting/theme/my_theme.dart';

import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;

enum Direction { left, right }

class ARIOSPage extends StatefulWidget {
  const ARIOSPage({Key? key}) : super(key: key);

  @override
  State<ARIOSPage> createState() => _ARIOSPageState();
}

class _ARIOSPageState extends State<ARIOSPage> {
  late ARKitController arkitController;
  ARKitNode? boxNode;
  ARKitNode? floorMarker;
  Vector3? boxPosition;
  Vector3 boxRotation = Vector3.zero();
  String debugText = '';
  List<ARKitNode> edgeNodes = [];
  bool isFloorDetected = false;
  Offset? _panStartLocation;
  Vector3? _boxStartPosition;
  Vector3? floorPosition;
  Vector3? boxAnchorPoint;
  ARKitNode? anchorSphereNode;
  Vector3 boxSize = Vector3(0.1, 0.1, 0.1);

  @override
  void dispose() {
    arkitController.dispose();
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
              child: ARKitSceneView(
                onARKitViewCreated: onARKitViewCreated,
                planeDetection: ARPlaneDetection.horizontal,
                enableTapRecognizer: true,
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
                      backgroundColor: setBlack.withOpacity(0.5)),
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
        // 회전 각도
        double rotationAngle = (direction == Direction.left) ? 0.1 : -0.1;
        boxRotation.y += rotationAngle;

        // 1. 앵커 위치 및 회전 업데이트
        _updateAnchorSphere(boxAnchorPoint!, boxRotation.y);

        // 2. 박스 위치 및 회전 업데이트
        Matrix4 transform = Matrix4.identity()
          ..setTranslation(boxAnchorPoint!)
          ..rotateY(boxRotation.y)
          ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

        boxNode!.transform = transform;
        updateEdges();
      });
    }
  }

  void addBox({required Vector3 position}) {
    // 기준점 설정 (바닥의 한 점)
    boxAnchorPoint = position;

    // 1. 앵커 생성 및 배치
    _updateAnchorSphere(boxAnchorPoint!, boxRotation.y);

    // 2. 박스 생성 및 배치
    Matrix4 transform = Matrix4.identity()
      ..setTranslation(boxAnchorPoint!)
      ..rotateY(boxRotation.y)
      ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(kOrangeBssetColor.withOpacity(0.5)),
      transparency: 0.5,
    );

    boxNode = ARKitNode(
        name: 'cargo_box',
        geometry: ARKitBox(
          width: boxSize.x,
          height: boxSize.y,
          length: boxSize.z,
          materials: [material],
        ),
        transformation: transform);

    arkitController.add(boxNode!);
    _addEdgeLines(boxNode!, boxSize);

    setDebugText('박스가 추가되었습니다.');
  }

  void _updateBoxSize({double? width, double? height, double? depth}) {
    if (boxNode == null || boxAnchorPoint == null) return;

    setState(() {
      // 크기 업데이트
      if (width != null) boxSize.x = width;
      if (height != null) boxSize.y = height;
      if (depth != null) boxSize.z = depth;

      final material = ARKitMaterial(
        diffuse:
            ARKitMaterialProperty.color(kOrangeBssetColor.withOpacity(0.5)),
        transparency: 0.5,
      );

      arkitController.remove(boxNode!.name);

      // 1. 앵커는 그대로 유지하면서 회전만 적용
      _updateAnchorSphere(boxAnchorPoint!, boxRotation.y);

      // 2. 박스는 새로운 크기로 업데이트하되 기준점 기준으로 확장
      Matrix4 transform = Matrix4.identity()
        ..setTranslation(boxAnchorPoint!)
        ..rotateY(boxRotation.y)
        ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

      boxNode = ARKitNode(
          name: 'cargo_box',
          geometry: ARKitBox(
            width: boxSize.x,
            height: boxSize.y,
            length: boxSize.z,
            materials: [material],
          ),
          transformation: transform);

      arkitController.add(boxNode!);
      updateEdges();
    });
    setDebugText(
        '박스 크기가 변경되었습니다: 가로 ${boxSize.x.toStringAsFixed(2)}m x 세로 ${boxSize.z.toStringAsFixed(2)}m x 높이 ${boxSize.y.toStringAsFixed(2)}m');
  }

  void _updateAnchorSphere(Vector3 position, double rotation) {
    if (anchorSphereNode != null) {
      arkitController.remove(anchorSphereNode!.name);
    }

    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(kCyanA),
      emission: ARKitMaterialProperty.color(kCyanA),
    );

    final sphere = ARKitSphere(
      radius: 0.02,
      materials: [material],
    );

    // 앵커의 transform도 회전 적용
    Matrix4 transform = Matrix4.identity()
      ..setTranslation(position)
      ..rotateY(rotation);

    anchorSphereNode = ARKitNode(
        name: 'anchor_sphere', geometry: sphere, transformation: transform);

    arkitController.add(anchorSphereNode!);
  }

  void moveBox(Vector3 newPosition) {
    if (boxNode != null && floorPosition != null) {
      setState(() {
        boxAnchorPoint = Vector3(
            newPosition.x,
            floorPosition!.y, // 항상 바닥에 위치
            newPosition.z);

        // 1. 앵커 이동
        _updateAnchorSphere(boxAnchorPoint!, boxRotation.y);

        // 2. 박스 이동
        Matrix4 transform = Matrix4.identity()
          ..setTranslation(boxAnchorPoint!)
          ..rotateY(boxRotation.y)
          ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

        boxNode!.transform = transform;
        updateEdges();
      });
      setDebugText('박스 위치가 변경되었습니다.');
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartLocation == null || boxAnchorPoint == null || boxNode == null)
      return;

    final dx = details.localPosition.dx - _panStartLocation!.dx;
    final dy = details.localPosition.dy - _panStartLocation!.dy;
    final scale = 0.001;

    setState(() {
      Vector3 newAnchorPoint = Vector3(
          _boxStartPosition!.x + dx * scale,
          floorPosition!.y, // 항상 바닥에 위치
          _boxStartPosition!.z + dy * scale);

      boxAnchorPoint = newAnchorPoint;

      // 1. 앵커 이동
      _updateAnchorSphere(boxAnchorPoint!, boxRotation.y);

      // 2. 박스 이동
      Matrix4 transform = Matrix4.identity()
        ..setTranslation(boxAnchorPoint!)
        ..rotateY(boxRotation.y)
        ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

      boxNode!.transform = transform;
      updateEdges();
    });
  }

  void detectFloor() async {
    final hitTestResults = await arkitController.performHitTest(
      x: 0.5,
      y: 0.5,
    );
    if (hitTestResults.isNotEmpty) {
      final result = hitTestResults.first;
      final newFloorPosition = Vector3(
        result.worldTransform.getColumn(3).x,
        result.worldTransform.getColumn(3).y,
        result.worldTransform.getColumn(3).z,
      );

      setState(() {
        // 새로운 바닥 설정
        isFloorDetected = true;
        floorPosition = newFloorPosition;

        // 기존 바닥 마커 업데이트
        _addFloorMarker(newFloorPosition);

        // 박스가 있다면 새 바닥으로 이동
        if (boxNode != null) {
          boxAnchorPoint =
              Vector3(boxAnchorPoint!.x, newFloorPosition.y, boxAnchorPoint!.z);

          // 1. 앵커 업데이트
          _updateAnchorSphere(boxAnchorPoint!, boxRotation.y);

          // 2. 박스 업데이트
          Matrix4 transform = Matrix4.identity()
            ..setTranslation(boxAnchorPoint!)
            ..rotateY(boxRotation.y)
            ..translate(boxSize.x / 2, boxSize.y / 2, -boxSize.z / 2);

          boxNode!.transform = transform;
          updateEdges();
        }

        setDebugText('새로운 바닥이 설정되었습니다.');
      });
    } else {
      setDebugText('바닥을 감지할 수 없습니다. 다시 시도해주세요.');
    }
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
          onChanged: (double value) {
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

  void updateEdges() {
    if (boxNode != null) {
      for (var node in edgeNodes) {
        arkitController.remove(node.name);
      }
      edgeNodes.clear();
      _addEdgeLines(boxNode!, boxSize);
    }
  }

  void _addEdgeLines(ARKitNode parentNode, Vector3 size) {
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

    _drawEdges(vertices, frontEdges, kBlueBssetColor, parentNode);
    _drawEdges(vertices, backEdges, kGreenFontColor, parentNode);
  }

  void _drawEdges(List<Vector3> vertices, List<List<int>> edges, Color color,
      ARKitNode parentNode) {
    for (var edge in edges) {
      final start = vertices[edge[0]];
      final end = vertices[edge[1]];
      _drawEdge(start, end, color, parentNode);
    }
  }

  void _drawEdge(
      Vector3 start, Vector3 end, Color color, ARKitNode parentNode) {
    final direction = end - start;
    final length = direction.length;
    final midPoint = (start + end) / 2;

    final cylinder = ARKitCylinder(
      radius: 0.001,
      height: length,
      materials: [
        ARKitMaterial(
          diffuse: ARKitMaterialProperty.color(color),
          emission: ARKitMaterialProperty.color(color),
        )
      ],
    );

    final node = ARKitNode(
      geometry: cylinder,
      position: midPoint,
      eulerAngles: _calculateRotation(direction),
    );

    arkitController.add(node, parentNodeName: parentNode.name);
    edgeNodes.add(node);
  }

  Vector3 _calculateRotation(Vector3 direction) {
    final up = Vector3(0, 1, 0);
    final axis = direction.normalized().cross(up).normalized();
    final angle = math.acos(direction.normalized().dot(up));
    return axis * angle;
  }

  void _onPanStart(DragStartDetails details) {
    if (boxNode == null) return;
    _panStartLocation = details.localPosition;
    _boxStartPosition = boxNode!.position;
  }

  void _onPanEnd(DragEndDetails details) {
    _panStartLocation = null;
    _boxStartPosition = null;
  }

  void onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController.onARTap = handleARTap;
    setDebugText(
        '상단의 파란색 버튼을 클릭하여 바닥을 설정하세요.\n빨간점이 바닥에 정상적으로 표시되어야 합니다.\n바닥을 다시 설정하시려면 파란색 버튼을 클릭하세요.');
  }

  void _addFloorMarker(Vector3 position) {
    if (floorMarker != null) {
      arkitController.remove(floorMarker!.name);
    }

    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(kRedColor),
      emission: ARKitMaterialProperty.color(kRedColor),
    );
    final sphere = ARKitSphere(
      radius: 0.01,
      materials: [material],
    );
    floorMarker = ARKitNode(
      geometry: sphere,
      position: position,
    );
    arkitController.add(floorMarker!);
  }

  void handleARTap(List<ARKitTestResult> hits) {
    if (!isFloorDetected || hits.isEmpty) return;

    final hit = hits.first;
    final position = Vector3(
      hit.worldTransform.getColumn(3).x,
      hit.worldTransform.getColumn(3).y,
      hit.worldTransform.getColumn(3).z,
    );

    if (boxNode == null) {
      addBox(position: position);
    } else {
      moveBox(position);
    }
  }

  void setDebugText(String text) {
    setState(() {
      debugText = text;
    });
  }
}
