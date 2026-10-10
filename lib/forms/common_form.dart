// ignore_for_file: void_checks

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/components/bottom_nav_widget.dart';
import 'package:kalino_app/components/image_picker_widget.dart';
import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/validators.dart';
import 'package:kalino_app/constants/widgets.dart';
import 'package:kalino_app/forms/user_form_review.dart';
import 'package:kalino_app/provider/category_provider.dart';
import 'package:kalino_app/services/user.dart';

class CommonForm extends StatefulWidget {
  static const String screenId = 'common_form';
  const CommonForm({Key? key}) : super(key: key);

  @override
  State<CommonForm> createState() => _CommonFormState();
}

class _CommonFormState extends State<CommonForm> {
  final UserService _firebaseUser = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late FocusNode _brandNode;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionNode;
  late TextEditingController _titleController;
  late FocusNode _titleNode;
  late TextEditingController _priceController;
  late FocusNode _priceNode;
  late TextEditingController _typeController;
  late FocusNode _typeNode;
  late TextEditingController _bedroomController;
  late FocusNode _bedroomNode;
  late TextEditingController _bathroomController;
  late FocusNode _bathroomNode;
  late TextEditingController _furnishController;
  late FocusNode _furnishNode;
  late TextEditingController _constructionController;
  late FocusNode _constructionNode;
  late TextEditingController _sqftController;
  late FocusNode _sqftNode;
  late TextEditingController _floorsController;
  late FocusNode _floorsNode;

