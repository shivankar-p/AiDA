import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amazon_clone_bloc/src/config/router/app_route_constants.dart';
import 'package:flutter_amazon_clone_bloc/src/data/models/product.dart';
import 'package:flutter_amazon_clone_bloc/src/data/repositories/account_repository.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/keep_shopping_for/cubit/keep_shopping_for_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/account/wish_list/wish_list_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/cart/cart_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/home_blocs/carousel_bloc/carousel_image_bloc.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/product_details/averageRating/average_rating_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/product_details/user_rating/user_rating_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/logic/blocs/user_cubit/user_cubit.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/ar/ar_view_screen.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_app_bar.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/custom_elevated_button.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/divider_with_sizedbox.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/common_widgets/stars.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/home/custom_carousel_slider.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/home/dots_indicator.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/customer_ratings.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/product_features.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/product_quality_icons.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/widgets/product_details/you_might_also_like.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/strings.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/constants/constants.dart';
import 'package:flutter_amazon_clone_bloc/src/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/product_carousel/products.dart';
import 'package:flutter_amazon_clone_bloc/src/presentation/views/avatar/avatar_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final String deliveryDate;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
    required this.deliveryDate,
  }) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product product;
  late String deliveryDate;
  late CarouselController controller;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    deliveryDate = widget.deliveryDate;
    controller = CarouselController();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CarouselImageBloc>(context).add(ResetCarouselEvent());
    BlocProvider.of<UserRatingCubit>(context).userRating(product);
    BlocProvider.of<AverageRatingCubit>(context)
        .getProductAverageRating(productId: product.id!);
    BlocProvider.of<WishListCubit>(context).wishList(product: product);
    BlocProvider.of<KeepShoppingForCubit>(context)
        .addToKeepShoppingFor(product: product);

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60), child: CustomAppBar()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    const SizedBox(height: 10),
                    BlocBuilder<CarouselImageBloc, CarouselImageState>(
                      builder: (context, state) {
                        if (state is CarouselImageChangeState) {
                          return CarouselWidget(
                              // key: ValueKey(product.images.length),
                              product: product,
                              controller: controller,
                              currentIndex: state.index);
                        } else {
                          return CarouselWidget(
                              product: product,
                              controller: controller,
                              currentIndex: 0);
                        }
                      },
                    ),
                    Positioned(
                      bottom: 30,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: BlocBuilder<WishListCubit, WishListState>(
                          builder: (context, state) {
                            if (state is GetWishListLoadingS) {
                              return const SizedBox();
                            }

                            if (state is NotAddedToWishListS) {
                              return WishListIcon(
                                iconColor: Colors.grey,
                                product: product,
                                onPressed: () {
                                  context
                                      .read<WishListCubit>()
                                      .addToWishList(product: product);
                                },
                              );
                            }
                            if (state is AddedToWishListS) {
                              return WishListIcon(
                                iconColor: Colors.red,
                                product: product,
                                onPressed: () {
                                  context
                                      .read<WishListCubit>()
                                      .deleteFromWishList(product: product);
                                },
                              );
                            }
                            if (state is DeletedFromWishListS) {
                              return WishListIcon(
                                iconColor: Colors.grey,
                                product: product,
                                onPressed: () {
                                  context
                                      .read<WishListCubit>()
                                      .addToWishList(product: product);
                                },
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                    if (product.category == 'Furniture')
                      Positioned(
                        bottom: 30,
                        left: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScreenshotWidget()));
                          },
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.orange,
                          ),
                          child: Icon(
                            Icons.view_in_ar, // Custom AR icon
                            color: Colors.white, // Icon color
                          ),
                        ),
                      ),
                    if (product.category == 'Fashion')
                      Positioned(
                        bottom: 30,
                        left: 30,
                        child: ElevatedButton(
                          onPressed: () async {
                            // await openFilePicker(product);
                            // var imgs = product.images;
                            // context.read<CarouselImageBloc>().add(
                            //     CarouselImageChangedEvent(
                            //         index: imgs.length - 1));
                            // context.pushNamed(
                            //   AppRouteConstants.productCarouselScreenRoute.name,
                            // );
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProductCarouselScreen()));
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             (AvatarScreen())));
                          },
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.orange,
                          ),
                          child: Icon(
                            Icons.checkroom, // Custom AR icon
                            color: Colors.white, // Icon color
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Visit the Store',
                      style: TextStyle(color: Constants.selectedNavBarColor),
                    ),
                    BlocBuilder<AverageRatingCubit, AverageRatingState>(
                      builder: (context, state) {
                        if (state is AverageRatingLoadingS) {
                          return const SizedBox();
                        }
                        if (state is AverageRatingSuccessS) {
                          return Row(
                            children: [
                              Text(state.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87)),
                              const SizedBox(width: 4),
                              Stars(rating: state.averageRating),
                              const SizedBox(width: 6),
                              Text(
                                state.averageRatingLength.toString(),
                                style: TextStyle(
                                  color: Constants.selectedNavBarColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const DividerWithSizedBox(),
            priceEmi(),
            const DividerWithSizedBox(
              sB1Height: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Total: ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: '₹${formatPrice(product.price)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                      text: 'FREE delivery ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Constants.selectedNavBarColor,
                      ),
                      children: [
                        TextSpan(
                          text: deliveryDate,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        if (state is UserSuccessS) {
                          if (state.user.address != '') {
                            return Expanded(
                              child: Text(
                                'Deliver to ${capitalizeFirstLetter(string: state.user.name)} - ${state.user.address}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Constants.selectedNavBarColor),
                              ),
                            );
                          } else {
                            return Expanded(
                              child: Text(
                                'Deliver to ${state.user.name} ',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Constants.selectedNavBarColor),
                              ),
                            );
                          }
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'In stock',
                  style: TextStyle(color: Constants.greenColor, fontSize: 16),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomElevatedButton(
                    buttonText: 'Add to Cart',
                    onPressed: () {
                      context.read<CartBloc>().add(AddToCart(product: product));
                      showSnackBar(context, 'Added to cart!');
                    }),
                const SizedBox(
                  height: 10,
                ),
                CustomElevatedButton(
                  buttonText: 'Buy Now',
                  onPressed: () {
                    context.pushReplacementNamed(
                        AppRouteConstants.buyNowPaymentScreenRoute.name,
                        extra: {
                          'product': product,
                        });
                  },
                  color: Constants.secondaryColor,
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Secure transaction',
                      style: TextStyle(
                          color: Constants.selectedNavBarColor, fontSize: 15),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gift-wrap available.',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 14),
                BlocBuilder<WishListCubit, WishListState>(
                  builder: (context, state) {
                    return InkWell(
                      onTap: () async {
                        if (state is AddedToWishListS) {
                          return showSnackBar(context,
                              'This product is already in your wish list');
                        } else {
                          await context
                              .read<WishListCubit>()
                              .addToWishList(product: product);
                          if (context.mounted) {
                            showSnackBar(context, ' Added to wishlist!');
                          }
                        }
                      },
                      child: Text(
                        'Add to Wish List',
                        style: TextStyle(
                            color: Constants.selectedNavBarColor, fontSize: 15),
                      ),
                    );
                  },
                ),
              ],
            ),
            const DividerWithSizedBox(),
            const ProductQualityIcons(),
            const DividerWithSizedBox(
              sB1Height: 4,
              sB2Height: 6,
            ),
            ProductFeatures(product: product),
            const DividerWithSizedBox(),
            BlocBuilder<AverageRatingCubit, AverageRatingState>(
              builder: (context, state) {
                if (state is AverageRatingLoadingS) {
                  return CustomerReviews(averageRating: 0, product: product);
                }
                if (state is AverageRatingSuccessS) {
                  return CustomerReviews(
                      averageRating: state.averageRating, product: product);
                }
                return CustomerReviews(averageRating: 0, product: product);
              },
            ),
            const DividerWithSizedBox(),

            // userRating == -1
            //     ? const SizedBox()
            //     :
            BlocConsumer<UserRatingCubit, UserRatingState>(
                listener: (context, state) {
              if (state is UserRatingErrorS) {
                showSnackBar(context, state.errorString);
              }
            }, builder: (context, state) {
              if (state is UpdateUserRatingInitialS) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is UserRatingSuccessS) {
                if (state.userRating == -1) {
                  return const SizedBox();
                } else {
                  return ratingFromUser(context, state.userRating, product);
                }
              } else {
                if (state is UpdateUserRatingSuccessS) {
                  return ratingFromUser(context, state.userRating, product);
                }
              }
              return const SizedBox();
            }),

            const YouMightAlsoLike(),
          ]),
        ),
      ),
    );
  }

  Column ratingFromUser(
      BuildContext context, double userRating, Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your star rating!',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        RatingBar.builder(
            itemSize: 28,
            initialRating: userRating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Constants.secondaryColor,
                ),
            onRatingUpdate: (rating) {
              BlocProvider.value(
                  value: UserRatingCubit(AccountRepository())
                    ..updateUserRating(userRating: rating, product: product));
            }),
        const DividerWithSizedBox(),
      ],
    );
  }

  Column priceEmi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '₹',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              formatPrice(product.price),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        RichText(
          text: TextSpan(
            text: 'EMI ',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(
                text: 'from ₹${getEmi(product)}. No Cost EMI available.',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' EMI options',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Constants.selectedNavBarColor,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Inclusive of all texes',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class CarouselWidget extends StatelessWidget {
  const CarouselWidget({
    super.key,
    required this.currentIndex,
    required this.product,
    required this.controller,
  });

  final int currentIndex;
  final Product product;
  final CarouselController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomCarouselSliderList(
            onPageChanged: (index, reason) {
              BlocProvider.of<CarouselImageBloc>(context)
                  .add(CarouselImageChangedEvent(index: index));
            },
            sliderImages: product.images),
        DotsIndicatorList(
            controller: controller,
            current: currentIndex,
            sliderImages: product.images),
      ],
    );
  }
}

