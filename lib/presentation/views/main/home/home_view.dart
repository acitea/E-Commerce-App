import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constant/images.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/usecases/product/get_product_usecase.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/user/user_bloc.dart';
import '../../../widgets/product_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: (MediaQuery.of(context).padding.top + 10),
            ),
            BlocBuilder<UserBloc, UserState>(builder: (context, state) {
              if (state is UserLogged) {
                return Row(
                  children: [
                    Text(
                      "${state.user.firstName} ${state.user.lastName}",
                      style: const TextStyle(fontSize: 26),
                    ),
                    Spacer(),
                    SizedBox(
                      width: 8,
                    ),
                    const CircleAvatar(
                      radius: 24.0,
                      backgroundImage: AssetImage('assets/dev/user.jpg'),
                      backgroundColor: Colors.transparent,
                    )
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Welcome,",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 36),
                        ),
                        Text(
                          "E-Shop mobile store",
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 22),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.signIn);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 24.0,
                          backgroundImage: AssetImage(kUserAvatar),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    )
                  ],
                );
              }
            }),
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
              ),
              child: TextField(
                autofocus: false,
                controller: _textEditingController,
                onChanged: (val) => setState(() {}),
                onSubmitted: (val) => context
                    .read<ProductBloc>()
                    .add(GetProducts(FilterProductParams(keyword: val))),
                decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(left: 20, bottom: 22, top: 22),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.search),
                    ),
                    suffixIcon: _textEditingController.text.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _textEditingController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear)),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    hintText: "Search Product",
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.white, width: 3.0),
                        borderRadius: BorderRadius.circular(32)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide:
                          const BorderSide(color: Colors.white, width: 3.0),
                    )),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                    //Result Empty and No Error
                    if (state is ProductLoaded && state.products.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/status_image/empty.png'),
                          const Text("Products not found!"),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          )
                        ],
                      );
                    }
                    //Error and no preloaded data
                    if (state is ProductError && state.products.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.failure is ServerFailure)
                            Image.asset(
                                'assets/status_image/internal-server-error.png'),
                          if (state.failure is CacheFailure)
                            Image.asset(
                                'assets/status_image/no-connection.png'),
                          const Text("Products not found!"),
                          IconButton(
                              onPressed: () {
                                context.read<ProductBloc>().add(GetProducts(
                                    FilterProductParams(
                                        keyword: _textEditingController.text)));
                              },
                              icon: const Icon(Icons.refresh)),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          )
                        ],
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<ProductBloc>()
                            .add(const GetProducts(FilterProductParams()));
                      },
                      child: GridView.builder(
                        itemCount: state.products.length +
                            ((state is ProductLoading) ? 10 : 0),
                        padding: EdgeInsets.only(
                            top: 14,
                            bottom:
                                (80 + MediaQuery.of(context).padding.bottom)),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55,
                          crossAxisSpacing: 6,
                        ),
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          if (state.products.length > index) {
                            return ProductCard(
                              product: state.products[index],
                            );
                          }
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade100,
                            highlightColor: Colors.white,
                            child: const ProductCard(),
                          );
                        },
                      ),
                    );
                  })),
            )
          ],
        ),
      ),
    );
  }
}