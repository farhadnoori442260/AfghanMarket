import 'package:easy_localization/easy_localization.dart';
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

class SellCarForm extends StatefulWidget {
  static const screenId = 'sell_car_form';

  const SellCarForm({Key? key}) : super(key: key);

  @override
  State<SellCarForm> createState() => _SellCarFormState();
}

class _SellCarFormState extends State<SellCarForm> {
  final UserService _firebaseUser = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _carModelNameController;
  late TextEditingController _yearController;
  late TextEditingController _priceController;
  late TextEditingController _fuelController;
  late TextEditingController _transmissionController;
  late TextEditingController _kmDrivenController;
  late TextEditingController _ownerController;
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late FocusNode _carModelNameNode;
  late FocusNode _yearNode;
  late FocusNode _priceNode;
  late FocusNode _fuelNode;
  late FocusNode _transmissionNode;
  late FocusNode _kmDrivenNode;
  late FocusNode _ownerNode;
  late FocusNode _titleNode;
  late FocusNode _descNode;

  bool _isSubmitting = false;

  final List<String> _fuelType = ['Petrol', 'Diesel', 'Gas / LPG', 'Hybrid', 'Electric'];
  final List<String> _transmissionType = ['Automatic', 'Manual'];
  final List<String> _noOfOwner = ['1st', '2nd', '3rd', '4th', '4th+'];

  @override
  void initState() {
    super.initState();
    _carModelNameController = TextEditingController();
    _yearController = TextEditingController();
    _priceController = TextEditingController();
    _fuelController = TextEditingController();
    _transmissionController = TextEditingController();
    _kmDrivenController = TextEditingController();
    _ownerController = TextEditingController();
    _titleController = TextEditingController();
    _descController = TextEditingController();

    _carModelNameNode = FocusNode();
    _yearNode = FocusNode();
    _priceNode = FocusNode();
    _fuelNode = FocusNode();
    _transmissionNode = FocusNode();
    _kmDrivenNode = FocusNode();
    _ownerNode = FocusNode();
    _titleNode = FocusNode();
    _descNode = FocusNode();
  }

