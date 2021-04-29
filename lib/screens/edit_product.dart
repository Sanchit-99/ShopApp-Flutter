import 'package:ShopApp/providers/product.dart';
import 'package:ShopApp/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static String screenName = '/EditProductScreen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final imageurlController = TextEditingController();
  final imageurlFocusNode = FocusNode();
  final form = GlobalKey<FormState>();

  Product editedProduct = Product(
    description: '',
    id: null,
    imageUrl: '',
    price: 0,
    title: '',
  );
  var isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    imageurlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  var isinit = true;
  @override
  void didChangeDependencies() {
    if (isinit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        editedProduct = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId);
        initValues = {
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price.toString(),
          'imageUrl': '',
        };
        imageurlController.text = editedProduct.imageUrl;
      }
    }
    isinit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void updateImageUrl() {
    if (!imageurlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    imageurlFocusNode.removeListener(updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    imageurlFocusNode.dispose();
    super.dispose();
  }

  Future<void> saveForm() async {
    bool isValid = form.currentState.validate();
    if (isValid) {
      form.currentState.save();
      setState(() {
        isloading = true;
      });
      if (editedProduct.id != null) {
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(editedProduct.id, editedProduct);
      } else {
        try {
          await Provider.of<ProductProvider>(context, listen: false)
              .addProduct(editedProduct);
        } catch (error) {
          await showDialog(
              context: context,
              builder: (cxs) => AlertDialog(
                    title: Text('An error Occurred'),
                    content: Text('Something went Wrong. ${error.toString()}'),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Okay'),
                      )
                    ],
                  ));
        }
      }
      setState(() {
        isloading = false;
      });
      Navigator.of(context).pop();
    }
  }

  var initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EditProduct'),
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initValues['title'],
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          description: editedProduct.description,
                          imageUrl: editedProduct.imageUrl,
                          price: editedProduct.price,
                          title: value,
                          isFavorite: editedProduct.isFavorite,
                          id: editedProduct.id,
                        );
                      },
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                    ),
                    TextFormField(
                      initialValue: initValues['price'],
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Price cannot be zero or negative';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          description: editedProduct.description,
                          isFavorite: editedProduct.isFavorite,
                          id: editedProduct.id,
                          imageUrl: editedProduct.imageUrl,
                          price: double.parse(value),
                          title: editedProduct.title,
                        );
                      },
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                    ),
                    TextFormField(
                      initialValue: initValues['description'],
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length < 10) {
                          return 'Description should be at least 10 char long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                          description: value,
                          isFavorite: editedProduct.isFavorite,
                          id: editedProduct.id,
                          imageUrl: editedProduct.imageUrl,
                          price: editedProduct.price,
                          title: editedProduct.title,
                        );
                      },
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(right: 10, top: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: imageurlController.text.isEmpty
                              ? Text('Enter URL')
                              : FittedBox(
                                  fit: BoxFit.cover,
                                  child:
                                      Image.network(imageurlController.text)),
                        ),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an image URL';
                              }
                              if (!value.startsWith('http') ||
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid URL';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              editedProduct = Product(
                                description: editedProduct.description,
                                isFavorite: editedProduct.isFavorite,
                                id: editedProduct.id,
                                imageUrl: value,
                                price: editedProduct.price,
                                title: editedProduct.title,
                              );
                            },
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: imageurlController,
                            focusNode: imageurlFocusNode,
                            onFieldSubmitted: (_) => saveForm(),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: FlatButton(
                        onPressed: () {
                          saveForm();
                        },
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
