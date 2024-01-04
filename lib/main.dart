import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/sql_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toggle_switch/toggle_switch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;
  bool _searchBoolean = false;
  bool _bigCard = false;
  int toggle_bigCard = 0;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    print("Количество товаров ${_journals.length}");
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController =
      TextEditingController(); // Добавлено поле discount
  final TextEditingController _inStockController = TextEditingController();
  final TextEditingController _tagsController =
      TextEditingController(); // Добавлено поле tags
  final TextEditingController _ratingController =
      TextEditingController(); // Добавлено поле rating
// Добавлен контроллер для изображения, учитывая, что вы используете BLOB
  final TextEditingController _imageController = TextEditingController();

  final TextEditingController searchController = TextEditingController();

  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _titleController.text,
      _descriptionController.text,
      int.parse(_priceController.text),
      int.parse(_discountController.text), // Парсинг discount
      _inStockController.text,
      _tagsController.text,
      double.parse(_ratingController.text), // Парсинг rating
      // Конвертация изображения в Uint8List (зависит от того, как вы храните изображение в приложении)
      _imageController.text.isNotEmpty
          ? base64Decode(_imageController.text)
          : null,
    );
    _refreshJournals();
  }

  Future<void> _search(String id) async {
    await SQLHelper.searchByName(searchController.text);
    final data = await SQLHelper.searchByName(searchController.text);
    _journals = data;
    _isLoading = false;
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
      id,
      _titleController.text,
      _descriptionController.text,
      int.parse(_priceController.text),
      int.parse(_discountController.text),
      _inStockController.text,
      _tagsController.text,
      double.parse(_ratingController.text),
      _imageController.text.isNotEmpty
          ? base64Decode(_imageController.text)
          : null,
    );
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Товар успешно удален'),
    ));
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
      _priceController.text = existingJournal['price'].toString();
      _discountController.text = existingJournal['discount'].toString();
      _inStockController.text = existingJournal['inStock'];
      _tagsController.text = existingJournal['tags'].toString();
      _ratingController.text = existingJournal['rating'].toString();
      // Предполагается, что изображение хранится в виде строки в формате base64
      _imageController.text = existingJournal['image'] != null
          ? base64Encode(existingJournal['image'])
          : '';
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Название"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: "Описание"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Цена"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _inStockController,
              decoration: const InputDecoration(hintText: "В наличии"),
            ),
            const SizedBox(
              height: 10,
            ),
            // Добавлены новые поля
            TextField(
              controller: _discountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Скидка"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(hintText: "Теги"),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Рейтинг"),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (id == null) {
                    await _addItem();
                  }
                  if (id != null) {
                    await _updateItem(id);
                  }
                  _titleController.text = '';
                  _descriptionController.text = '';
                  _priceController.text = '';
                  _inStockController.text = '';
                  _discountController.text = '';
                  _tagsController.text = '';
                  _ratingController.text = '';
                  Navigator.of(context).pop();
                } catch (e) {
                  // Обработка ошибок при добавлении/обновлении элемента
                  print("Error: $e");
                }
              },
              child: Text(id == null ? 'Добавить товар' : 'Обновить'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final pickedImage =
                      await ImagePicker().getImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    final imageBytes = await pickedImage.readAsBytes();
                    _imageController.text = base64Encode(imageBytes);
                  }
                } catch (e) {
                  // Обработка ошибок при выборе изображения
                  print("Error picking image: $e");
                }
              },
              child: const Text('Выбрать изображение'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFEB),
      body: CustomScrollView(slivers: [
        SliverPersistentHeader(
            floating: true,
            delegate: _SliverAppBarDelegate(
                minHeight: 60,
                maxHeight: 150,
                child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(children: [
                      AppBar(
                          backgroundColor: const Color(0xFFA7CF9B),
                          title: !_searchBoolean
                              ? Text(
                                  'Медведи',
                                  style: TextStyle(color: Color(0xFAFAFAFF)),
                                )
                              : TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                      hintText: "Поиск...",
                                      hintStyle:
                                          TextStyle(color: Color(0xFAFAFAFF)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFAFAFAFF))),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFAFAFAFF)))),
                                  onChanged: (text) async {
                                    await _search(text);
                                  },
                                ),
                          centerTitle: true,
                          leading: IconButton(
                              onPressed: () => {},
                              icon: Transform.flip(
                                  flipX: true,
                                  child: SvgPicture.asset(
                                    'icons/Marker.svg',
                                    color: const Color(0xFAFAFAFF),
                                    height: 30,
                                  ))),
                          actions: !_searchBoolean
                              ? [
                                  IconButton(
                                      iconSize: 30,
                                      icon: Icon(
                                        Icons.search,
                                        color: Color(0xFAFAFAFF),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchBoolean = true;
                                        });
                                      })
                                ]
                              : [
                                  IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Color(0xFAFAFAFF),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _searchBoolean = false;
                                          searchController.clear();
                                          _refreshJournals();
                                        });
                                      })
                                ]),
                      Container(
                          color: Color(0xFFF2FFEB),
                          child: Center(
                              child: ToggleSwitch(
                            minWidth: 50,
                            minHeight: 50,
                            initialLabelIndex: toggle_bigCard,
                            cornerRadius: 20,
                            activeFgColor: Colors.white,
                            inactiveBgColor: Colors.grey,
                            inactiveFgColor: Colors.white,
                            totalSwitches: 2,
                            icons: [Icons.check, Icons.cancel],
                            iconSize: 30,
                            onToggle: (index) {
                              if (index == 0) {
                                _bigCard = false;
                                toggle_bigCard = 0;
                              } else {
                                _bigCard = true;
                                toggle_bigCard = 1;
                              }
                              print('bigCard: $_bigCard');
                              _refreshJournals();
                            },
                          ))),
                    ])))),
        !_bigCard
            ? SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.64),
                itemCount: _journals.length,
                itemBuilder: (context, index) => InkWell(
                    onTap: () {},
                    child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFA7CF9B),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(9, 7, 9, 2),
                              child: Container(
                                  height: 145,
                                  width: 175,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: const Color(0xFF567B59),
                                          width: 3),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: _journals[index]['image'] != null
                                      ? Image.memory(
                                          _journals[index]['image'],
                                          fit: BoxFit.fitHeight,
                                        )
                                      : Container()),
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(9, 1, 9, 25),
                                child: Text(_journals[index]['title'],
                                    style: TextStyle(
                                        fontSize: 16, color: Color(0xFAFAFAFF)),
                                    textAlign: TextAlign.center)),
                            Padding(
                                padding: EdgeInsets.fromLTRB(11, 0, 11, 0),
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFF567B59),
                                          width: 2)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            EdgeInsets.only(left: 4, right: 10),
                                        child: Row(children: <Widget>[
                                          SvgPicture.asset('icons/Rating.svg',
                                              width: 30, height: 25),
                                          SvgPicture.asset('icons/Rating.svg',
                                              width: 30, height: 25),
                                          SvgPicture.asset('icons/Rating.svg',
                                              width: 30, height: 25),
                                          SvgPicture.asset('icons/Rating.svg',
                                              width: 30, height: 25),
                                          SvgPicture.asset('icons/Rating.svg',
                                              width: 30, height: 25)
                                        ]),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: 15),
                                        child: Text(
                                          _journals[index]['rating']
                                              .round()
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFAFAFAFF)),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            Container(
                                margin: EdgeInsets.only(
                                    left: 10, right: 10, top: 8),
                                height: 53,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFF2FFEB),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Flexible(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.only(
                                                    left: 7, top: 3),
                                                child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Text(
                                                      _journals[index]['price']
                                                              .toString() +
                                                          '₽',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                              0xFF567B59)),
                                                    ))),
                                            Container(
                                              padding: EdgeInsets.only(left: 6),
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                    'От ' +
                                                        (_journals[index]
                                                                    ['price'] /
                                                                12)
                                                            .round()
                                                            .toString() +
                                                        '₽/ в мес.',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF567B59))),
                                              ),
                                            )
                                          ])),
                                      Container(
                                          child: IconButton(
                                              iconSize: 30,
                                              icon: Icon(
                                                Icons.info,
                                                color: Color(0xFFA7CF9B),
                                              ),
                                              onPressed: () {}))
                                    ]))
                          ],
                        ))),
              )
            : SliverList.builder(
                itemCount: _journals.length,
                itemBuilder: (context, index) => InkWell(
                    onTap: () {},
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFA7CF9B),
                        ),
                        child: Column(children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(12, 20, 9, 0),
                                    child: Container(
                                        height: 145,
                                        width: 125,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: const Color(0xFF567B59),
                                                width: 3),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: _journals[index]['image'] != null
                                            ? Image.memory(
                                                _journals[index]['image'],
                                                fit: BoxFit.fitHeight,
                                              )
                                            : Container())),
                                Flexible(
                                    child: Column(
                                  children: [
                                    Container(
                                        height: 50,
                                        width: 200,
                                        /*    decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xFF567B59),
                                              width: 3)),  */
                                        padding:
                                            EdgeInsets.fromLTRB(0, 20, 0, 0),
                                        child: Text(
                                          _journals[index]['title'],
                                          style: TextStyle(
                                              fontSize: 21,
                                              color: Color(0xFAFAFAFF)),
                                        )),
                                    Container(
                                        height: 100,
                                        width: 200,
                                        /*       decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xFF567B59),
                                              width: 3)),         */
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          _journals[index]['description'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFAFAFAFF)),
                                        )),
                                  ],
                                ))
                              ]),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF567B59),
                                        width: 3)),
                              ),
                            ],
                          )
                        ]))))
      ]),
      //Большая Карточка

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFA7CF9B),
        focusColor: Color(0xFF567B59),
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
