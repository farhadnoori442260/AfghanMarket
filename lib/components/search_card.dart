import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/models/product_model.dart';
import 'package:kalino_app/screens/product/product_details_screen.dart';

class SearchCard extends StatelessWidget {
  final String address;
  final Products product;

  const SearchCard({
    required this.address,
    required this.product,
    Key? key,
  }) : super(key: key);

  String _formatPrice(dynamic value) {
    final price = double.tryParse(value?.toString() ?? '') ?? 0;
    return NumberFormat.decimalPattern('en_US').format(price);
  }

  String _formatPostDate(dynamic value) {
    if (value == null) {
      return '';
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is int) {
      date = DateTime.fromMicrosecondsSinceEpoch(value);
    } else if (value is num) {
      date = DateTime.fromMicrosecondsSinceEpoch(value.toInt());
    }

    if (date == null) {
      return '';
    }

    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final documentData =
        product.document.data() as Map<String, dynamic>? ?? {};

    final rawImages = documentData['images'];
    final images = rawImages is List ? rawImages : const [];
    final imageUrl =
        images.isNotEmpty ? images.first?.toString() ?? '' : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              ProductDetail.screenId,
              arguments: product,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: scaffoldBgColor,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported_outlined,
                                color: greyMediumColor,
                              );
                            },
                          )
                        : const Icon(
                            Icons.image_outlined,
                            color: greyMediumColor,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: blackColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatPrice(product.price)} ${'currency_symbol'.tr()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: greyColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (address.isNotEmpty)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: greyMediumColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        address,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: greyMediumColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(width: 6),
                            Text(
                              _formatPostDate(product.postDate),
                              style: const TextStyle(
                                fontSize: 11,
                                color: greyMediumColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
