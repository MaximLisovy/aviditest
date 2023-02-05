import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aviditest/Screens/ShareScreen.dart';

class ImageItem extends StatelessWidget {
  final String image;
  const ImageItem(this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(imageUrl: image,
      imageBuilder: (context, imageProvider) =>
          InkWell(
              onTap: (){
               Navigator.push(context,
                 MaterialPageRoute(
                 builder: (context) => ShareScreen(image: imageProvider,link: image,),
               ),);
              },
              child:
          Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover),
        ),
      )),
      errorWidget: (context, url, error) => Image.asset("assets/images/placeholder.png", fit: BoxFit.cover)
    );
  }
}
