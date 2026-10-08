import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:kalino_app/constants/colors.dart';
import 'package:kalino_app/constants/validators.dart';
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

  @override
  Widget build(BuildContext context) {
    List images = product.document?['images'] ?? [];
    String imageUrl = images.isNotEmpty ? images[0] : '';

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
              ProductDetailsScreen.screenId,
              arguments: product,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // تصویر آگهی
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

                // اطلاعات آگهی
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.title ?? '',
                              maxLines: 1,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: blackColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.price != null
                                ? '${intToStringFormatter(product.price)} ${'currency_symbol'.tr()}'
                                : '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description ?? '',
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 12,
                          color: greyColor,
                          height: 1.3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: greyMediumColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (product.postDate != null)
                            Text(
                              formattedTime(product.postDate),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