  final List<String> _accessoriesList = ['Mobile', 'Tablet'];
  final List<String> _tabletList = ['IPads', 'Samsung', 'Other Tablets'];
  final List<String> _appartmentList = [
    'Apartments',
    'Farm Houses',
    'Houses & Villas'
  ];
  final List<String> _bedroomList = ['1', '2', '3', '3+'];
  final List<String> _bathroomList = ['1', '2', '3', '3+'];
  final List<String> _furnishList = [
    'Full-Furnished',
    'Semi-Furnished',
    'Un-Furnished'
  ];
  final List<String> _constructionList = [
    'New Launch',
    'Ready to Move',
    'Under construction'
  ];

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _brandNode = FocusNode();
    _descriptionController = TextEditingController();
    _descriptionNode = FocusNode();
    _titleController = TextEditingController();
    _titleNode = FocusNode();
    _priceController = TextEditingController();
    _priceNode = FocusNode();
    _typeController = TextEditingController();
    _typeNode = FocusNode();
    _bedroomController = TextEditingController();
    _bedroomNode = FocusNode();
    _bathroomController = TextEditingController();
    _bathroomNode = FocusNode();
    _furnishController = TextEditingController();
    _furnishNode = FocusNode();
    _constructionController = TextEditingController();
    _constructionNode = FocusNode();
    _sqftController = TextEditingController();
    _sqftNode = FocusNode();
    _floorsController = TextEditingController();
    _floorsNode = FocusNode();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _brandNode.dispose();
    _descriptionController.dispose();
    _descriptionNode.dispose();
    _titleController.dispose();
    _titleNode.dispose();
    _priceController.dispose();
    _priceNode.dispose();
    _typeController.dispose();
    _typeNode.dispose();
    _bedroomController.dispose();
    _bedroomNode.dispose();
    _bathroomController.dispose();
    _bathroomNode.dispose();
    _furnishController.dispose();
    _furnishNode.dispose();
    _constructionController.dispose();
    _constructionNode.dispose();
    _sqftController.dispose();
    _sqftNode.dispose();
    _floorsController.dispose();
    _floorsNode.dispose();
    super.dispose();
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
          'title_form_details'.tr(args: [categoryProvider.selectedCategory]),
          style: const TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildFormBody(context, categoryProvider),
      bottomNavigationBar: BottomNavigationWidget(
        buttonText: 'btn_next'.tr(),
        validator: true,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            categoryProvider.formData.addAll({
              'seller_uid': _firebaseUser.user!.uid,
              'category': categoryProvider.selectedCategory,
              'subcategory': categoryProvider.selectedSubCategory,
              'brand': _brandController.text,
              'type': _typeController.text,
              'bedroom': _bedroomController.text,
              'bathroom': _bathroomController.text,
              'furnishing': _furnishController.text,
              'floors': _floorsController.text,
              'construction_status': _constructionController.text,
              'sqft': _sqftController.text,
              'title': _titleController.text,
              'description': _descriptionController.text,
              'price': _priceController.text,
              'images': categoryProvider.imageUploadedUrls.isEmpty
                  ? ''
                  : categoryProvider.imageUploadedUrls,
              'posted_at': DateTime.now().microsecondsSinceEpoch,
              'favourites': [],
            });

            if (categoryProvider.imageUploadedUrls.isNotEmpty) {
              Navigator.pushNamed(context, UserFormReview.screenId);
            } else {
              customSnackBar(
                context: context,
                content: 'msg_please_upload_images'.tr(),
              );
            }
            if (kDebugMode) {
              print(categoryProvider.formData);
            }
          }
        },
      ),
    );
  }

  void _showBrandBottomSheet(
  BuildContext context,
  CategoryProvider categoryProvider,
) {
  final data =
      categoryProvider.doc?.data() as Map<String, dynamic>? ?? {};
  final brands = List<Map<String, dynamic>>.from(
    (data['brands'] as List? ?? const []).map(
      (item) => Map<String, dynamic>.from(item as Map),
    ),
  );

  openBottomSheet(
    context: context,
    appBarTitle: 'sheet_select_brand'.tr(),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: brands.length,
      itemBuilder: (BuildContext context, int index) {
        final brand = brands[index];
        final brandName = brand['name']?.toString() ?? '';
        final brandImage = brand['img']?.toString() ?? '';

        return ListTile(
          onTap: () {
            setState(() {
              _brandController.text = brandName;
            });
            Navigator.pop(context);
          },
          title: Text(brandName),
          leading: brandImage.isEmpty
              ? const Icon(Icons.branding_watermark_outlined)
              : Image.network(
                  brandImage,
                  width: 35,
                  height: 35,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.branding_watermark_outlined),
                ),
        );
      },
    ),
  );
  }

  void _showCommonBottomSheet(
      BuildContext context, List<String> list, TextEditingController controller, String title) {
    openBottomSheet(
      context: context,
      appBarTitle: title,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              setState(() {
                controller.text = list[index];
              });
              Navigator.pop(context);
            },
            title: Text(list[index]),
          );
        },
      ),
    );
  }

  Widget _buildFormBody(
      BuildContext context, CategoryProvider categoryProvider) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryProvider.selectedSubCategory,
                style: const TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),

              // انتخاب برند (مخصوص موبایل)
              if (categoryProvider.selectedSubCategory == 'Mobile Phones')
                InkWell(
                  onTap: () => _showBrandBottomSheet(context, categoryProvider),
                  child: TextFormField(
                    focusNode: _brandNode,
                    controller: _brandController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'err_select_brand'.tr();
                      }
                      return null;
                    },
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'label_brand'.tr(),
                      suffixIcon: const Icon(Icons.arrow_drop_down_sharp,
                          color: blackColor, size: 28),
                      hintText: 'hint_select_brand'.tr(),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: greyLightColor),
                      ),
                    ),
                  ),
                ),

              // انتخاب نوع (دستگاه، لوازم جانبی یا نوع ملک)
              if (categoryProvider.selectedSubCategory == 'Accessories' ||
                  categoryProvider.selectedSubCategory == 'Tablets' ||
                  categoryProvider.selectedSubCategory ==
                      'For Sale: House & Apartments' ||
                  categoryProvider.selectedSubCategory ==
                      'For Rent: House & Apartments') ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    if (categoryProvider.selectedSubCategory == 'Accessories') {
                      _showCommonBottomSheet(
                          context, _accessoriesList, _typeController, 'sheet_select_type'.tr());
                    } else if (categoryProvider.selectedSubCategory == 'Tablets') {
                      _showCommonBottomSheet(
                          context, _tabletList, _typeController, 'sheet_select_type'.tr());
                    } else if (categoryProvider.selectedSubCategory ==
                            'For Sale: House & Apartments' ||
                        categoryProvider.selectedSubCategory ==
                            'For Rent: House & Apartments') {
                      _showCommonBottomSheet(
                          context, _appartmentList, _typeController, 'sheet_select_type'.tr());
                    }
                  },
                  child: TextFormField(
                    focusNode: _typeNode,
                    controller: _typeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'err_select_type'.tr();
                      }
                      return null;
                    },
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'label_type'.tr(),
                      suffixIcon: const Icon(Icons.arrow_drop_down_sharp,
                          color: blackColor, size: 28),
                      hintText: 'hint_select_type'.tr(),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: greyLightColor),
                      ),
                    ),
                  ),
                ),
              ],

              // مشخصات اختصاصی املاک
              if (categoryProvider.selectedSubCategory ==
                      'For Sale: House & Apartments' ||
                  categoryProvider.selectedSubCategory ==
                      'For Rent: House & Apartments') ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showCommonBottomSheet(
                      context, _bedroomList, _bedroomController, 'sheet_select_bedroom'.tr()),
                  child: TextFormField(
                    focusNode: _bedroomNode,
                    controller: _bedroomController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'err_select_bedroom'.tr();
                      }
                      return null;
                    },
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'label_bedroom'.tr(),
                      suffixIcon: const Icon(Icons.arrow_drop_down_sharp,
                          color: blackColor, size: 28),
                      hintText: 'hint_select_bedroom'.tr(),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: greyLightColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showCommonBottomSheet(
                      context, _bathroomList, _bathroomController, 'sheet_select_bathroom'.tr()),
                  child: TextFormField(
                    focusNode: _bathroomNode,
                    controller: _bathroomController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'err_select_bathroom'.tr();
                      }
                      return null;
                    },
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'label_bathroom'.tr(),
                      suffixIcon: const Icon(Icons.arrow_drop_down_sharp,
                          color: blackColor, size: 28),
                      hintText: 'hint_select_bathroom'.tr(),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: greyLightColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showCommonBottomSheet(
                      context, _furnishList, _furnishController, 'sheet_select_furnish'.tr()),
                  child: TextFormField(
                    focusNode: _furnishNode,
                    controller: _furnishController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'err_select_furnish'.tr();
                      }
                      return null;
                    },
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'label_furnishing'.tr(),
                      suffixIcon: const Icon(Icons.arrow_drop_down_sharp,
                          color: blackColor, size: 28),
                      hintText: 'hint_select_furnish'.tr(),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: greyLightColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showCommonBottomSheet(
                      context, _constructionList, _constructionController, 'sheet_select_construction'.tr()),
                  child: TextFormField(
                    focusNode: _constructionNode,
                    controller: _constructionController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'err_select_construction'.tr();
                      }
                      return null;
                    },
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'label_construction_status'.tr(),
                      suffixIcon: const Icon(Icons.arrow_drop_down_sharp,
                          color: blackColor, size: 28),
                      hintText: 'hint_select_construction'.tr(),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: greyLightColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sqftController,
                  focusNode: _sqftNode,
                  validator: (value) =>
                      checkNullEmptyValidation(value, 'sqft'),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'label_sqft'.tr(),
                    contentPadding: const EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: greyLightColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _floorsController,
                  focusNode: _floorsNode,
                  validator: (value) =>
                      checkNullEmptyValidation(value, 'floors'),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'label_floors'.tr(),
                    contentPadding: const EdgeInsets.all(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: greyLightColor),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // عنوان آگهی
              TextFormField(
                controller: _titleController,
                focusNode: _titleNode,
                maxLength: 50,
                validator: (value) => checkNullEmptyValidation(value, 'title'),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'label_title'.tr(),
                  helperText: 'hint_title_helper'.tr(),
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: greyLightColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // توضیحات آگهی
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionNode,
                maxLength: 500,
                validator: (value) =>
                    checkNullEmptyValidation(value, 'product description'),
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'label_description'.tr(),
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: greyLightColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // قیمت
              TextFormField(
                controller: _priceController,
                focusNode: _priceNode,
                validator: (value) => validatePrice(value),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  suffixText: 'currency_symbol'.tr(),
                  labelText: 'label_price'.tr(),
                  contentPadding: const EdgeInsets.all(15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: greyLightColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // دکمه آپلود تصویر
              InkWell(
                onTap: () async {
                  return openBottomSheet(
                    context: context,
                    child: const ImagePickerWidget(),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: primaryLightColor.withOpacity(0.5),
                    border: Border.all(color: primaryColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        categoryProvider.imageUploadedUrls.isNotEmpty
                            ? 'btn_add_more_images'.tr()
                            : 'btn_select_image'.tr(),
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // پیش‌نمایش گالری تصاویر آپلودشده
              if (categoryProvider.imageUploadedUrls.isNotEmpty)
                GalleryImage(
                  titleGallery: 'title_uploaded_images'.tr(),
                  numOfShowImages: categoryProvider.imageUploadedUrls.length,
                  imageUrls: categoryProvider.imageUploadedUrls,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
