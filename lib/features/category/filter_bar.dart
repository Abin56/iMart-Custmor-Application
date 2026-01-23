// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../app/theme/colors.dart';
import '../../app/core/extensions/context_extensions.dart';

/// Filter controls bar with icon + filter chips
/// - Left: Filter icon (SVG)
/// - Right: Horizontal list of filter options (Brand, Price Drop, Popular)
/// - Selected filter highlighted in primary color
class FilterBar extends StatelessWidget {
  const FilterBar({
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
    super.key,
    this.leadingIconAsset,
    this.isLoading = false,
    this.isCanceling = false,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;
  final String? leadingIconAsset;
  final bool isLoading;
  final bool isCanceling;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = !isDark;
    final unselectedTextColor = isLight
        ? AppColors.green100
        : colorScheme.onSurfaceVariant;
    final unselectedBackground = isLight
        ? Colors.white
        : colorScheme.surfaceContainerHighest;

    return SizedBox(
      height: 35.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: isLight ? Colors.white : colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.15),
              ),
            ),
            alignment: Alignment.center,
            child: leadingIconAsset != null
                ? SvgPicture.asset(
                    leadingIconAsset!,
                    width: 18.w,
                    height: 18.w,
                    colorFilter: isDark
                        ? const ColorFilter.mode(
                            AppColors.green100,
                            BlendMode.srcIn,
                          )
                        : null,
                  )
                : Icon(
                    Icons.filter_list,
                    size: 18.w,
                    color: AppColors.green100,
                  ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 33.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder: (_, index) => AppSpacing.w8,
                  itemBuilder: (context, index) {
                    final isSelected = index == selectedIndex;
                    final isLoadingThisChip = isLoading && isSelected;
                    final isCancelingThisChip = isCanceling && isSelected;
                    final isProcessing =
                        isLoadingThisChip || isCancelingThisChip;

                    // Different colors for apply vs cancel states
                    final chipColor = isCancelingThisChip
                        ? Colors
                              .orange
                              .shade600 // Orange for canceling
                        : AppColors.green100; // Green for applying/selected

                    return AnimatedScale(
                      scale: isProcessing ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ChoiceChip(
                        label: isProcessing
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 12.w,
                                    height: 12.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isCancelingThisChip
                                            ? Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(filters[index]),
                                ],
                              )
                            : isSelected && !isProcessing
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(filters[index]),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.close,
                                    size: 14.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              )
                            : Text(filters[index]),
                        labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                        pressElevation: 0,
                        showCheckmark: false,
                        selected: isSelected || isCancelingThisChip,
                        onSelected: (isLoading || isCanceling)
                            ? null
                            : (_) {
                                onFilterSelected(index);
                              },
                        selectedColor: chipColor,
                        backgroundColor: unselectedBackground,
                        labelStyle: TextStyle(
                          fontSize: 10.sp,
                          color: (isSelected || isCancelingThisChip)
                              ? Colors.white
                              : unselectedTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: (isSelected || isCancelingThisChip)
                              ? chipColor
                              : AppColors.lightGrey.withValues(alpha: 0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
