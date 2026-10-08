import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galleryimage/galleryimage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/provider/category_provider.dart';
import 'package:kalino_app/utils.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({Key? key}) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;
  final picker = ImagePicker();
  bool isUploading = false;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: isUploading ? 160 : 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scaffoldBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: greyLightColor),
                ),
                child: isUploading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 16),
                          Text(
                            'msg_uploading_image'.tr(),
                            style: const TextStyle(
                              color: greyColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      )
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
          ] else if (categoryProvider.imageUploadedUrls.isNotEmpty) ...[
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: GalleryImage(
                titleGallery: 'title_uploaded_images'.tr(),
                numOfShowImages: categoryProvider.imageUploadedUrls.length,
                imageUrls: categoryProvider.imageUploadedUrls,
              ),
            ),
          ] else ...[
            InkWell(
              onTap: getImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryLightColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.camera_fill,
                      size: 48,
                      color: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'btn_select_image'.tr(),
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'hint_add_images'.tr(),
                      style: const TextStyle(
                        color: greyMediumColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_image == null && categoryProvider.imageUploadedUrls.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: getImage,
                icon: const Icon(CupertinoIcons.add),
                label: Text('btn_add_more_images'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_image != null && !isUploading)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isUploading = true;
                        uploadFile(context, _image!.path).then((url) {
                          if (url != null) {
                            categoryProvider.setImageList(url);
                            setState(() {
                              isUploading = false;
                              _image = null;
                            });
                          } else {
                            setState(() {
                              isUploading = false;
                            });
                          }
                        });
                      });
                    },
                    icon: const Icon(CupertinoIcons.cloud_upload),
                    label: Text('btn_upload_image'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: whiteColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _image = null;
                      });
                    },
                    icon: const Icon(CupertinoIcons.xmark),
                    label: Text('btn_cancel'.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: errorColor,
                      side: const BorderSide(color: errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
