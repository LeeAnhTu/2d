import 'package:flutter/material.dart';
import '../components/draggable_image.dart'; // Import đúng cách
import '../components/icon_buttons.dart';
import '../components/select_room.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../model/image_details.dart';

class DrawDetail extends StatefulWidget {
  const DrawDetail({super.key});

  @override
  State<DrawDetail> createState() => _DrawDetailState();
}

class _DrawDetailState extends State<DrawDetail> {
  Map<String, List<ImageDetails>>? imagesMap;
  List<DraggableImage> draggableImages = [];

  @override
  void initState() {
    super.initState();
    loadImagesMap();
  }

  Future<void> loadImagesMap() async {
    // Load file JSON từ assets
    String jsonString = await rootBundle.loadString('assets/images/images_list.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    // Chuyển dữ liệu JSON thành Map<String, List<ImageDetails>>
    setState(() {
      imagesMap = jsonData.map((key, value) {
        List<ImageDetails> imageDetailsList = (value as List<dynamic>)
            .map((item) => ImageDetails.fromJson(item as Map<String, dynamic>))
            .toList();
        return MapEntry(key, imageDetailsList);
      });
    });
  }

  // Hàm để hiển thị chọn ảnh
  void _showImageSelection(BuildContext context, String imageType) {
    if (imagesMap == null || !imagesMap!.containsKey(imageType)) {
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 120,
          color: Colors.white,
          child: Column(
            children: [
              Text(
                'Select Image: $imageType',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imagesMap![imageType]!.length,
                  itemBuilder: (context, index) {
                    final imageDetails = imagesMap![imageType]![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Giảm khoảng cách
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _addDraggableImage(imageDetails, imageType); // Thêm ảnh
                        },
                        child: Container(
                          width: ImageDetails.defaultWidth, // Kích thước cố định cho tất cả ảnh
                          height: ImageDetails.defaultHeight, // Kích thước cố định cho tất cả ảnh
                          child: Image.asset(
                            'assets/images/$imageType/${imageDetails.fileName}', // Đường dẫn ảnh từ JSON
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // Thêm ảnh draggable
  void _addDraggableImage(ImageDetails imageDetails, String imageType) {
    setState(() {
      // Đường dẫn đầy đủ cho ảnh ban đầu
      String imagePath = 'assets/images/$imageType/${imageDetails.fileName}';

      // Đường dẫn cho ảnh thay thế
      String alternateImagePath = imageDetails.alternateFileName != null
          ? 'assets/images/$imageType/${imageDetails.alternateFileName}'
          : imagePath;

      // Sử dụng kích thước mặc định, chỉ thay đổi chiều cao nếu ảnh thay thế có kích thước khác
      double imageWidth = ImageDetails.defaultWidth;  // Kích thước mặc định cho tất cả ảnh
      double imageHeight = imageDetails.alternateHeight ?? ImageDetails.defaultHeight;

      // Thêm ảnh thay thế hoặc ảnh gốc vào draggableImages
      draggableImages.add(DraggableImage(
        fileName: alternateImagePath, // Dùng ảnh thay thế nếu có
        width: imageWidth,            // Dùng độ rộng mặc định
        height: imageHeight,          // Dùng chiều cao thay thế nếu có
        position: Offset(0, 0),       // Vị trí mặc định
      ));
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw2D'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SelectRoom(
              draggableImages: draggableImages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: CustomIconButton(
                icon: Icons.table_restaurant,
                onPressed: () {
                  _showImageSelection(context, 'Table');
                },
              ),
            ),
            Flexible(
              child: CustomIconButton(
                icon: Icons.chair,
                onPressed: () {
                  _showImageSelection(context, 'Chair');
                },
              ),
            ),
            Flexible(
              child: CustomIconButton(
                icon: Icons.local_florist,
                onPressed: () {
                  _showImageSelection(context, 'Tree');
                },
              ),
            ),
            Flexible(
              child: CustomIconButton(
                icon: Icons.sensor_door,
                onPressed: () {
                  _showImageSelection(context, 'Door');
                },
              ),
            ),
            Flexible(
              child: CustomIconButton(
                icon: Icons.window,
                onPressed: () {
                  _showImageSelection(context, 'Window');
                },
              ),
            ),
            Flexible(
              child: CustomIconButton(
                icon: Icons.bed,
                onPressed: () {
                  _showImageSelection(context, 'Bed');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
