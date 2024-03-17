import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../domain/entities/cart/cart_item.dart';
import '../../../../../domain/entities/product/price_tag.dart';
import '../../../../../domain/entities/product/product.dart';
import '../../../core/router/app_router.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../widgets/input_form_button.dart';
import 'dart:io' as io;
import 'package:native_ar_viewer/native_ar_viewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../../../core/constant/strings.dart';

String documentDirectoryPath = "";
String iosAssetPath = '';
String taskId = '';

class ProductDetailsView extends StatefulWidget {
  final Product product;
  const ProductDetailsView({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  int _currentIndex = 0;
  late PriceTag _selectedPriceTag;

  @override
  void initState() {
    _selectedPriceTag = widget.product.priceTags.first;
    super.initState();
  }

  _downloadAssetsForIOS(String name) async {
    await _prepareSaveDir();
    taskId = (await FlutterDownloader.enqueue(
        url: "$modelURL/$name.usdz",
        savedDir: documentDirectoryPath))!;
    // print('taskId = $taskId');
  }

  Future<void> _prepareSaveDir() async {
    documentDirectoryPath = (await _findLocalPath())!;
    final savedDir = io.Directory(documentDirectoryPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async =>
      (await getApplicationDocumentsDirectory()).path;

  _launchAR(String name) async {
    if (io.Platform.isAndroid) {
      await NativeArViewer.launchAR("$modelURL/$name.glb");
    } else if (io.Platform.isIOS) {
      await _downloadAssetsForIOS(name);
      await NativeArViewer.launchAR("$documentDirectoryPath/$name.usdz");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Platform not supported')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: const Color(0xffe9e8ca),
        backgroundColor: const Color(0xff6c8737),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.message)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).width,
            // NEED TO MODIFY THIS CHILD, ADDED STACK AND POSITIONED

            child: Stack(children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: double.infinity,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: widget.product.images.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Hero(
                        tag: widget.product.id,
                        child: CachedNetworkImage(
                          imageUrl: image,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(
                                    Colors.grey.shade50.withOpacity(0.25),
                                    BlendMode.softLight),
                              ),
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Positioned(
                bottom: 16.0, // Adjust the bottom margin as needed
                right: 16.0, // Adjust the right margin as needed
                child: GestureDetector(
                  onTap: () {
                    _launchAR(widget.product.name);
                  },
                  child: Container(
                    width: 50.0, // Adjust the button size as needed
                    height: 50.0, // Adjust the button size as needed
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(
                          0xffe9e8ca), // Adjust the button color as needed
                    ),
                    child:
                        Image.asset('assets/Model3D/ControlAR.png', height: 50),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Align(
              alignment: Alignment.center,
              child: AnimatedSmoothIndicator(
                activeIndex: _currentIndex,
                count: widget.product.images.length,
                effect: ScrollingDotsEffect(
                    dotColor: Colors.grey.shade300,
                    maxVisibleDots: 7,
                    activeDotColor: Colors.grey,
                    dotHeight: 6,
                    dotWidth: 6,
                    activeDotScale: 1.1,
                    spacing: 6),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 14, top: 20, bottom: 4),
            child: Text(
              widget.product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Wrap(
              children: widget.product.priceTags
                  .map((priceTag) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPriceTag = priceTag;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: _selectedPriceTag.id == priceTag.id
                                  ? 2.0
                                  : 1.0,
                              color: _selectedPriceTag.id == priceTag.id
                                  ? const Color(0xff6c8737)
                                  : Colors.grey,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 4),
                          child: Column(
                            children: [
                              Text(priceTag.name),
                              Text("\$" + priceTag.price.toString()),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 10,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom),
            child: Text(
              widget.product.description,
              style: const TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.secondary,
        height: 80 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 10,
          top: 10,
          left: 20,
          right: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  '\$${_selectedPriceTag.price}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 120,
              child: InputFormButton(
                onClick: () {
                  context.read<CartBloc>().add(AddProduct(
                      cartItem: CartItem(
                          product: widget.product,
                          priceTag: _selectedPriceTag)));
                  // print("test");
                  Navigator.pop(context);
                },
                titleText: "Add to Cart",
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            SizedBox(
              width: 90,
              child: InputFormButton(
                onClick: () {
                  Navigator.of(context)
                      .pushNamed(AppRouter.orderCheckout, arguments: [
                    CartItem(
                      product: widget.product,
                      priceTag: _selectedPriceTag,
                    )
                  ]);
                },
                titleText: "Buy",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
