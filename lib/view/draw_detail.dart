import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/DesignStorage.dart';
import '../components/design.dart';
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
  String selectedRoomType = 'rectangle'; // 'rectangle' hoặc 'square'
  double roomWidth = 0.0; // Thay thế cho 'width'
  double roomHeight = 0.0; // Thay thế cho 'height'
  @override
  void initState() {
    super.initState();
    loadImagesMap();
  }
  Future<void> saveDesign() async {
    final prefs = await SharedPreferences.getInstance();
    final design = Design(
      name: 'MyDesign', // Bạn có thể thêm input để người dùng nhập tên
      draggableImages: draggableImages,
      width: roomWidth,
      height: roomHeight,
      roomType: selectedRoomType,
    );
    final jsonString = jsonEncode(design.toJson());
    await prefs.setString('savedDesign', jsonString);
  }

  Future<void> loadDesign() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('savedDesign');
    if (jsonString != null) {
      final designJson = jsonDecode(jsonString);
      final design = Design.fromJson(designJson);
      setState(() {
        draggableImages = design.draggableImages;
        roomWidth = design.width;
        roomHeight = design.height;
        selectedRoomType = design.roomType;
      });
    }
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

  void _saveDesign() async {
    String? designName = await _showNameInputDialog();
    if (designName != null && designName.isNotEmpty) {
      final design = Design(
        name: designName,
        draggableImages: draggableImages,
        width: roomWidth,
        height: roomHeight,
        roomType: selectedRoomType,
      );
      await DesignStorage.saveDesign(design);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Design saved successfully')),
      );
    }
  }

  void _loadDesign() async {
    List<Design> savedDesigns = await DesignStorage.loadDesigns();
    if (savedDesigns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No saved designs')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a design'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: savedDesigns.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(savedDesigns[index].name),
                  onTap: () {
                    Navigator.of(context).pop();
                    _applyDesign(savedDesigns[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _applyDesign(Design design) {
    setState(() {
      draggableImages = design.draggableImages;
      roomWidth = design.width;
      roomHeight = design.height;
      selectedRoomType = design.roomType;
    });
  }
  Future<String?> _showNameInputDialog() async {
    String? designName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter design name'),
          content: TextField(
            onChanged: (value) {
              designName = value;
            },
            decoration: InputDecoration(hintText: "Design name"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () => Navigator.of(context).pop(designName),
            ),
          ],
        );
      },
    );
    return designName;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw2D'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDesign,
          ),
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _loadDesign,
          ),
        ],
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
