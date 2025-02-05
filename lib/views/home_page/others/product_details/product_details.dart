import 'package:carousel_slider/carousel_slider.dart';
import 'package:eat_incredible_app/controller/cart/cart_bloc.dart';
import 'package:eat_incredible_app/controller/cart/cart_details/cart_details_bloc.dart';
import 'package:eat_incredible_app/controller/product_details/product_details_bloc.dart';
import 'package:eat_incredible_app/controller/product_list/product_list_bloc.dart';
import 'package:eat_incredible_app/utils/barrel.dart';
import 'package:eat_incredible_app/utils/messsenger.dart';
import 'package:eat_incredible_app/views/home_page/others/cart_page/cart_page.dart';
import 'package:eat_incredible_app/widgets/addtocart/addtocart_bar.dart';
import 'package:eat_incredible_app/widgets/banner/custom_banner.dart';
import 'package:eat_incredible_app/widgets/product_card/product_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class ProductDetails extends StatefulWidget {
  final String productId;
  final String catId;
  const ProductDetails(
      {super.key, required this.productId, required this.catId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int current = 0;
  final CarouselController controller = CarouselController();
  ProductDetailsBloc productDetailsBloc = ProductDetailsBloc();

  @override
  void initState() {
    getData();
    super.initState();
  }

  //* call the product details api and get the data from the api
  void getData() {
    productDetailsBloc.add(
        ProductDetailsEvent.getproductdetails(productId: widget.productId));
    context
        .read<ProductListBloc>()
        .add(ProductListEvent.fetchProductList(categoryId: widget.catId));
    context
        .read<CartDetailsBloc>()
        .add(const CartDetailsEvent.getCartDetails());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          getData();
          return Future.value();
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            BlocConsumer<ProductDetailsBloc, ProductDetailsState>(
              bloc: productDetailsBloc,
              listener: (context, state) {
                state.when(
                    initial: () {},
                    loading: () {},
                    loaded: (_) {},
                    failure: (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e),
                          padding: EdgeInsets.symmetric(
                              vertical: 4.6.h, horizontal: 20.w),
                          action: SnackBarAction(
                            label: 'Retry',
                            onPressed: () {
                              context.read<ProductDetailsBloc>().add(
                                  ProductDetailsEvent.getproductdetails(
                                      productId: widget.productId));
                            },
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 29, 30, 29),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    });
              },
              builder: (context, state) {
                return state.maybeWhen(
                  orElse: () {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Shimmer.fromColors(
                          baseColor: const Color.fromARGB(44, 222, 220, 220),
                          highlightColor: Colors.grey[100]!,
                          child: Image.asset(
                            "assets/images/product_details.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                  loaded: (productdetails) {
                    return SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //* Banner ============== >
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: CarouselSlider(
                                carouselController: controller,
                                options: CarouselOptions(
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  reverse: false,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 10),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 1000),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enlargeCenterPage: true,
                                  scrollDirection: Axis.horizontal,
                                  height: 200.h,
                                  viewportFraction: 1.0,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      current = index;
                                    });
                                  },
                                ),
                                items: [
                                  productdetails[0].thumbnail.toString(),
                                ].map((i) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                          width: double.infinity,
                                          color: const Color.fromRGBO(
                                              245, 239, 240, 1),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: CustomPic(
                                            imageUrl: i,
                                            height: 200.h,
                                            width: double.infinity,
                                          ));
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                productdetails[0].thumbnail.toString(),
                              ].asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () =>
                                      controller.animateToPage(entry.key),
                                  child: Container(
                                    width: 9.sp,
                                    height: 9.sp,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 7.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: current == entry.key
                                            ? const Color.fromRGBO(
                                                226, 10, 19, 1)
                                            : const Color.fromRGBO(
                                                223, 223, 223, 1)),
                                  ),
                                );
                              }).toList(),
                            ),
                            //* Banner ============== >
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 11.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    productdetails[0].productName.toString(),
                                    style: GoogleFonts.poppins(
                                        color:
                                            const Color.fromRGBO(44, 44, 44, 1),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.share,
                                        color: const Color.fromRGBO(0, 0, 0, 1),
                                        size: 14.sp,
                                      ))
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 13.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productdetails[0].weight.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color.fromRGBO(
                                                148, 148, 148, 1)),
                                      ),
                                      Text(
                                        "₹ ${productdetails[0].salePrice.toString()}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromRGBO(
                                                44, 44, 44, 1)),
                                      ),
                                    ],
                                  ),
                                  productdetails[0].iscart == false
                                      ? BlocConsumer<CartBloc, CartState>(
                                          listener: (context, state) {
                                            state.when(
                                                initial: () {},
                                                loading: (productId) {},
                                                success: (msg, producId) {
                                                  getData();
                                                },
                                                failure: (error) {});
                                          },
                                          builder: (context, state) {
                                            return state.maybeWhen(
                                              orElse: () {
                                                return GestureDetector(
                                                  onTap: (() {
                                                    context
                                                        .read<CartBloc>()
                                                        .add(
                                                            CartEvent.addToCart(
                                                          productid:
                                                              productdetails[0]
                                                                  .id
                                                                  .toString(),
                                                        ));
                                                  }),
                                                  child: Container(
                                                    height: 24.h,
                                                    width: 60.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                      border: Border.all(
                                                          color: const Color
                                                                  .fromRGBO(
                                                              2, 160, 8, 1)),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Add",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins',
                                                            fontSize: 10.sp,
                                                            color: const Color
                                                                    .fromRGBO(
                                                                2, 160, 8, 1),
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              loading: (productId) {
                                                return Center(
                                                  child: Container(
                                                    height: 24.h,
                                                    width: 60.w,
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                      border: Border.all(
                                                          color: const Color
                                                                  .fromRGBO(
                                                              2, 160, 8, 1)),
                                                    ),
                                                    child: Center(
                                                      child:
                                                          CupertinoActivityIndicator(
                                                        radius: 8.sp,
                                                        color: const Color
                                                                .fromARGB(
                                                            162, 2, 160, 7),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        )
                                      : GestureDetector(
                                          onTap: (() {
                                            Get.to(() => const CartPage());
                                          }),
                                          child: Container(
                                            height: 24.h,
                                            width: 60.w,
                                            decoration: BoxDecoration(
                                              color: const Color.fromRGBO(
                                                  2, 160, 8, 1),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      2, 160, 8, 1)),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "View cart",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 10.sp,
                                                    color: const Color.fromARGB(
                                                        255, 255, 255, 255),
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 13.w, vertical: 12.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Product Details',
                                    style: GoogleFonts.poppins(
                                        color:
                                            const Color.fromRGBO(44, 44, 44, 1),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Description',
                                    style: GoogleFonts.poppins(
                                        color:
                                            const Color.fromRGBO(44, 44, 44, 1),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  ReadMoreText(
                                    productdetails[0].description.toString(),
                                    trimLines: 4,
                                    colorClickableText:
                                        const Color.fromARGB(192, 226, 10, 17),
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'Show more',
                                    trimExpandedText: ' Show less',
                                    moreStyle: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.normal,
                                      color:
                                          const Color.fromRGBO(226, 10, 19, 1),
                                    ),
                                    style: GoogleFonts.poppins(
                                        color: const Color.fromRGBO(
                                            148, 148, 148, 1),
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  Text(
                                    'View Similar Items',
                                    style: GoogleFonts.poppins(
                                        color: const Color.fromRGBO(0, 0, 0, 1),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                ],
                              ),
                            ),
                            BlocConsumer<ProductListBloc, ProductListState>(
                              bloc: context.read<ProductListBloc>(),
                              listener: (context, state) {
                                state.when(
                                    initial: () {},
                                    loading: () {},
                                    loaded: (_) {},
                                    failure: (e) {
                                      CustomSnackbar.flutterSnackbarWithAction(
                                          e, 'Retry', () {
                                        context.read<ProductListBloc>().add(
                                            ProductListEvent.fetchProductList(
                                                categoryId: productdetails[0]
                                                    .categoryId
                                                    .toString()));
                                      }, context);
                                    });
                              },
                              builder: (context, state) {
                                return state.maybeWhen(orElse: () {
                                  return SizedBox(
                                    child: Shimmer.fromColors(
                                      baseColor: const Color.fromARGB(
                                          44, 222, 220, 220),
                                      highlightColor: Colors.grey[100]!,
                                      child: Image.asset(
                                        "assets/images/itemList.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }, loaded: (productList) {
                                  return SizedBox(
                                    height: 165.h,
                                    child: ListView.builder(
                                        physics: const BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: productList.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.w),
                                            child: ProductCard(
                                              isCart: productList[index].iscart,
                                              imageUrl: productList[index]
                                                  .thumbnail
                                                  .toString(),
                                              title: productList[index]
                                                  .productName
                                                  .toString(),
                                              disprice: productList[index]
                                                  .originalPrice
                                                  .toString(),
                                              price: productList[index]
                                                  .salePrice
                                                  .toString(),
                                              quantity: productList[index]
                                                  .weight
                                                  .toString(),
                                              cartId: productList[index]
                                                  .categoryId
                                                  .toString(),
                                              percentage: productList[index]
                                                  .discountPercentage
                                                  .toString(),
                                              productId: productList[index]
                                                  .id
                                                  .toString(),
                                              addtocartTap: () {
                                                context.read<CartBloc>().add(
                                                    CartEvent.addToCart(
                                                        productid:
                                                            productList[index]
                                                                .id
                                                                .toString()));
                                              },
                                              ontap: () {
                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //     builder: (context) =>
                                                //         ProductDetails(
                                                //       productId:
                                                //           productList[
                                                //                   index]
                                                //               .id
                                                //               .toString(),
                                                //       catId: productList[
                                                //               index]
                                                //           .categoryId
                                                //           .toString(),
                                                //     ),
                                                //   ),
                                                // );
                                                Navigator.of(context)
                                                    .push(SwipeablePageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ProductDetails(
                                                    productId:
                                                        productList[index]
                                                            .id
                                                            .toString(),
                                                    catId: productList[index]
                                                        .categoryId
                                                        .toString(),
                                                  ),
                                                ));
                                              },
                                            ),
                                          );
                                        }),
                                  );
                                });
                              },
                            ),
                            SizedBox(
                              height: 70.h,
                            )
                          ]),
                    );
                  },
                );
              },
            ),
            BlocConsumer<CartDetailsBloc, CartDetailsState>(
              listener: (context, state) {},
              builder: (context, state) {
                return state.maybeWhen(orElse: () {
                  return const SizedBox();
                }, loaded: (cartDetails) {
                  return cartDetails.totalItem != 0
                      ? Positioned(
                          bottom: 10.h,
                          child: AddtocartBar(
                            iteamCount: cartDetails.totalItem ?? 0,
                            onTap: () {
                              Get.to(() => const CartPage());
                            },
                            totalAmount: cartDetails.totalPrice ?? 0,
                          ),
                        )
                      : const Opacity(
                          opacity: 0.0,
                          child: SizedBox(),
                        );
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
