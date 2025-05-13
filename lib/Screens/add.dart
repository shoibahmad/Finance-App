import 'package:flutter/material.dart';
import 'package:managment/data/model/add_date.dart'; // Ensure this path is correct
import 'package:hive_flutter/hive_flutter.dart';

class Add_Screen extends StatefulWidget {
  const Add_Screen({super.key});

  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

class _Add_ScreenState extends State<Add_Screen> {
  // Hive Box
  final box = Hive.box<Add_data>('data'); // Ensure Add_data type matches your model

  // State Variables
  DateTime date = DateTime.now();
  String? selectedCategory; // Renamed from selctedItem for clarity
  String? selectedType; // Renamed from selctedItemi for clarity

  // Controllers and Focus Nodes
  final TextEditingController explainController = TextEditingController();
  final FocusNode explainFocusNode = FocusNode();
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  // Dropdown Items
  final List<String> _categories = [
    'food',       // Ensure corresponding images exist: images/food.png, etc.
    'Transfer',
    'Transportation',
    'Education'
  ];
  final List<String> _types = [
    'Income',
    'Expense', // Assuming 'Expand' means Expense
  ];

  @override
  void initState() {
    super.initState();
    // Add listeners to update UI state when focus changes (optional)
    explainFocusNode.addListener(() {
      if (mounted) setState(() {}); // Rebuild to show focus highlight
    });
    amountFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    explainController.dispose();
    explainFocusNode.dispose();
    amountController.dispose();
    amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use theme background color
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            _buildBackground(context),
            Positioned(
              top: 120, // Adjust as needed based on background height
              child: _buildMainContainer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Main Container ---
  Widget _buildMainContainer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white, // Keep card white or use Theme.of(context).cardColor
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 560, // Increased height slightly for better spacing
      width: MediaQuery.of(context).size.width * 0.9, // Responsive width
      child: SingleChildScrollView( // Allow scrolling if content overflows
         padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: [
            const SizedBox(height: 30), // Spacing from top inside container
            _buildCategoryDropdown(),
            const SizedBox(height: 30),
            _buildExplainField(),
            const SizedBox(height: 30),
            _buildAmountField(),
            const SizedBox(height: 30),
            _buildTypeDropdown(),
            const SizedBox(height: 30),
            _buildDateTimePicker(),
            const SizedBox(height: 40), // Spacing before save button
            _buildSaveButton(),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- Form Field Widgets ---

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: double.infinity, // Take available width
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Colors.grey.shade400, // Use a slightly lighter grey
          ),
        ),
        child: DropdownButton<String>(
          value: selectedCategory,
          hint: Text(
            'Category', // More descriptive hint
            style: TextStyle(color: Colors.grey.shade600),
          ),
          isExpanded: true,
          underline: const SizedBox(), // Remove default underline
          dropdownColor: Colors.white,
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    // Use Image.asset with errorBuilder for robustness
                    child: Image.asset(
                      'images/$category.png', // Ensure these paths are correct
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error_outline, color: Colors.red, size: 30), // Fallback icon
                       height: 30, // Consistent height
                       width: 30, // Consistent width
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedCategory = value;
              });
            }
          },
          // Customize the selected item appearance if needed
          selectedItemBuilder: (BuildContext context) {
            return _categories.map<Widget>((item) {
              return Row(
                 mainAxisAlignment: MainAxisAlignment.start, // Align left
                children: [
                   SizedBox(
                    width: 40,
                    child: Image.asset(
                      'images/$item.png',
                       errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error_outline, color: Colors.red, size: 30),
                       height: 30,
                       width: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(item, style: const TextStyle(fontSize: 16)),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

   Widget _buildExplainField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        focusNode: explainFocusNode,
        controller: explainController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Explanation (Optional)',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          border: OutlineInputBorder( // Use OutlineInputBorder for consistency
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Colors.grey.shade400)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor)),
        ),
         maxLines: 1, // Single line explanation
      ),
    );
  }

  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        keyboardType: TextInputType.numberWithOptions(decimal: true), // Allow decimals
        focusNode: amountFocusNode,
        controller: amountController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
           border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Colors.grey.shade400)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Colors.grey.shade400)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Theme.of(context).primaryColor)),
           prefixIcon: Icon(Icons.attach_money, color: Colors.grey.shade600, size: 20), // Added currency icon
        ),
      ),
    );
  }

 Widget _buildTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Colors.grey.shade400,
          ),
        ),
        child: DropdownButton<String>(
          value: selectedType,
          hint: Text(
            'Type (Income/Expense)', // Clearer hint
            style: TextStyle(color: Colors.grey.shade600),
          ),
          isExpanded: true,
          underline: const SizedBox(),
          dropdownColor: Colors.white,
          items: _types.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: const TextStyle(fontSize: 17),
              ),
            );
          }).toList(),
          onChanged: (value) {
             if (value != null) {
               setState(() {
                selectedType = value;
              });
             }
          },
           selectedItemBuilder: (BuildContext context) {
            return _types.map<Widget>((item) {
              return Align( // Align text to the start
                alignment: Alignment.centerLeft,
                child: Text(item, style: const TextStyle(fontSize: 16)),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Container(
      alignment: Alignment.centerLeft, // Align text left
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.grey.shade400)),
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), // Consistent padding
          alignment: Alignment.centerLeft // Ensure text inside button is left aligned
        ),
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2020), // Reasonable start date
            lastDate: DateTime.now().add(const Duration(days: 365)), // Allow up to 1 year in future
             builder: (context, child) { // Optional: Theme the date picker
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).primaryColor, // header background color
                    onPrimary: Colors.white, // header text color
                    onSurface: Colors.black, // body text color
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor, // button text color
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          // Important: Check for null correctly
          if (newDate == null) return;

          // Update the state with the selected date
          setState(() {
            date = newDate;
          });
        },
        // Format date as Day / Month / Year (more standard)
        child: Text(
          'Date : ${date.day} / ${date.month} / ${date.year}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87, // Darker text for readability
          ),
        ),
      ),
    );
  }

   Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        // --- Validation ---
        if (selectedCategory == null) {
          _showErrorSnackbar('Please select a category.');
          return;
        }
        if (amountController.text.isEmpty || double.tryParse(amountController.text) == null) {
          _showErrorSnackbar('Please enter a valid amount.');
          return;
        }
         if (selectedType == null) {
          _showErrorSnackbar('Please select the type (Income/Expense).');
          return;
        }
        // --- End Validation ---

        // Create data model object
        var newTransaction = Add_data(
          selectedType!,        // Now safe due to validation
          amountController.text, // Store as string as per model
          date,
          explainController.text.isEmpty ? selectedCategory! : explainController.text, // Use category if explain is empty
          selectedCategory!,     // Now safe due to validation
        );

        // Add to Hive
        box.add(newTransaction).then((_) {
          // Close screen after successful save
          Navigator.of(context).pop();
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newTransaction.name} transaction saved successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            )
          );
        }).catchError((error) {
           _showErrorSnackbar('Failed to save transaction: $error');
        });

      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColor, // Use theme color
        ),
        width: 150, // Slightly wider button
        height: 50,
        child: const Text(
          'Save Transaction',
          style: TextStyle(
            fontFamily: 'f', // Make sure this font is configured in pubspec.yaml
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  // --- Background Widget ---
  Widget _buildBackground(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240, // Standard height
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor, // Use theme color
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Navigate back
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    // Title
                    const Text(
                      'Add Transaction', // More descriptive title
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    // Placeholder Icon (can be removed or used)
                    const Icon(
                      Icons.attach_file_outlined, // Or another relevant icon
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // Helper to show error messages
  void _showErrorSnackbar(String message) {
     if (!mounted) return; // Check if the widget is still active
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}