class WishListIcon extends StatelessWidget {
  const WishListIcon({
    super.key,
    required this.product,
    required this.onPressed,
    required this.iconColor,
  });

  final Product product;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: InkWell(
      onTap: onPressed,
      child: Icon(
        Icons.favorite,
        color: iconColor,
        size: 38,
      ),
    )
        // : InkWell(
        //     onTap: () {
        //       context
        //           .read<WishListCubit>()
        //           .addToWishList(product: product);
        //     },
        //     child: const Icon(
        //       Icons.favorite_border,
        //       color: Colors.grey,
        //       size: 30,
        //     ),
        //   ),
        );
  }
}

Future<void> openFilePicker(Product product) async {
  try {
    print(product.id);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        File file = File(filePath);
        List<int> fileBytes = await file.readAsBytes();
        String fileName = file.path.split('/').last;

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://172.16.202.52:8888/tryon'),
        );

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ));

        request.fields['cloth_path'] = product.id!;
        print("Sent request to Tryon API");
        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print('Tryon returned successfully');

          var responseBody = await response.stream.bytesToString();
          var responseData = jsonDecode(responseBody);

          // Call the product image API
          await addImagetoDB(product, responseData['generated_image']);
        } else {
          print('Error uploading file: ${response}');
        }
      }
    } else {
      print("User didn't pick a file.");
    }
  } catch (e) {
    print('Error picking/sending file: $e');
  }
}

// Function to call the product image API
Future<void> addImagetoDB(Product product, String? imageUrl) async {
  print(product.id);
  print(imageUrl);
  // print(Uri.parse(addimgtoProductUri + '/' + productId));
  // print(addimgtoProductUri + '/' + productId);

  try {
    final client = http.Client();
    String token = await getToken();
    var response = await client.post(
      Uri.parse(addimgtoProductUri), // Add the product image API endpoint here
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
      body: jsonEncode({'id': product.id, 'image': imageUrl}),
    );

    if (response.statusCode == 200) {
      print('Product image added successfully');
      product.images.add(imageUrl!);
      Fluttertoast.showToast(
        msg: 'Tryon Generated Successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity:
            ToastGravity.BOTTOM, // Position the toast at the top of the screen
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
    } else {
      print('Error adding product image: ${response.body}');
    }
  } catch (e) {
    print('Error calling product image API: $e');
  }
}
