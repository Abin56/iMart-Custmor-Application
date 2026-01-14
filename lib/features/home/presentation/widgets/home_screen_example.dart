// import 'package:flutter/material.dart';
// import 'home_top_section_ui.dart';

// /// Example home screen using the UI-only top section
// /// Shows how to integrate with other sections
// class HomeScreenExample extends StatelessWidget {
//   const HomeScreenExample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Top section with green header and categories
//           const HomeTopSectionUI(),

//           // Scrollable content below
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   _buildSearchBar(),
//                   const SizedBox(height: 24),
//                   _buildGoToItemsHeader(),
//                   const SizedBox(height: 16),
//                   // Add your items grid here
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         height: 50,
//         decoration: BoxDecoration(
//           color: const Color(0xFFF0F0F0),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             const SizedBox(width: 16),
//             Icon(
//               Icons.search,
//               color: Colors.grey.shade600,
//               size: 24,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search...',
//                   hintStyle: TextStyle(
//                     color: Colors.grey.shade400,
//                     fontSize: 15,
//                   ),
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGoToItemsHeader() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Your go-to items',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           Text(
//             'See All',
//             style: TextStyle(
//               color: Color(0xFF145A32),
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
