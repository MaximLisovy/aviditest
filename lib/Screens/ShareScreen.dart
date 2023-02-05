import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareScreen extends StatefulWidget {
  final ImageProvider image;
  final String link;
  const ShareScreen({Key? key, required this.image, required this.link}) : super(key: key);

  @override
  State<ShareScreen> createState() => _ShareScreenState(image, link);
}

class _ShareScreenState extends State<ShareScreen> {
  ImageProvider image;
  String link;
  _ShareScreenState(this.image, this.link);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading:IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: (){Navigator.pop(context);}
        ),
      ),
      body: Column(
        children: [
         Expanded(child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image,
                fit: BoxFit.contain,
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Share.share(link);
      },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.share, color: Colors.black,),
      ),
    );
  }
}
