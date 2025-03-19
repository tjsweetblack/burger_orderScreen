import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'dart:js' as js; // Import the dart:js library

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});
  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  late Stream<QuerySnapshot> _ordersStream;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('kitchenStatus', isEqualTo: 'queue')
        .orderBy('dateCreated',
            descending: false) // Order by dateCreated ascending
        .snapshots();
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 300,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openMap(double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      js.context.callMethod('open', [url]); // Open the URL in a new tab
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location data is not available.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _scrollLeft,
              child: const Icon(Icons.arrow_left),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _ordersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print("Error fetching orders: ${snapshot.error}");
                  return Center(
                      child: Text('Something went wrong: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Waiting for orders...");
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  print("No order data available.");
                  return const Center(child: Text("No orders in the queue."));
                }

                final orders = snapshot.data!.docs;
                print("Number of orders in queue: ${orders.length}");

                return Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final orderData =
                          orders[index].data() as Map<String, dynamic>;
                      final orderId = orders[index].id;
                      print(
                          "Processing order with ID: $orderId, Data: $orderData");

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getUserData(orderData['userId']),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            print(
                                "Waiting for user data for user ID: ${orderData['userId']}");
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!userSnapshot.hasData ||
                              userSnapshot.data == null) {
                            print(
                                "User data not available for user ID: ${orderData['userId']}");
                            return const Text("User data not available");
                          }

                          final userData = userSnapshot.data!;
                          print("User data fetched: $userData");

                          return FutureBuilder<List<Widget>>(
                            future: _getBurgerItemsDisplay(
                                orderData['items'] as List),
                            builder: (context, burgerSnapshot) {
                              if (burgerSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                print(
                                    "Waiting for burger items display for order ID: $orderId");
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!burgerSnapshot.hasData ||
                                  burgerSnapshot.data == null) {
                                print(
                                    "Burger items display not available for order ID: $orderId");
                                return const Text("Burger names not available");
                              }

                              final itemsDisplay = burgerSnapshot.data!;
                              print(
                                  "Burger items display created with ${itemsDisplay.length} widgets for order ID: $orderId");

                              print(
                                  "Fetching side items for order ID: $orderId, Sides data: ${orderData['sides']}");
                              return FutureBuilder<List<Widget>>(
                                future: _getSideItemsDisplay(
                                    orderData['sides'] as List?),
                                builder: (context, sideSnapshot) {
                                  print(
                                      "FutureBuilder for sides snapshot (Order ID: $orderId): ${sideSnapshot.connectionState}");
                                  if (sideSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _buildOrderColumn(
                                      order: orderData,
                                      orderId: orderId,
                                      itemsDisplay: itemsDisplay,
                                      userName: userData['name'],
                                      userPhoneNumber: userData[
                                          'phoneNumber'], // Pass phone number
                                      sideItemsDisplay: [],
                                    );
                                  } else if (sideSnapshot.hasError) {
                                    print(
                                        "Error fetching side items: ${sideSnapshot.error}");
                                    return _buildOrderColumn(
                                      order: orderData,
                                      orderId: orderId,
                                      itemsDisplay: itemsDisplay,
                                      userName: userData['name'],
                                      userPhoneNumber: userData[
                                          'phoneNumber'], // Pass phone number
                                      sideItemsDisplay: [],
                                    );
                                  } else if (sideSnapshot.hasData &&
                                      sideSnapshot.data != null) {
                                    final sideItemsDisplay = sideSnapshot.data!;
                                    print(
                                        "Side data received for order ID: $orderId, ${sideItemsDisplay.length} items");
                                    return _buildOrderColumn(
                                      order: orderData,
                                      orderId: orderId,
                                      itemsDisplay: itemsDisplay,
                                      userName: userData['name'],
                                      userPhoneNumber: userData[
                                          'phoneNumber'], // Pass phone number
                                      sideItemsDisplay: sideItemsDisplay,
                                    );
                                  } else {
                                    print(
                                        "No side data or empty list for order ID: $orderId (in final else)");
                                    return _buildOrderColumn(
                                      order: orderData,
                                      orderId: orderId,
                                      itemsDisplay: itemsDisplay,
                                      userName: userData['name'],
                                      userPhoneNumber: userData[
                                          'phoneNumber'], // Pass phone number
                                      sideItemsDisplay: [],
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _scrollRight,
              child: const Icon(Icons.arrow_right),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    print("Fetching user data for ID: $userId");
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = doc.data() as Map<String, dynamic>;
    print("User data fetched for ID $userId: $data");
    return data;
  }

  Future<List<Widget>> _getBurgerItemsDisplay(List items) async {
    print("Inside _getBurgerItemsDisplay with items: $items");
    List<Widget> itemWidgets = [];
    for (var item in items) {
      print("Processing burger item: $item");
      final burgerDoc = await FirebaseFirestore.instance
          .collection('burgers')
          .doc(item['productId'])
          .get();
      print(
          "Fetched burger document for ID '${item['productId']}': ${burgerDoc.exists ? burgerDoc.data() : 'Not found'}");
      String burgerName = "Product ID: ${item['productId']}";
      String? burgerImageUrl;
      int burgerPrice = 0;
      List<String> burgerIngredients = [];

      if (burgerDoc.exists) {
        final burgerData = burgerDoc.data() as Map<String, dynamic>;
        burgerName = "${burgerData['name']}";
        burgerImageUrl = burgerData['imageUrl'];
        burgerPrice = burgerData['price'] ?? 0;
        if (burgerData.containsKey('custom') && burgerData['custom'] == true) {
          if (burgerData.containsKey('ingredients') &&
              burgerData['ingredients'] is List) {
            burgerIngredients = List<String>.from(burgerData['ingredients']);
          }
        }
      }

      itemWidgets.add(
        Row(
          children: [
            Text("${item['quantity']}x "),
            if (burgerImageUrl != null)
              Image.network(burgerImageUrl, width: 20, height: 20)
            else
              const SizedBox(width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
                "$burgerName (${NumberFormat.currency(symbol: '', decimalDigits: 0).format(burgerPrice)})"),
          ],
        ),
      );

      if (burgerIngredients.isNotEmpty) {
        itemWidgets.add(const Text("\tBurger Ingredients:",
            style: TextStyle(fontWeight: FontWeight.bold)));
        for (var ingredientId in burgerIngredients) {
          final ingredientDoc = await FirebaseFirestore.instance
              .collection('ingredients')
              .doc(ingredientId)
              .get();
          String ingredientName = "Ingredient ID: $ingredientId";
          String? imageUrl;
          int ingredientPrice = 0;
          if (ingredientDoc.exists) {
            final ingredientData = ingredientDoc.data() as Map<String, dynamic>;
            ingredientName = ingredientData['name'];
            imageUrl = ingredientData['imageUrl'];
            ingredientPrice = ingredientData['price'] ?? 0;
          }
          itemWidgets.add(Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                if (imageUrl != null)
                  Image.network(imageUrl, width: 20, height: 20)
                else
                  const SizedBox(width: 20, height: 20),
                const SizedBox(width: 8),
                Text(
                    "$ingredientName (${NumberFormat.currency(symbol: '', decimalDigits: 0).format(ingredientPrice)})"),
              ],
            ),
          ));
        }
      }

      if (item.containsKey('extras') && item['extras'] != null) {
        final extras = item['extras'] as List<dynamic>;
        if (extras.isNotEmpty) {
          itemWidgets.add(const Text("\tExtras:",
              style: TextStyle(fontWeight: FontWeight.bold)));
          Map<String, int> extraCounts = {};
          for (var extraId in extras) {
            extraCounts[extraId] = (extraCounts[extraId] ?? 0) + 1;
          }
          for (var extraId in extraCounts.keys) {
            final ingredientDoc = await FirebaseFirestore.instance
                .collection('ingredients')
                .doc(extraId)
                .get();
            String extraName = "Extra ID: $extraId";
            String? imageUrl;
            int extraPrice = 0;
            if (ingredientDoc.exists) {
              final ingredientData =
                  ingredientDoc.data() as Map<String, dynamic>;
              extraName = ingredientData['name'];
              imageUrl = ingredientData['imageUrl'];
              extraPrice = ingredientData['price'] ?? 0;
            }
            itemWidgets.add(Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  Text("${extraCounts[extraId]}x "),
                  if (imageUrl != null)
                    Image.network(imageUrl, width: 20, height: 20)
                  else
                    const SizedBox(width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text(
                      "$extraName (${NumberFormat.currency(symbol: '', decimalDigits: 0).format(extraPrice)})"),
                ],
              ),
            ));
          }
        }
      }
    }
    print("Returning burger item widgets: ${itemWidgets.length}");
    return itemWidgets;
  }

  Future<List<Widget>> _getSideItemsDisplay(List? sides) async {
    print("Inside _getSideItemsDisplay with sides: $sides");
    List<Widget> sideWidgets = [];
    if (sides != null) {
      for (var sideItem in sides) {
        print("Processing side item: $sideItem");
        final sideDoc = await FirebaseFirestore.instance
            .collection('sides')
            .doc(sideItem['sideId'])
            .get();
        print(
            "Fetched side document for ID '${sideItem['sideId']}': ${sideDoc.exists ? sideDoc.data() : 'Not found'}");
        String sideName = "Side ID: ${sideItem['sideId']}";
        String? sideImageUrl;
        int sidePrice = 0;

        if (sideDoc.exists) {
          final sideData = sideDoc.data() as Map<String, dynamic>;
          sideName = "${sideData['name']}";
          sideImageUrl = sideData['imageUrl'];
          sidePrice = sideData['price'] ?? 0;
        }

        final sideRow = Row(
          children: [
            Text("${sideItem['quantity']}x "),
            if (sideImageUrl != null)
              Image.network(sideImageUrl, width: 20, height: 20)
            else
              const SizedBox(width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
                "$sideName (${NumberFormat.currency(symbol: '', decimalDigits: 0).format(sidePrice)})"),
            const SizedBox(width: 8),
          ],
        );
        print("Created side widget: $sideRow");
        sideWidgets.add(sideRow);
      }
    }
    print("Returning side widgets: ${sideWidgets.length}");
    return sideWidgets;
  }

  Widget _buildOrderColumn({
    required Map<String, dynamic> order,
    required String orderId,
    required List<Widget> itemsDisplay,
    required String userName,
    required String? userPhoneNumber, // Add userPhoneNumber parameter
    required List<Widget> sideItemsDisplay,
  }) {
    final dateCreated = order['dateCreated'] as Timestamp?;
    final totalPrice = order['totalPrice'];
    final paymentMethod = order['paymentMethod'];
    int sidesTotalPrice = order['sidesTotalPrice'] ?? 0;
    final latitude = order['latitude'] as double?;
    final longitude = order['longitude'] as double?;

    if (order['sides'] != null && order['sides'] is List) {
      for (var item in (order['sides'] as List)) {
        print("Order ID: $orderId, Side Item in Order: $item");
      }
    }
    print("Building order column for ID: $orderId");
    print(
        "Total Price: $totalPrice, Payment Method: $paymentMethod, Sides Total Price: $sidesTotalPrice");
    print("Number of burger items to display: ${itemsDisplay.length}");
    print("Number of side items to display: ${sideItemsDisplay.length}");

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Number",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("#${order['orderNumber'] ?? orderId}"),
            const SizedBox(height: 8),
            Text("Username",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(userName),
            const SizedBox(height: 8),
            Text("Phone Number",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(userPhoneNumber ?? 'N/A'), // Display phone number
            const SizedBox(height: 8),
            Text("Shipping Address",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(order['shippingAddress'] ?? 'N/A'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _openMap(latitude, longitude),
              child: const Text('See in Map'),
            ),
            const SizedBox(height: 8),
            Text("Date Created",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (dateCreated != null)
              Text(DateFormat('yyyy-MM-dd HH:mm').format(dateCreated.toDate())),
            const SizedBox(height: 8),
            Text("Payment Method",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(paymentMethod ?? 'N/A'),
            const SizedBox(height: 8),
            Text("Total Price",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(NumberFormat.currency(symbol: 'AOA ', decimalDigits: 0)
                .format(totalPrice)),
            const SizedBox(height: 8),
            Text("Items", style: const TextStyle(fontWeight: FontWeight.bold)),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: itemsDisplay,
              ),
            ),
            if (sideItemsDisplay.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text("Sides",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sideItemsDisplay,
                ),
              ),
              const SizedBox(height: 8),
              Text("Sides Total Price",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(NumberFormat.currency(symbol: 'AOA ', decimalDigits: 0)
                  .format(sidesTotalPrice)),
            ],
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _startCooking(
                      orderId, order, itemsDisplay, userName, dateCreated);
                },
                child: const Text("START COOKING"),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _startCooking(
                      orderId, order, itemsDisplay, userName, dateCreated);
                },
                child: const Text("cancel order"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startCooking(
      String orderId,
      Map<String, dynamic> order,
      List<Widget> itemsDisplay,
      String userName,
      Timestamp? dateCreated) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'kitchenStatus': 'cooking'});
  }
}