  @override
  void dispose() {
    _carModelNameController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _fuelController.dispose();
    _transmissionController.dispose();
    _kmDrivenController.dispose();
    _ownerController.dispose();
    _titleController.dispose();
    _descController.dispose();

    _carModelNameNode.dispose();
    _yearNode.dispose();
    _priceNode.dispose();
    _fuelNode.dispose();
    _transmissionNode.dispose();
    _kmDrivenNode.dispose();
    _ownerNode.dispose();
    _titleNode.dispose();
    _descNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    var categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    if (categoryProvider.formData.isNotEmpty) {
      _carModelNameController.text = categoryProvider.formData['brand'] ?? "";
      _yearController.text = categoryProvider.formData['year'] ?? "";
      _priceController.text = categoryProvider.formData['price'] ?? "";
      _fuelController.text = categoryProvider.formData['fuel_type'] ?? "";
      _transmissionController.text = categoryProvider.formData['transmission_type'] ?? "";
      _kmDrivenController.text = categoryProvider.formData['km_driven'] ?? "";
      _ownerController.text = categoryProvider.formData['owners'] ?? "";
      _titleController.text = categoryProvider.formData['title'] ?? "";
      _descController.text = categoryProvider.formData['description'] ?? "";
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: blackColor),
        title: Text(
          'title_add_car_details'.tr(),
          style: const TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: sellCarFormWidget(categoryProvider),
      bottomNavigationBar: BottomNavigationWidget(
        buttonText: 'btn_next'.tr(),
        validator: true,
        onPressed: _isSubmitting
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  if (categoryProvider.imageUploadedUrls.isEmpty) {
                    customSnackBar(
                      context: context,
                      content: 'msg_please_upload_images'.tr(),
                    );
                    return;
                  }

                  setState(() {
                    _isSubmitting = true;
                  });

                  categoryProvider.formData.addAll({
                    'seller_uid': _firebaseUser.user?.uid ?? '',
                    'category': categoryProvider.selectedCategory,
                    'subcategory': categoryProvider.selectedSubCategory,
                    'brand': _carModelNameController.text,
                    'year': _yearController.text,
                    'price': _priceController.text,
                    'fuel_type': _fuelController.text,
                    'transmission_type': _transmissionController.text,
                    'km_driven': _kmDrivenController.text,
                    'owners': _ownerController.text,
                    'title': _titleController.text,
                    'description': _descController.text,
                    'images': categoryProvider.imageUploadedUrls,
                    'posted_at': DateTime.now().microsecondsSinceEpoch,
                    'favourites': [],
                  });

                  setState(() {
                    _isSubmitting = false;
                  });

                  Navigator.pushNamed(context, UserFormReview.screenId);
                }
              },
      ),
    );
  }

  void _fuelTypeListView(BuildContext context) {
    openBottomSheet(
      context: context,
      appBarTitle: 'sheet_select_fuel_type'.tr(),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _fuelType.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_fuelType[index]),
            onTap: () {
              setState(() {
                _fuelController.text = _fuelType[index];
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _transmissionTypeListView(BuildContext context) {
    openBottomSheet(
      context: context,
      appBarTitle: 'sheet_select_transmission_type'.tr(),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _transmissionType.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_transmissionType[index]),
            onTap: () {
              setState(() {
                _transmissionController.text = _transmissionType[index];
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _ownerListView(BuildContext context) {
    openBottomSheet(
      context: context,
      appBarTitle: 'sheet_select_no_of_owners'.tr(),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _noOfOwner.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_noOfOwner[index]),
            onTap: () {
              setState(() {
                _ownerController.text = _noOfOwner[index];
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _getCarModelList(
  BuildContext context,
  CategoryProvider categoryProvider,
) {
  final data =
      categoryProvider.doc?.data() as Map<String, dynamic>? ?? {};

  final models = List<String>.from(data['models'] ?? const []);

  if (models.isEmpty) {
    customSnackBar(
      context: context,
      content: 'msg_no_models_found'.tr(),
    );
    return;
  }

  openBottomSheet(
    context: context,
    appBarTitle: 'sheet_select_car_model'.tr(),
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: models.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(models[index]),
          onTap: () {
            setState(() {
              _carModelNameController.text = models[index];
            });
            Navigator.pop(context);
          },
        );
      },
    ),
  );
  }

  Widget sellCarFormWidget(CategoryProvider categoryProvider) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'header_car_details'.tr(),
                style: const TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 20),

              // مدل موتر
              InkWell(
                onTap: () => _getCarModelList(context, categoryProvider),
                child: TextFormField(
                  focusNode: _carModelNameNode,
                  controller: _carModelNameController,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'err_please_choose_model'.tr();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.directions_car_outlined, color: greyColor),
                    suffixIcon: const Icon(Icons.arrow_drop_down_sharp, color: blackColor, size: 28),
                    labelText: 'label_car_model'.tr(),
                    hintText: 'hint_car_model'.tr(),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // نوعیت سوخت
              InkWell(
                onTap: () => _fuelTypeListView(context),
                child: TextFormField(
                  controller: _fuelController,
                  focusNode: _fuelNode,
                  enabled: false,
                  validator: (value) => checkNullEmptyValidation(value, 'label_fuel_type'.tr()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.local_gas_station_outlined, color: greyColor),
                    suffixIcon: const Icon(Icons.arrow_drop_down_sharp, color: blackColor, size: 28),
                    labelText: 'label_fuel_type'.tr(),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // نوعیت گیربکس / تانکمند
              InkWell(
                onTap: () => _transmissionTypeListView(context),
                child: TextFormField(
                  controller: _transmissionController,
                  focusNode: _transmissionNode,
                  enabled: false,
                  validator: (value) => checkNullEmptyValidation(value, 'label_transmission'.tr()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.settings_outlined, color: greyColor),
                    suffixIcon: const Icon(Icons.arrow_drop_down_sharp, color: blackColor, size: 28),
                    labelText: 'label_transmission'.tr(),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // تعداد دست / مالک
              InkWell(
                onTap: () => _ownerListView(context),
                child: TextFormField(
                  controller: _ownerController,
                  focusNode: _ownerNode,
                  enabled: false,
                  validator: (value) => checkNullEmptyValidation(value, 'label_no_of_owners'.tr()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: greyColor),
                    suffixIcon: const Icon(Icons.arrow_drop_down_sharp, color: blackColor, size: 28),
                    labelText: 'label_no_of_owners'.tr(),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // سال ساخت / سال خرید
              TextFormField(
                controller: _yearController,
                focusNode: _yearNode,
                validator: (value) => validateYear(value),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: greyColor),
                  labelText: 'label_purchase_year'.tr(),
                  hintText: 'hint_purchase_year'.tr(),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // قیمت (AFN)
              TextFormField(
                controller: _priceController,
                focusNode: _priceNode,
                validator: (value) => validatePrice(value),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money_outlined, color: greyColor),
                  suffixText: 'currency_afn'.tr(),
                  labelText: 'label_car_price'.tr(),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // کارکرد (کیلومتر)
              TextFormField(
                controller: _kmDrivenController,
                focusNode: _kmDrivenNode,
                validator: (value) => checkNullEmptyValidation(value, 'label_km_driven'.tr()),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.speed_outlined, color: greyColor),
                  labelText: 'label_km_driven'.tr(),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // عنوان اعلان
              TextFormField(
                controller: _titleController,
                focusNode: _titleNode,
                maxLength: 50,
                validator: (value) => checkNullEmptyValidation(value, 'label_ad_title'.tr()),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.title_outlined, color: greyColor),
                  labelText: 'label_ad_title'.tr(),
                  helperText: 'helper_ad_title'.tr(),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // توضیحات
              TextFormField(
                controller: _descController,
                focusNode: _descNode,
                maxLines: 4,
                validator: (value) => checkNullEmptyValidation(value, 'label_description'.tr()),
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.description_outlined, color: greyColor),
                  labelText: 'label_description'.tr(),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        categoryProvider.imageUploadedUrls.isNotEmpty
                            ? 'btn_upload_more_images'.tr()
                            : 'btn_upload_image'.tr(),
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
              const SizedBox(height: 12),

              // گالری تصاویر آپلود شده
              if (categoryProvider.imageUploadedUrls.isNotEmpty)
                GalleryImage(
                  titleGallery: 'gallery_uploaded_images'.tr(),
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
