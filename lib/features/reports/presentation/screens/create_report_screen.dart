import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:video_player/video_player.dart';

import 'package:saliena_app/core/config/app_config.dart';
import 'package:saliena_app/core/services/video_service.dart';
import 'package:saliena_app/core/services/exif_gps_service.dart';
import 'package:saliena_app/core/services/offline_queue_service.dart';
import 'package:saliena_app/core/network/network_info.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:saliena_app/l10n/app_localizations.dart';
import 'package:saliena_app/routing/routes.dart';
import 'package:saliena_app/injection.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _videoService = VideoServiceImpl();
  final _exifGpsService = ExifGpsService();
  
  final List<XFile> _selectedImages = [];
  XFile? _selectedVideo;
  VideoPlayerController? _videoController;
  Position? _currentPosition;
  Position? _photoGpsPosition; // GPS from photo EXIF
  String? _currentAddress;
  bool _isSubmitting = false;
  bool _isOnline = true;
  String? _locationSource; // 'photo_exif', 'device_gps', or 'manual'

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final networkInfo = getIt<NetworkInfo>();
    final connected = await networkInfo.isConnected;
    setState(() {
      _isOnline = connected;
    });

    // Listen to connectivity changes
    networkInfo.onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          _isOnline = status == InternetStatus.connected;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          if (mounted) {
            _showError(AppLocalizations.of(context)!.locationPermissionDenied);
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentPosition = position;
          if (_photoGpsPosition == null) {
            // Only use device GPS if we don't have photo GPS
            _currentAddress = '${place.street}, ${place.locality}';
            _locationSource = 'device_gps';
          }
        });
      } else {
        setState(() {
          _currentPosition = position;
          if (_photoGpsPosition == null) {
            _locationSource = 'device_gps';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric);
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_selectedImages.length >= AppConfig.maxPhotos) {
      _showError(AppLocalizations.of(context)!.maximumPhotosAllowed(AppConfig.maxPhotos));
      return;
    }

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // Try to extract GPS from photo EXIF data
        await _extractGpsFromPhoto(File(image.path));
        
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final remainingSlots = AppConfig.maxPhotos - _selectedImages.length;
    if (remainingSlots <= 0) {
      _showError(AppLocalizations.of(context)!.maximumPhotosAllowed(AppConfig.maxPhotos));
      return;
    }

    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final imagesToAdd = images.take(remainingSlots).toList();
        
        // Try to extract GPS from first photo
        if (imagesToAdd.isNotEmpty) {
          await _extractGpsFromPhoto(File(imagesToAdd.first.path));
        }
        
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          if (mounted) {
            _showError(AppLocalizations.of(context)!.onlyMorePhotosAllowed(remainingSlots));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric);
      }
    }
  }

  /// Extract GPS coordinates from photo EXIF data.
  Future<void> _extractGpsFromPhoto(File imageFile) async {
    try {
      final gpsData = await _exifGpsService.extractGpsFromImage(imageFile);
      
      if (gpsData != null) {
        // GPS found in photo EXIF - use this as primary location
        final photoPosition = Position(
          latitude: gpsData.latitude,
          longitude: gpsData.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        // Get address for photo location
        try {
          final placemarks = await placemarkFromCoordinates(
            gpsData.latitude,
            gpsData.longitude,
          );
          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            setState(() {
              _photoGpsPosition = photoPosition;
              _currentAddress = '${place.street}, ${place.locality}';
              _locationSource = 'photo_exif';
            });
            
            if (mounted) {
              _showSuccess('📍 Location extracted from photo GPS');
            }
            return;
          }
        } catch (e) {
          // Address lookup failed, but we still have GPS
          setState(() {
            _photoGpsPosition = photoPosition;
            _locationSource = 'photo_exif';
          });
          
          if (mounted) {
            _showSuccess('📍 Location extracted from photo GPS');
          }
          return;
        }
      }
    } catch (e) {
      // EXIF extraction failed, will fall back to device GPS
      debugPrint('Failed to extract GPS from photo: $e');
    }
  }

  Future<void> _recordVideo() async {
    if (_selectedVideo != null) {
      _showError(AppLocalizations.of(context)!.onlyOneVideoAllowed);
      return;
    }

    try {
      final result = await _videoService.captureFromCamera();
      
      result.fold(
        onSuccess: (videoData) async {
          // Create temporary file to display video
          final tempFile = XFile.fromData(
            videoData.bytes,
            name: videoData.fileName,
            mimeType: videoData.mimeType,
          );

          final controller = VideoPlayerController.file(File(tempFile.path));
          await controller.initialize();

          setState(() {
            _selectedVideo = tempFile;
            _videoController = controller;
          });
        },
        onFailure: (failure) {
          _showError(failure.message);
        },
      );
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric);
      }
    }
  }

  Future<void> _pickVideo() async {
    if (_selectedVideo != null) {
      _showError(AppLocalizations.of(context)!.onlyOneVideoAllowed);
      return;
    }

    try {
      final result = await _videoService.pickFromGallery();
      
      result.fold(
        onSuccess: (videoData) async {
          // Create temporary file to display video
          final tempFile = XFile.fromData(
            videoData.bytes,
            name: videoData.fileName,
            mimeType: videoData.mimeType,
          );

          final controller = VideoPlayerController.file(File(tempFile.path));
          await controller.initialize();

          setState(() {
            _selectedVideo = tempFile;
            _videoController = controller;
          });
        },
        onFailure: (failure) {
          _showError(failure.message);
        },
      );
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric);
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _videoController?.dispose();
      _videoController = null;
      _selectedVideo = null;
    });
  }

  Future<void> _submitReport() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;

    // Allow submission without media
    if (_selectedImages.isEmpty && _selectedVideo == null) {
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.noMedia),
          content: Text(l10n.areYouSureSubmitWithoutMedia),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.submitAnyway),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    // Use photo GPS if available, otherwise device GPS
    final locationToUse = _photoGpsPosition ?? _currentPosition;
    
    if (locationToUse == null) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context)!.locationRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final List<Uint8List> photoBytesList = [];
      final List<String> photoFileNames = [];

      for (final image in _selectedImages) {
        final bytes = await image.readAsBytes();
        photoBytesList.add(bytes);
        photoFileNames.add(image.name);
      }

      Uint8List? videoBytes;
      String? videoFileName;
      if (_selectedVideo != null) {
        videoBytes = await _selectedVideo!.readAsBytes();
        videoFileName = _selectedVideo!.name;
      }

      if (!mounted) return;

      // Check if online
      if (!_isOnline) {
        // Queue for offline submission
        await _queueOfflineReport(
          photoBytesList: photoBytesList,
          photoFileNames: photoFileNames,
          videoBytes: videoBytes,
          videoFileName: videoFileName,
          latitude: locationToUse.latitude,
          longitude: locationToUse.longitude,
        );
        return;
      }

      // Submit online
      context.read<ReportsBloc>().add(
        ReportCreateRequested(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          photoBytesList: photoBytesList,
          photoFileNames: photoFileNames,
          videoBytes: videoBytes,
          videoFileName: videoFileName,
          latitude: locationToUse.latitude,
          longitude: locationToUse.longitude,
          address: _currentAddress,
        ),
      );
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorGeneric);
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _queueOfflineReport({
    required List<Uint8List> photoBytesList,
    required List<String> photoFileNames,
    Uint8List? videoBytes,
    String? videoFileName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final offlineQueue = getIt<OfflineQueueService>();
      await offlineQueue.queueReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoBytesList: photoBytesList,
        photoFileNames: photoFileNames,
        videoBytes: videoBytes,
        videoFileName: videoFileName,
        latitude: latitude,
        longitude: longitude,
        address: _currentAddress,
      );

      if (!mounted) return;
      
      setState(() => _isSubmitting = false);
      
      _showSuccess('📤 Report queued for upload when online');
      
      // Navigate to offline queue screen
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go(Routes.offlineQueue);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to queue report: ${e.toString()}');
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SalienaColors.iconGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SalienaColors.getNavy(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMedia = _selectedImages.isNotEmpty || _selectedVideo != null;
    final canAddPhotos = _selectedImages.length < AppConfig.maxPhotos;
    final canAddVideo = _selectedVideo == null;

    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reportSubmittedSuccess),
              backgroundColor: SalienaColors.iconGreen,
            ),
          );
          context.go(Routes.myReports);
        } else if (state is ReportCreateError) {
          setState(() => _isSubmitting = false);
          _showError(l10n.errorGeneric);
        }
      },
      child: Scaffold(
        backgroundColor: SalienaColors.getBackgroundBlue(context),
        body: SafeArea(
          child: Column(
            children: [
              // Offline banner
              if (!_isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.orange.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, color: Colors.orange.shade900, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '📤 Offline - Reports will be queued for upload',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Location source indicator
              if (_locationSource != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: SalienaColors.iconGreen.withValues(alpha: 0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: SalienaColors.iconGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _locationSource == 'photo_exif' 
                            ? Icons.photo_camera 
                            : Icons.my_location,
                        color: SalienaColors.iconGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _locationSource == 'photo_exif'
                            ? '📍 ${l10n.locationFromPhoto}'
                            : '📍 ${l10n.locationFromDeviceGPS}',
                        style: TextStyle(
                          color: SalienaColors.iconGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context, l10n),
                        const SizedBox(height: 24),
                        _buildTitleField(context, l10n),
                        const SizedBox(height: 16),
                        _buildDescriptionField(context, l10n),
                        const SizedBox(height: 24),
                        
                        // Media section header
                        Text(
                          l10n.addMediaOptional,
                          style: TextStyle(
                            color: SalienaColors.getTextColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addMediaSubtitle(AppConfig.maxPhotos, AppConfig.maxVideoDurationSeconds),
                          style: TextStyle(
                            color: SalienaColors.getHintColor(context),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Media preview
                        if (hasMedia) ...[
                          _buildMediaPreview(),
                          const SizedBox(height: 16),
                        ],
                        
                        // Photo buttons
                        if (canAddPhotos) ...[
                          SalienaSecondaryButton(
                            text: '📷 ${l10n.takePhoto} (${_selectedImages.length}/${AppConfig.maxPhotos})',
                            onPressed: _isSubmitting ? null : _takePhoto,
                          ),
                          const SizedBox(height: 12),
                          SalienaSecondaryButton(
                            text: '🖼️ ${l10n.choosePhoto} (${_selectedImages.length}/${AppConfig.maxPhotos})',
                            onPressed: _isSubmitting ? null : _pickFromGallery,
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Video buttons
                        if (canAddVideo) ...[
                          SalienaSecondaryButton(
                            text: '🎥 ${l10n.recordVideoWithDuration(AppConfig.maxVideoDurationSeconds)}',
                            onPressed: _isSubmitting ? null : _recordVideo,
                          ),
                          const SizedBox(height: 12),
                          SalienaSecondaryButton(
                            text: '📹 ${l10n.chooseVideo}',
                            onPressed: _isSubmitting ? null : _pickVideo,
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        _buildSubmitButton(context, l10n),
                      ],
                    ),
                  ),
                ),
              ),
              SalienaBottomNav(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 80,
          child: SalienaLogo(
            withText: false,
            scale: 1.6,
            isDarkBackground: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        Text(
          l10n.report,
          style: TextStyle(
            color: SalienaColors.getTextColor(context),
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: SalienaColors.getTextFieldBackground(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: _titleController,
        maxLength: 30,
        style: TextStyle(
          color: SalienaColors.getTextColor(context),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: l10n.reportTitle,
          hintStyle: TextStyle(
            color: SalienaColors.getTextFieldHint(context),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.pleaseEnterTitle;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: SalienaColors.getTextFieldBackground(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          color: SalienaColors.getTextColor(context),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: l10n.describeTheIssue,
          hintStyle: TextStyle(
            color: SalienaColors.getTextFieldHint(context),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.reportDescriptionHint;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photos preview
        if (_selectedImages.isNotEmpty) ...[
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_selectedImages[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: SalienaColors.getNavy(context),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        
        // Video preview
        if (_selectedVideo != null && _videoController != null) ...[
          if (_selectedImages.isNotEmpty) const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _removeVideo,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SalienaColors.getNavy(context),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_videoController!.value.duration.inSeconds}s',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return SalienaPrimaryButton(
      text: l10n.submitReport,
      isLoading: _isSubmitting,
      onPressed: _isSubmitting ? null : _submitReport,
    );
  }
}
