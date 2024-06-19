import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Define the states
abstract class CarouselImageState {}

class CarouselImageInitialState extends CarouselImageState {}

class CarouselImageChangeState extends CarouselImageState {
  final int index;
  CarouselImageChangeState(this.index);
}

class CarouselImageProductState extends CarouselImageState {
  final String product;
  CarouselImageProductState(this.product);
}

// Define the events
abstract class CarouselImageEvent {}

class ChangeCarouselImageEvent extends CarouselImageEvent {
  final int newIndex;
  ChangeCarouselImageEvent(this.newIndex);
}

class UpdateProductEvent extends CarouselImageEvent {
  final String newProduct;
  UpdateProductEvent(this.newProduct);
}

// Define the Bloc
class CarouselImageBloc extends Bloc<CarouselImageEvent, CarouselImageState> {
  CarouselImageBloc() : super(CarouselImageInitialState());

  @override
  Stream<CarouselImageState> mapEventToState(CarouselImageEvent event) async* {
    if (event is ChangeCarouselImageEvent) {
      yield CarouselImageChangeState(event.newIndex);
    } else if (event is UpdateProductEvent) {
      yield CarouselImageProductState(event.newProduct);
    }
  }
}

// Dummy CarouselWidget for demonstration
class CarouselWidget extends StatelessWidget {
  final String product;
  final PageController controller;
  final int currentIndex;

  CarouselWidget(
      {required this.product,
      required this.controller,
      required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Product: $product'),
          Text('Current Index: $currentIndex'),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => CarouselImageBloc(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('BlocBuilder Example'),
          ),
          body: BlocBuilder<CarouselImageBloc, CarouselImageState>(
            builder: (context, state) {
              String product = "Initial Product";
              int currentIndex = 0;

              if (state is CarouselImageProductState) {
                product = state.product;
              } else if (state is CarouselImageChangeState) {
                currentIndex = state.index;
              }

              return CarouselWidget(
                product: product,
                controller: controller,
                currentIndex: currentIndex,
              );
            },
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  // Change the product to trigger a rebuild
                  context
                      .read<CarouselImageBloc>()
                      .add(UpdateProductEvent("New Product"));
                },
                child: Icon(Icons.update),
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () {
                  // Change the index to trigger a rebuild
                  context
                      .read<CarouselImageBloc>()
                      .add(ChangeCarouselImageEvent(1));
                },
                child: Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
