import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget FeedListSkeletonWidget() {
  return ListView.builder(
    itemCount: 5, // You can adjust the number of skeleton items
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 2,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Add padding
                    child: Container(
                      width: double.infinity,
                      height: 200, // Adjust the image height
                      color: Colors.white, // Customize the skeleton item's appearance
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding
                    child: Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.white, // Customize the skeleton item's appearance
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
