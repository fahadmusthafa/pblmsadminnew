import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pb_lms/models/fahad/model.dart';
import 'package:pb_lms/providers/fahad/student_and_grievance_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  dynamic selectedCourse;
  dynamic selectedBatch;
  bool _isLoading = true;
  // Add a key to force rebuild of LiveSessionManagement when batch changes
  Key _liveSessionKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() async {
    final provider = Provider.of<AdminAuthProvider>(context, listen: false);
    try {
      await provider.AdminfetchCoursesprovider();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading courses: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminAuthProvider>(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              // Header Section
              Text(
                'Live course management',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth < 600 ? 32 : 64,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                'Select your course and batch and manage live sessions here.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // Course and Batch Selection Row
              screenWidth < 800
                  ? Column(
                    children: [
                      _buildCourseSection(provider, screenWidth),
                      const SizedBox(height: 20),
                      _buildBatchSection(provider, screenWidth),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: _buildCourseSection(provider, screenWidth),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildBatchSection(provider, screenWidth),
                      ),
                    ],
                  ),

              const SizedBox(height: 40),

              // Live Session Management
              if (selectedCourse != null && selectedBatch != null)
                LiveSessionManagement(
                  key: _liveSessionKey, // Use key to force rebuild
                  courseId: selectedCourse.courseId,
                  batchId: selectedBatch.batchId,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseSection(AdminAuthProvider provider, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your course',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 44,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: selectedCourse,
              hint: Text(
                'Select a course',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey.shade600,
              ),
              items:
                  provider.course.isNotEmpty
                      ? provider.course.map<DropdownMenuItem<dynamic>>((
                        course,
                      ) {
                        return DropdownMenuItem<dynamic>(
                          value: course,
                          child: Text(
                            course.name ?? 'Unknown Course',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        );
                      }).toList()
                      : [
                        DropdownMenuItem<dynamic>(
                          value: null,
                          enabled: false,
                          child: Text(
                            'No courses available',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
              onChanged:
                  provider.course.isNotEmpty
                      ? (dynamic newCourse) {
                        setState(() {
                          selectedCourse = newCourse;
                          selectedBatch = null; // Reset batch when course changes
                          _liveSessionKey = UniqueKey(); // Generate new key
                        });
                        if (newCourse != null) {
                          provider.AdminfetchBatchForCourseProvider(
                            newCourse.courseId,
                          );
                        }
                      }
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchSection(AdminAuthProvider provider, double screenWidth) {
    final batches =
        selectedCourse != null
            ? (provider.courseBatches[selectedCourse.courseId] ?? [])
            : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your batch',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 44,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: selectedCourse != null ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              value: selectedBatch,
              hint: Text(
                selectedCourse == null
                    ? 'Select a course first'
                    : 'Select a batch',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color:
                      selectedCourse == null
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color:
                    selectedCourse != null
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
              ),
              items:
                  selectedCourse == null
                      ? null
                      : batches.isEmpty
                      ? [
                        DropdownMenuItem<dynamic>(
                          value: null,
                          enabled: false,
                          child: Text(
                            'No batches available',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ]
                      : batches.map<DropdownMenuItem<dynamic>>((batch) {
                        return DropdownMenuItem<dynamic>(
                          value: batch,
                          child: Text(
                            batch.batchName ?? 'Unknown Batch',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        );
                      }).toList(),
              onChanged:
                  selectedCourse == null || batches.isEmpty
                      ? null
                      : (dynamic newBatch) {
                        setState(() {
                          selectedBatch = newBatch;
                          _liveSessionKey = UniqueKey(); // Generate new key to trigger rebuild
                        });
                      },
            ),
          ),
        ),
      ],
    );
  }
}

class LiveSessionManagement extends StatefulWidget {
  final int courseId;
  final int batchId;

  const LiveSessionManagement({
    super.key,
    required this.courseId,
    required this.batchId,
  });

  @override
  State<LiveSessionManagement> createState() => _LiveSessionManagementState();
}

class _LiveSessionManagementState extends State<LiveSessionManagement> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _liveLinkController = TextEditingController();
  DateTime? _selectedDateTime;
  late Future<AdminLiveLinkResponse?> liveDataFuture;

  @override
  void initState() {
    super.initState();
    _refreshLiveData();
  }

  // Add didUpdateWidget to handle when batchId changes
  @override
  void didUpdateWidget(LiveSessionManagement oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If batchId has changed, refresh the live data
    if (oldWidget.batchId != widget.batchId) {
      _refreshLiveData();
    }
  }

  void _refreshLiveData() {
    setState(() {
      liveDataFuture = Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      ).AdminfetchLiveAdmin(widget.batchId);
    });
  }

  Future<void> _launchLiveLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch the live link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCreateLiveSession() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create live session',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Live session link
          Text(
            'Live session link',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _liveLinkController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a live session link';
              }
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasAbsolutePath) {
                return 'Please enter a valid URL';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter live session link',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black54),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),

          screenWidth < 800
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateTimeSection(),
                  const SizedBox(height: 20),
                  _buildCreateButton(),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _buildDateTimeSection()),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 200,
                    child: _buildCreateButton(),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your date and time',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? date = await showDatePicker(
              context: context,
              initialDate: _selectedDateTime ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (date != null && mounted) {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null && mounted) {
                setState(() {
                  _selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Select date and time'
                        : DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(_selectedDateTime!),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color:
                          _selectedDateTime == null
                              ? Colors.grey.shade600
                              : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            if (_selectedDateTime == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select date and time'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            try {
              await context
                  .read<AdminAuthProvider>()
                  .AdmincreateLivelinkprovider(
                    widget.batchId,
                    _liveLinkController.text,
                    _selectedDateTime!,
                  );

              _refreshLiveData();
              _liveLinkController.clear();
              setState(() {
                _selectedDateTime = null;
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Live session created successfully'),
                    backgroundColor: Color.fromARGB(255, 12, 201, 70),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error creating live session: ${e.toString()}',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 12, 201, 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Create live',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveLiveSession(AdminLiveLinkResponse liveLink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          'Active live session',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      liveLink.liveLink,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _launchLiveLink(liveLink.liveLink),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        'Open live link',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _deleteLiveLink,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'dd MMMM yyyy - HH:mm',
                    ).format(liveLink.liveStartTime),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _deleteLiveLink() async {
    try {
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Live Session',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to delete this live session?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (shouldDelete == true && mounted) {
        await context.read<AdminAuthProvider>().AdmindeleteLiveprovider(
          widget.courseId,
          widget.batchId,
        );
        _refreshLiveData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live session deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting live session: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(AdminLiveLinkResponse liveLink) async {
    final TextEditingController editLinkController = TextEditingController(
      text: liveLink.liveLink,
    );
    DateTime? editDateTime = liveLink.liveStartTime;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Edit Live Session',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: editLinkController,
                      decoration: InputDecoration(
                        labelText: 'Live Link',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: editDateTime ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              editDateTime ?? DateTime.now(),
                            ),
                          );
                          if (time != null) {
                            setDialogState(() {
                              editDateTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy HH:mm',
                              ).format(editDateTime!),
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<AdminAuthProvider>().AdminupdateLive(
                        widget.batchId,
                        editLinkController.text,
                        editDateTime!,
                      );
                      Navigator.of(context).pop();
                      _refreshLiveData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Live session updated successfully'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error updating live session: ${e.toString()}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 12, 201, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Update',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCreateLiveSession(),
        FutureBuilder<AdminLiveLinkResponse?>(
          future: liveDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData && snapshot.data != null) {
              return _buildActiveLiveSession(snapshot.data!);
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _liveLinkController.dispose();
    super.dispose();
  }
}