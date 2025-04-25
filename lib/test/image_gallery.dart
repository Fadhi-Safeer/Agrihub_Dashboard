import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'image_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageGalleryProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String camNum = "cam1";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery',
      home: ImageGalleryScreen(camNum: camNum),
    );
  }
}

class ImageGalleryScreen extends StatefulWidget {
  final String camNum;

  const ImageGalleryScreen({Key? key, required this.camNum}) : super(key: key);

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger image load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ImageGalleryProvider>(context, listen: false)
          .loadImages(widget.camNum);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageGalleryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Images - ${widget.camNum}")),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : provider.errorMessage.isNotEmpty
              ? Center(child: Text(provider.errorMessage))
              : GridView.builder(
                  padding: EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: provider.images.length,
                  itemBuilder: (context, index) {
                    final image = provider.images[index];
                    return Column(
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: image.url,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          image.filename,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
