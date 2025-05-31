import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/models/fahad/model.dart';
import 'package:pb_lms/providers/fahad/student_and_grievance_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({super.key});

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  final TextEditingController _batchNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  dynamic selectedCourse;

  AdminCourseBatch? _editingBatch;
  bool get isEditMode => _editingBatch != null;

  // Filtered batches for search
  List<AdminCourseBatch> filteredBatches = [];

  @override
  void initState() {
    super.initState();
    // Fetch courses when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).AdminfetchCoursesprovider();
    });
    _searchController.addListener(_filterBatches);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBatches);
    _searchController.dispose();
    _batchNameController.dispose();
    super.dispose();
  }

  void _filterBatches() {
    if (selectedCourse == null) return;

    final provider = Provider.of<AdminAuthProvider>(context, listen: false);
    final batches = provider.courseBatches[selectedCourse.courseId] ?? [];

    setState(() {
      if (_searchController.text.isEmpty) {
        filteredBatches = batches;
      } else {
        filteredBatches =
            batches
                .where(
                  (batch) => batch.batchName.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _showBatchDialog(BuildContext context, {AdminCourseBatch? batch}) {
    // Set edit mode
    _editingBatch = batch;

    // Initialize form fields
    _batchNameController.text = batch?.batchName ?? '';
    _startDate = batch?.startTime;
    _endDate = batch?.endTime;
    bool isSubmitting = false;

    if (selectedCourse == null) {
      _showError(context, 'Please select a course first');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 235, 235, 235),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: screenWidth < 700 ? null : screenWidth * 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditMode ? 'Edit Batch' : 'Create New Batch',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _batchNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter Batch Name',
                        labelText: 'Batch Name',
                        suffixIcon: const Icon(Icons.group),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            controller: TextEditingController(
                              text:
                                  _startDate != null
                                      ? DateFormat(
                                        'dd MMM yyyy',
                                      ).format(_startDate!)
                                      : '',
                            ),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate ?? DateTime.now(),
                                firstDate:
                                    isEditMode
                                        ? DateTime(2020)
                                        : DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            controller: TextEditingController(
                              text:
                                  _endDate != null
                                      ? DateFormat(
                                        'dd MMM yyyy',
                                      ).format(_endDate!)
                                      : '',
                            ),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _endDate ?? (_startDate ?? DateTime.now()),
                                firstDate: _startDate ?? DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width:
                              screenWidth < 700
                                  ? double.infinity
                                  : (screenWidth * 0.2 - 35),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  screenWidth < 700
                                      ? const Color.fromARGB(255, 12, 201, 70)
                                      : Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                screenWidth >= 700
                                    ? () => Navigator.pop(context)
                                    : (isSubmitting
                                        ? null
                                        : () => _submitBatch(context, setState)),
                            child:
                                isSubmitting && screenWidth < 700
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      screenWidth < 700
                                          ? (isEditMode ? 'Update' : 'Create')
                                          : 'Close',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(
                          width:
                              screenWidth < 700
                                  ? double.infinity
                                  : (screenWidth * 0.2 - 35),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  screenWidth < 700
                                      ? Colors.redAccent
                                      : const Color.fromARGB(255, 12, 201, 70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                screenWidth >= 700
                                    ? (isSubmitting
                                        ? null
                                        : () =>
                                            _submitBatch(context, setState))
                                    : () => Navigator.pop(context),
                            child:
                                isSubmitting && screenWidth >= 700
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      screenWidth < 700
                                          ? 'Close'
                                          : (isEditMode ? 'Update' : 'Create'),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitBatch(BuildContext context, StateSetter setState) async {
    if (_batchNameController.text.trim().isEmpty) {
      _showError(context, 'Please enter a batch name');
      return;
    }
    if (_startDate == null) {
      _showError(context, 'Please select a start date');
      return;
    }
    if (_endDate == null) {
      _showError(context, 'Please select an end date');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      _showError(context, 'End date cannot be before start date');
      return;
    }

    setState(() {});

    try {
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);

      if (isEditMode) {
        await provider.AdminUpdatebatchprovider(
          selectedCourse.courseId,
          _editingBatch!.batchId,
          _batchNameController.text.trim(),
          '',
          _startDate!,
          _endDate!,
        );
      } else {
        await provider.AdminCreateBatchProvider(
          _batchNameController.text.trim(),
          selectedCourse.courseId,
          _startDate!,
          _endDate!,
        );
      }

      Navigator.pop(context);
      await provider.AdminfetchBatchForCourseProvider(selectedCourse.courseId);
      _filterBatches(); // Refresh filtered list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Batch ${isEditMode ? 'updated' : 'created'} successfully!',
          ),
          backgroundColor: const Color.fromARGB(255, 12, 201, 70),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      _showError(
        context,
        'Failed to ${isEditMode ? 'update' : 'create'} batch: ${e.toString()}',
      );
    }
  }

  Future<void> _deleteBatch(AdminAuthProvider provider, int batchId) async {
    try {
      await provider.AdmindeleteBatchprovider(
        selectedCourse.courseId,
        batchId,
        '',
        DateTime.now(),
        DateTime.now().add(const Duration(days: 365)),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Batch deleted successfully!'),
          backgroundColor: const Color.fromARGB(255, 12, 201, 70),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await provider.AdminfetchBatchForCourseProvider(selectedCourse.courseId);
      _filterBatches(); // Refresh filtered list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete batch: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Delete Batch',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Are you sure you want to delete this batch?',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel', style: GoogleFonts.poppins()),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: 20,
          top: 55,
          right: 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 235, 235, 235),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Batch management',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth < 600 ? 32 : 64,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Select your course and manage your batches here.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Course Selection
              Text(
                'Select your course',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),

              Container(
                width: 500,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: DropdownButtonFormField<dynamic>(
                  value: selectedCourse,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    hintText: 'Select a course',
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  items:
                      provider.course.map<DropdownMenuItem<dynamic>>((course) {
                        return DropdownMenuItem<dynamic>(
                          value: course,
                          child: Text(
                            course.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCourse = value;
                      if (value != null) {
                        provider.AdminfetchBatchForCourseProvider(
                          value.courseId,
                        );
                      }
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              if (selectedCourse != null) ...[
                // Batch Section Header
                Text(
                  'Batch',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Search and Create Button Row
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              CupertinoIcons.search,
                              size: 20,
                              color: Colors.grey,
                            ),
                            hintText: 'Search',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => _showBatchDialog(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            maximumSize: const Size(254, 44),
                            minimumSize:
                                screenWidth < 800 ? null : const Size(150, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: const Color(0xFF00C746),
                          ),
                          child:
                              screenWidth < 800
                                  ? const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Create batch',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Batch List
                _buildBatchList(provider),
              ],
            ],
          ),
        ),
      ),
    );
  }

Widget _buildBatchList(AdminAuthProvider provider) {
  final batches =
      filteredBatches.isNotEmpty
          ? filteredBatches
          : (provider.courseBatches[selectedCourse.courseId] ?? []);

  if (provider.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (batches.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No batches found matching your search'
                : 'No batches available for this course',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    children: batches.map((batch) {
      return _buildBatchCard(batch, provider);
    }).toList(),
  );
}

Widget _buildBatchCard(AdminCourseBatch batch, AdminAuthProvider provider) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      
      if (isMobile) {
        return _buildMobileBatchCard(batch, provider);
      } else {
        return _buildDesktopBatchCard(batch, provider);
      }
    },
  );
}

Widget _buildDesktopBatchCard(AdminCourseBatch batch, AdminAuthProvider provider) {
  return Container(
    margin: const EdgeInsets.only(bottom: 1),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    child: Row(
      children: [
        // Groups Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.groups_outlined,
            color: Colors.grey[600],
            size: 22,
          ),
        ),
        const SizedBox(width: 16),

        // Batch Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                batch.batchName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    batch.startTime != null && batch.endTime != null
                        ? '${DateFormat('dd MMMM yyyy').format(batch.startTime!)} - ${DateFormat('dd MMMM yyyy').format(batch.endTime!)}'
                        : 'No dates set',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Action Icons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _showBatchDialog(context, batch: batch),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.edit_outlined,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () async {
                if (await _confirmDelete(context)) {
                  await _deleteBatch(provider, batch.batchId);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ],
    ),
  );
}

Widget _buildMobileBatchCard(AdminCourseBatch batch, AdminAuthProvider provider) {
  return Container(
    margin: const EdgeInsets.only(bottom: 1),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    child: Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: const ExpansionTileThemeData(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 16,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.groups_outlined,
            color: Colors.grey[600],
            size: 22,
          ),
        ),
        title: Text(
          batch.batchName,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey[600],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Duration
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        batch.startTime != null && batch.endTime != null
                            ? '${DateFormat('dd MMMM yyyy').format(batch.startTime!)} - ${DateFormat('dd MMMM yyyy').format(batch.endTime!)}'
                            : 'No dates set',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _showBatchDialog(context, batch: batch),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        if (await _confirmDelete(context)) {
                          await _deleteBatch(provider, batch.batchId);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red[400],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.red[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
