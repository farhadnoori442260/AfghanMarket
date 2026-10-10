import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/components/bottom_nav_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/validators.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/provider/category_provider.dart';
import 'package:kalino_app/screens/location_screen.dart';
import 'package:kalino_app/screens/main_navigatiion_screen.dart';
import 'package:kalino_app/services/auth.dart';
import 'package:kalino_app/services/user.dart';

class UserFormReview extends StatefulWidget {
  static const screenId = 'user_form_review_screen';

  const UserFormReview({Key? key}) : super(key: key);

  @override
  State<UserFormReview> createState() => _UserFormReviewState();
}

class _UserFormReviewState extends State<UserFormReview> {
  final UserService _firebaseUser = UserService();
  final Auth _authService = Auth();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _countryCodeController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  late FocusNode _nameNode;
  late FocusNode _countryCodeNode;
  late FocusNode _phoneNumberNode;
  late FocusNode _emailNode;
  late FocusNode _addressNode;

  bool _isDataLoaded = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _countryCodeController = TextEditingController(text: '+93');
    _phoneNumberController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();

    _nameNode = FocusNode();
    _countryCodeNode = FocusNode();
    _phoneNumberNode = FocusNode();
    _emailNode = FocusNode();
    _addressNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryCodeController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();

    _nameNode.dispose();
    _countryCodeNode.dispose();
    _phoneNumberNode.dispose();
    _emailNode.dispose();
    _addressNode.dispose();
    super.dispose();
  }

  Future<void> _updateUserProductData(
      CategoryProvider categoryProvider, Map<String, dynamic> data, BuildContext context) {
    return _authService.users
        .doc(_firebaseUser.user!.uid)
        .update(data)
        .then((value) {
      _saveProductToDatabase(categoryProvider, context);
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      customSnackBar(
        context: context,
        content: 'err_failed_update_user'.tr(),
      );
    });
  }

  Future<void> _saveProductToDatabase(CategoryProvider categoryProvider, BuildContext context) {
    return _authService.products.add(categoryProvider.formData).then((value) {
      categoryProvider.clearData();
      customSnackBar(
        context: context,
        content: 'msg_product_added_success'.tr(),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        MainNavigationScreen.screenId,
        (route) => false,
      );
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      customSnackBar(
        context: context,
        content: 'err_failed_add_product'.tr(),
      );
    });
  }

  void _confirmFormDataDialog(CategoryProvider categoryProvider) {
    final images = categoryProvider.formData['images'] as List?;
    final firstImage = (images != null && images.isNotEmpty) ? images[0] : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'dialog_confirm_title'.tr(),
                  style: const TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'dialog_confirm_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: blackColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: firstImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            firstImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, color: greyColor),
                        ),
                  title: Text(
                    categoryProvider.formData['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        categoryProvider.formData['description'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: disabledColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${categoryProvider.formData['price']} ${'currency_afn'.tr()}',
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: greyColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'btn_cancel'.tr(),
                        style: const TextStyle(color: blackColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              Navigator.pop(context);
                              loadingDialogBox(context, 'msg_uploading_database'.tr());
                              setState(() {
                                _isSubmitting = true;
                              });

                              await _updateUserProductData(
                                categoryProvider,
                                {
                                  'contact_details': {
                                    'mobile': '+93${_phoneNumberController.text}',
                                    'email': _emailController.text,
                                    'address': _addressController.text,
                                  },
                                  'name': _nameController.text,
                                },
                                context,
                              );

                              setState(() {
                                _isSubmitting = false;
                              });
                            },
                      child: Text(
                        'btn_confirm'.tr(),
                        style: const TextStyle(color: whiteColor),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        backgroundColor: whiteColor,
        title: Text(
          'title_review_details'.tr(),
          style: const TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _userFormReviewBody(),
      bottomNavigationBar: BottomNavigationWidget(
        validator: true,
        buttonText: 'btn_confirm'.tr(),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _confirmFormDataDialog(categoryProvider);
          }
        },
      ),
    );
  }

  Widget _userFormReviewBody() {
    return Form(
      key: _formKey,
      child: FutureBuilder<DocumentSnapshot?>(
        future: _firebaseUser.getUserData(),
        builder: (
  BuildContext context,
  AsyncSnapshot<DocumentSnapshot?> snapshot,
) {
          if (snapshot.hasError) {
            return Center(child: Text('err_loading_review_form'.tr()));
          }
          if (snapshot.hasData && !snapshot.data!.exists) {
            return Center(child: Text('err_document_not_exist'.tr()));
          }
          if (snapshot.connectionState == ConnectionState.waiting && !_isDataLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasData && !_isDataLoaded) {
            Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              _nameController.text = data['name'] ?? '';

              String rawMobile = '';
              if (data['contact_details'] != null && data['contact_details']['mobile'] != null) {
                rawMobile = data['contact_details']['mobile'].toString();
              } else if (data['mobile'] != null) {
                rawMobile = data['mobile'].toString();
              }

              if (rawMobile.startsWith('+93')) {
                _phoneNumberController.text = rawMobile.substring(3);
              } else if (rawMobile.startsWith('0')) {
                _phoneNumberController.text = rawMobile.substring(1);
              } else {
                _phoneNumberController.text = rawMobile;
              }

              _emailController.text = (data['contact_details'] != null && data['contact_details']['email'] != null)
                  ? data['contact_details']['email']
                  : (data['email'] ?? '');

              _addressController.text = (data['contact_details'] != null && data['contact_details']['address'] != null)
                  ? data['contact_details']['address']
                  : (data['address'] ?? '');
            }
            _isDataLoaded = true;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        backgroundColor: primaryColor,
                        radius: 36,
                        child: CircleAvatar(
                          backgroundColor: secondaryColor,
                          radius: 33,
                          child: Icon(
                            CupertinoIcons.person_fill,
                            color: whiteColor,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          focusNode: _nameNode,
                          controller: _nameController,
                          validator: (value) => checkNullEmptyValidation(value, "label_name".tr()),
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'label_name'.tr(),
                            prefixIcon: const Icon(Icons.person_outline, color: greyColor),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'header_contact_details'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          focusNode: _countryCodeNode,
                          enabled: false,
                          controller: _countryCodeController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(15),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: disabledColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          focusNode: _phoneNumberNode,
                          controller: _phoneNumberController,
                          maxLength: 9,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          validator: (value) => validateMobile(value),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            counterText: '',
                            labelText: 'label_phone_number'.tr(),
                            prefixIcon: const Icon(Icons.phone_outlined, color: greyColor),
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: _emailNode,
                    controller: _emailController,
                    validator: (value) => validateEmail(
                      value,
                      EmailValidator.validate(_emailController.text),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'label_email'.tr(),
                      prefixIcon: const Icon(Icons.email_outlined, color: greyColor),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (builder) => const LocationScreen(
                            onlyPop: true,
                            popToScreen: UserFormReview.screenId,
                          ),
                        ),
                      );
                      if (result != null && result is String && result.isNotEmpty) {
                        setState(() {
                          _addressController.text = result;
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        focusNode: _addressNode,
                        controller: _addressController,
                        validator: (value) => checkNullEmptyValidation(value, 'label_address'.tr()),
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'label_address'.tr(),
                          prefixIcon: const Icon(Icons.location_on_outlined, color: greyColor),
                          suffixIcon: const Icon(Icons.arrow_forward_ios, size: 18, color: greyColor),
                          contentPadding: const EdgeInsets.all(15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
