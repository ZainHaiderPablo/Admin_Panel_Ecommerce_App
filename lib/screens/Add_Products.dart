import 'dart:ffi';
import 'dart:io';

import 'package:admin_side_flutter_app/database/product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../database/category.dart';
import '../database/brand.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';

class AddProduct extends StatefulWidget {
  const AddProduct({Key key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  ProductService _productService = ProductService();
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController ProductNameController = TextEditingController();
  TextEditingController QuantityController = TextEditingController();
  final PriceController = TextEditingController();
  List<DocumentSnapshot> brands = <DocumentSnapshot>[];
  List<DocumentSnapshot> categories = <DocumentSnapshot>[];
  List<DropdownMenuItem> categoriesDropDown = <DropdownMenuItem>[];
  List<DropdownMenuItem> brandsDropDown = <DropdownMenuItem>[];
  String _currentCategory;
  String _currentBrand;

  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  Color blue = Colors.blue;
  List<String> selectedSizes = <String>[];
  PickedFile _image1;
  PickedFile _image2;
  PickedFile _image3;
  List<String> colors = <String>[];
  bool isLoading = false;

  @override
  void initState() {
    _getCategories();
    _getBrands();

    // _currentCategory = categoriesDropDown[0].value;
  }

  List<DropdownMenuItem<String>> getCategoriesDropdown() {
    List<DropdownMenuItem<String>> items1 = new List();
    for (int i = 0; i < categories.length; i++) {
      setState(() {
        items1.insert(
            0,
            DropdownMenuItem(
                child: Text(categories[i].data()['category']),
                value: categories[i].data()['category']));
      });
    }
    return items1;
  }

  List<DropdownMenuItem<String>> getBrandsDropDown() {
    List<DropdownMenuItem<String>> items = new List();
    for (int i = 0; i < brands.length; i++) {
      setState(() {
        items.insert(
            0,
            DropdownMenuItem(
                child: Text(brands[i].get('brand')),
                value: brands[i].get('brand')));
      });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        leading: Icon(
          Icons.close,
          color: black,
        ),
        title: Text(
          "Add product",
          style: TextStyle(color: black),
        ),
      ),
      body: Form(
        key: _formKey,
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 120,
                            child: OutlineButton(
                                borderSide: BorderSide(
                                    color: grey.withOpacity(0.5), width: 2.5),
                                onPressed: () {
                                  _selectImage(ImageSource.gallery, 1);
                                },
                                child: _displayChild1()),
                          ),
                        ),
                      ),

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'enter a product name with 10 characters at maximum',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: red, fontSize: 12)),
                  ),

                  // C A T E G O R Y___S E L E C T I O N




                  Text(
                    "Available Sizes",
                    style: TextStyle(color: blue),
                  ),

                  Row(
                    children: <Widget>[
                      Checkbox(
                          value: selectedSizes.contains('XS'),
                          onChanged: (value) => changeSelectedSize('XS')),
                      Text('XS'),
                      Checkbox(
                          value: selectedSizes.contains('S'),
                          onChanged: (value) => changeSelectedSize('S')),
                      Text('S'),
                      Checkbox(
                          value: selectedSizes.contains('M'),
                          onChanged: (value) => changeSelectedSize('M')),
                      Text('M'),
                      Checkbox(
                          value: selectedSizes.contains('L'),
                          onChanged: (value) => changeSelectedSize('L')),
                      Text('L'),
                      Checkbox(
                          value: selectedSizes.contains('XL'),
                          onChanged: (value) => changeSelectedSize('XL')),
                      Text('XL'),
                      Checkbox(
                          value: selectedSizes.contains('XXL'),
                          onChanged: (value) => changeSelectedSize('XXL')),
                      Text('XXL'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller: ProductNameController,
                      decoration: InputDecoration(hintText: 'Product name'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'You must enter the product name';
                        } else if (value.length > 10) {
                          return 'Product name cant have more than 10 letters';
                        }
                      },
                    ),
                  ),



                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Category: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                      DropdownButton(
                        items: categoriesDropDown,
                        onChanged: changeSelectedCategory,
                        value: _currentCategory,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Brand: ',
                          style: TextStyle(color: red),
                        ),
                      ),
                      DropdownButton(
                        items: brandsDropDown,
                        onChanged: changeSelectedBrand,
                        value: _currentBrand,
                      ),
                    ],
                  ),


                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller: QuantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Quantity',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'You must enter the product name';
                        }
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller: PriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Price',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'You must enter the product name';
                        }
                      },
                    ),
                  ),


                  FlatButton(
                    color: red,
                    textColor: white,
                    child: Text('Add product'),
                    onPressed: () {
                      ValidateAndUpload();
                    },
                  )
                ],
              ),
      ),
    );
  }

  _getCategories() async {
    List<DocumentSnapshot> data = await _categoryService.getCategories();
    setState(() {
      categories = data;
      categoriesDropDown = getCategoriesDropdown();
      _currentCategory = categories[0].get('category');
    });
  }

  _getBrands() async {
    List<DocumentSnapshot> data = await _brandService.getBrands();
    setState(() {
      brands = data;
      brandsDropDown = getBrandsDropDown();
      _currentBrand = brands[0].get('brand');
    });
  }

  changeSelectedCategory(dynamic selectedCategory) async {
    setState(() => _currentCategory = selectedCategory);
  }

  changeSelectedBrand(dynamic selectedBrand) {
    setState(() => _currentCategory = selectedBrand);
  }

  void changeSelectedSize(String size) {
    if (selectedSizes.contains(size)) {
      setState(() {
        selectedSizes.remove(size);
      });
    } else {
      setState(() {
        selectedSizes.insert(0, size);
      });
    }
  }

  void _selectImage(ImageSource source, int imageNumber) async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() => _image1 = pickedFile);


  }

  Widget _displayChild1() {
    if (_image1 == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 50, 14, 50),
        child: new Icon(
          Icons.add,
          color: grey,
        ),
      );
    } else {
      return Image.file(
        File(_image1.path),
        fit: BoxFit.fill,
        width: double.infinity,
      );
    }
  }





  void ValidateAndUpload() async {
    if (_formKey.currentState.validate()) {
      setState(() => isLoading = true);
      if (_image1 != null ) {
        if (selectedSizes.isNotEmpty) {
          String imageUrl1;
          final FirebaseStorage storage = FirebaseStorage.instance;
          final String picture1 =
              "1${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          UploadTask task1 =
              storage.ref().child(picture1).putFile(File(_image1.path));

          TaskSnapshot snapshot1 =
              await task1.whenComplete(() => null).then((snapshot) => snapshot);


          task1.whenComplete(() => null).then((snapshot1) async {
            imageUrl1 = await snapshot1.ref.getDownloadURL();
            ProductService().uploadProduct({
            "name" : ProductNameController.text,
            "price" : double.parse(PriceController.text),
            "sizes" : selectedSizes,
            "picture" : imageUrl1,
            "quantity" : int.parse(QuantityController.text),
            "category" : _currentCategory,
            "brand" : _currentBrand




            });
            _formKey.currentState.reset();
            setState(() => isLoading = false);
            Fluttertoast.showToast(msg: 'Product added successfully');
            Navigator.pop(context);
          });
        } else {
          setState(() => isLoading = false);
          Fluttertoast.showToast(msg: 'Select atleast one size');
        }
      } else {
        setState(() => isLoading = false);
      }
    }
  }
}
