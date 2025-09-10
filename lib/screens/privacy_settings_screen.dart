import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/custom_colors.dart';

class PrivacySettingsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PrivacySettingsScreen({super.key, required this.userData});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataCollectionEnabled = true;
  bool _analyticsEnabled = true;
  bool _faceDataRetention = true;
  bool _shareDataWithThirdParty = false;
  bool _locationTracking = false;
  bool _crashReporting = true;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Debug logging
    final termsAccepted = prefs.getBool('terms_conditions_accepted') ?? false;
    print('📱 Loading privacy settings...');
    print('📱 Terms accepted: $termsAccepted');
    print('📱 All SharedPreferences keys: ${prefs.getKeys()}');
    
    setState(() {
      _dataCollectionEnabled = prefs.getBool('privacy_data_collection') ?? true;
      _analyticsEnabled = prefs.getBool('privacy_analytics') ?? true;
      _faceDataRetention = prefs.getBool('privacy_face_data') ?? true;
      _shareDataWithThirdParty = prefs.getBool('privacy_third_party') ?? false;
      _locationTracking = prefs.getBool('privacy_location') ?? false;
      _crashReporting = prefs.getBool('privacy_crash_reporting') ?? true;
      _termsAccepted = termsAccepted;
    });
  }

  Future<void> _savePrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_data_collection', _dataCollectionEnabled);
    await prefs.setBool('privacy_analytics', _analyticsEnabled);
    await prefs.setBool('privacy_face_data', _faceDataRetention);
    await prefs.setBool('privacy_third_party', _shareDataWithThirdParty);
    await prefs.setBool('privacy_location', _locationTracking);
    await prefs.setBool('privacy_crash_reporting', _crashReporting);
    await prefs.setBool('terms_conditions_accepted', _termsAccepted);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Privacy settings saved successfully'),
        backgroundColor: CustomColors.getSuccessColor(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Settings',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: CustomColors.getOnSurfaceColor(context),
          ),
        ),
        backgroundColor: CustomColors.getSurfaceColor(context),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _savePrivacySettings,
            style: TextButton.styleFrom(
              foregroundColor: CustomColors.getPrimaryColor(context),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Terms and Conditions Section
            if (!_termsAccepted) ...[
              _buildTermsSection(),
              SizedBox(height: 32),
            ],
            
            _buildSectionHeader('Data Collection'),
            SizedBox(height: 16),

            _buildSettingTile(
              'Data Collection',
              'Allow app to collect usage data for improvement',
              _dataCollectionEnabled,
              (value) => setState(() => _dataCollectionEnabled = value),
            ),

            _buildSettingTile(
              'Analytics',
              'Help improve the app by sharing anonymous usage statistics',
              _analyticsEnabled,
              (value) => setState(() => _analyticsEnabled = value),
            ),

            _buildSettingTile(
              'Crash Reporting',
              'Automatically send crash reports to help fix issues',
              _crashReporting,
              (value) => setState(() => _crashReporting = value),
            ),

            SizedBox(height: 32),

            _buildSectionHeader('Face Recognition Data'),
            SizedBox(height: 16),

            _buildSettingTile(
              'Face Data Retention',
              'Store face recognition data for faster authentication',
              _faceDataRetention,
              (value) => setState(() => _faceDataRetention = value),
            ),

            SizedBox(height: 32),

            _buildSectionHeader('Third-Party Sharing'),
            SizedBox(height: 16),

            _buildSettingTile(
              'Share with Partners',
              'Allow sharing anonymized data with trusted partners',
              _shareDataWithThirdParty,
              (value) => setState(() => _shareDataWithThirdParty = value),
            ),

            _buildSettingTile(
              'Location Tracking',
              'Allow location data for attendance verification',
              _locationTracking,
              (value) => setState(() => _locationTracking = value),
            ),

            SizedBox(height: 32),

            _buildSectionHeader('Data Management'),
            SizedBox(height: 16),

            _buildActionButton(
              'Download My Data',
              'Request a copy of all your stored data',
              Icons.download,
              _downloadData,
            ),

            SizedBox(height: 16),

            _buildActionButton(
              'Delete My Account',
              'Permanently delete your account and all data',
              Icons.delete_forever,
              _showDeleteAccountDialog,
              isDestructive: true,
            ),

            SizedBox(height: 32),

            _buildPrivacyInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CustomColors.getPrimaryColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CustomColors.getPrimaryColor(context).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel,
                color: CustomColors.getPrimaryColor(context),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Terms and Conditions',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.getPrimaryColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'By using EduVision, you agree to our Terms and Conditions and Privacy Policy. Please read and accept to continue using the app.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: CustomColors.getOnSurfaceColor(context).withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() {
                    _termsAccepted = value ?? false;
                  });
                },
                activeColor: CustomColors.getPrimaryColor(context),
              ),
              Expanded(
                child: Text(
                  'I have read and agree to the Terms and Conditions',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.getOnSurfaceColor(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: _showTermsAndConditions,
                child: Text(
                  'Read Terms & Conditions',
                  style: GoogleFonts.inter(
                    color: CustomColors.getPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _termsAccepted ? _acceptTerms : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Accept & Continue',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: CustomColors.getOnSurfaceColor(context),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColors.getSecondaryColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CustomColors.getOnSurfaceColor(context),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: CustomColors.getOnSurfaceColor(
                      context,
                    ).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: CustomColors.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? CustomColors.getErrorColor(context)
        : CustomColors.getPrimaryColor(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CustomColors.getSecondaryColor(
              context,
            ).withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Privacy Information',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Your privacy is important to us. We only collect data necessary to provide and improve our services. Face recognition data is encrypted and stored securely. You can request data deletion at any time.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8),
          InkWell(
            onTap: _showPrivacyPolicy,
            child: Text(
              'Read our Privacy Policy →',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download Data'),
        content: Text(
          'Your data download request has been submitted. You will receive an email with your data within 24-48 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Account deletion request submitted. You will be contacted for verification.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_conditions_accepted', true);
    
    // Debug logging
    print('💾 Saving terms acceptance: true');
    print('💾 All SharedPreferences keys after save: ${prefs.getKeys()}');
    
    setState(() {
      _termsAccepted = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terms and Conditions accepted successfully!'),
        backgroundColor: CustomColors.getSuccessColor(context),
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms and Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'EduVision Terms and Conditions\n\n'
            '1. Acceptance of Terms: By using this app, you agree to these terms.\n\n'
            '2. Use of Service: This app is for educational purposes only.\n\n'
            '3. Face Recognition: We use face recognition for attendance and security.\n\n'
            '4. Data Privacy: Your data is protected and not shared with third parties.\n\n'
            '5. User Responsibilities: Use the app responsibly and follow school policies.\n\n'
            '6. Prohibited Uses: No unauthorized access or misuse of the system.\n\n'
            '7. Privacy Policy: Please read our Privacy Policy for data handling details.\n\n'
            '8. Changes: We may update these terms from time to time.\n\n'
            '9. Contact: For questions, contact your school administrator.\n\n'
            'Last updated: ${DateTime.now().year}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'EduVision Privacy Policy\n\n'
            '1. Data Collection: We collect minimal data necessary for app functionality.\n\n'
            '2. Face Recognition: Biometric data is encrypted and stored locally when possible.\n\n'
            '3. Third Parties: We do not sell your data to third parties.\n\n'
            '4. Security: We use industry-standard encryption.\n\n'
            '5. Your Rights: You can request data deletion or download at any time.\n\n'
            'Last updated: ${DateTime.now().year}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
