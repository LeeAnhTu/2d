import 'package:flutter/material.dart';

import 'draggable_image.dart';

class SelectRoom extends StatefulWidget {
  final List<DraggableImage> draggableImages;

  const SelectRoom({Key? key, required this.draggableImages}) : super(key: key);

  @override
  State<SelectRoom> createState() => _SelectRoomState();
}

class _SelectRoomState extends State<SelectRoom> {
  String selectedRoomType = 'rectangle'; // 'rectangle' hoặc 'square'
  double roomWidth = 0.0; // Chiều rộng mặc định
  double roomHeight = 0.0; // Chiều cao mặc định
  double area = 0.0; // Diện tích phòng

  Color wallColor = Colors.grey[400]!; // Màu tường xám
  Color floorColor = Colors.brown[300]!; // Màu sàn gỗ
  Color lineColor = Colors.white; // Màu đường line
  double wallThickness = 8.0; // Độ dày của tường
  double lineThickness = 2.0; // Độ dày của đường line

  @override
  Widget build(BuildContext context) {
    // Xác định kích thước mặc định là 70% kích thước màn hình
    double width = MediaQuery.of(context).size.width * 0.7;
    double height = MediaQuery.of(context).size.height * 0.7;

    return Stack(
      children: [
        Column(
          children: [
            // Thanh chọn kiểu phòng
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRoomTypeButton('rectangle', 'Rectangle'),
                  SizedBox(width: 16.0),
                  _buildRoomTypeButton('square', 'Square'),
                ],
              ),
            ),
            // Hình phòng
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _showInputDialog(context),
                  child: _buildRoomShape(width, height),
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildRoomTypeButton(String type, String label) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedRoomType = type;
          // Cập nhật kích thước mặc định dựa trên kiểu phòng đã chọn
          if (selectedRoomType == 'square') {
            roomWidth = MediaQuery.of(context).size.width * 0.7;
            roomHeight = roomWidth;
          } else {
            roomWidth = MediaQuery.of(context).size.width * 0.7;
            roomHeight = MediaQuery.of(context).size.height * 0.7;
          }
        });
      },
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedRoomType == type ? Colors.blue : Colors.grey[300],
      ),
    );
  }

  Widget _buildRoomShape(double width, double height) {
    return Container(
      width: width,
      height: (selectedRoomType == 'square') ? width : height,
      decoration: BoxDecoration(
        color: floorColor,
        border: Border.all(
          color: wallColor,
          width: wallThickness,
        ),
      ),
      child: Stack(
        children: [
          // Đường line trắng ở giữa tường
          Positioned(
            left: wallThickness / 2,
            right: wallThickness / 2,
            top: wallThickness / 2,
            child: Container(
              height: lineThickness,
              color: lineColor,
            ),
          ),
          Positioned(
            top: wallThickness / 2,
            bottom: wallThickness / 2,
            left: wallThickness / 2,
            child: Container(
              width: lineThickness,
              color: lineColor,
            ),
          ),
          Positioned(
            left: wallThickness / 2,
            right: wallThickness / 2,
            bottom: wallThickness / 2,
            child: Container(
              height: lineThickness,
              color: lineColor,
            ),
          ),
          Positioned(
            top: wallThickness / 2,
            bottom: wallThickness / 2,
            right: wallThickness / 2,
            child: Container(
              width: lineThickness,
              color: lineColor,
            ),
          ),
          // Hiển thị diện tích
          Center(
            child: Text(
              'Area: ${area.toStringAsFixed(2)} m²',
              style: TextStyle(color: Colors.black, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          // Hiển thị các đồ vật
          ...widget.draggableImages.map((draggableImage) {
            return Positioned(
              left: draggableImage.position.dx,
              top: draggableImage.position.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    draggableImage.position += details.delta;
                  });
                },
                child: Image.asset(
                  draggableImage.fileName,
                  width: draggableImage.width,
                  height: draggableImage.height,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  // Hàm để nhập chiều dài và chiều rộng
  void _showInputDialog(BuildContext context) {
    TextEditingController widthController =
    TextEditingController(text: roomWidth.toString());
    TextEditingController heightController =
    TextEditingController(text: roomHeight.toString());

    showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          title: Text('Enter Width and Height'),
    content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    TextField(
    controller: widthController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
    labelText: 'Width (m)',
      suffixText: 'm', // Thêm đơn vị vào trường nhập liệu
    ),
    ),
      TextField(
        controller: heightController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Height (m)',
          suffixText: 'm', // Thêm đơn vị vào trường nhập liệu
        ),
      ),
    ],
    ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                roomWidth = double.tryParse(widthController.text) ?? roomWidth;
                roomHeight = double.tryParse(heightController.text) ?? roomHeight;
                area = roomWidth * roomHeight;
              });
              Navigator.pop(context); // Đóng hộp thoại sau khi xác nhận
            },
            child: Text('Confirm'),
          ),
        ],
      );
        },
    );
  }
}

