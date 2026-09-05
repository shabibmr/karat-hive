// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Karat Hive Admin Portal';

  @override
  String get loginTitle => 'PLATFORM ADMIN';

  @override
  String get loginSubtitle => 'Karat Hive Internal Management Portal';

  @override
  String get loginInstructions =>
      'Please sign in with your administrative credentials.';

  @override
  String get emailLabel => 'Admin Email';

  @override
  String get emailHint => 'admin@karathive.ae';

  @override
  String get emailRequired => 'Admin email is required';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get signInButton => 'Authenticate & Enter Portal';

  @override
  String get signingIn => 'Authenticating...';

  @override
  String get errorAccountLocked =>
      'Your administrative account has been temporarily locked due to consecutive failed login attempts. Please wait 30 minutes or contact security.';

  @override
  String get errorInvalidCredentials =>
      'Invalid administrative credentials. Please check your email and password.';

  @override
  String get errorServerUnavailable =>
      'Administrative service unavailable. Please check your connection and try again.';

  @override
  String get errorUnknown => 'An unexpected error occurred. Please try again.';

  @override
  String get categoriesTitle => 'Category Management';

  @override
  String get categoriesSubtitle =>
      'Manage two-level product category taxonomy for requests and vendor specialisations.';

  @override
  String get regionsTitle => 'Region Management';

  @override
  String get regionsSubtitle =>
      'Manage geographic matching taxonomy (emirates and areas) for marketplace routing.';

  @override
  String get showInactive => 'Show Inactive';

  @override
  String get hideInactive => 'Hide Inactive';

  @override
  String get addRootCategory => '+ Add Category';

  @override
  String get addRootRegion => '+ Add Region';

  @override
  String get addChildCategory => 'Add Subcategory';

  @override
  String get addChildRegion => 'Add Area';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get editRegion => 'Edit Region';

  @override
  String get createRootCategory => 'New Root Category';

  @override
  String get createRootRegion => 'New Root Region';

  @override
  String get newChildCategory => 'New Subcategory';

  @override
  String get newChildRegion => 'New Area';

  @override
  String get nameEnLabel => 'Name (English)';

  @override
  String get nameArLabel => 'Name (Arabic)';

  @override
  String get nameEnRequired => 'English name is required and cannot be blank';

  @override
  String get nameArRequired => 'Arabic name is required and cannot be blank';

  @override
  String get iconLabel => 'Icon';

  @override
  String get displayOrderLabel => 'Display Order';

  @override
  String get activeStatusLabel => 'Active Status';

  @override
  String get activeStatusDescription =>
      'Inactive nodes are hidden from customer/vendor selection but preserve existing associations.';

  @override
  String get saveButton => 'Save Changes';

  @override
  String get createButton => 'Create';

  @override
  String get deactivateButton => 'Deactivate';

  @override
  String deactivateConfirmTitle(String name) {
    return 'Deactivate $name?';
  }

  @override
  String deactivateConfirmBody(String name) {
    return 'Are you sure you want to deactivate \"$name\"? Inactive nodes cannot be selected for new requests, but existing associations are preserved. This action can be reversed later.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmDeactivate => 'Deactivate';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get emptyCategoriesTitle => 'No Categories Found';

  @override
  String get emptyCategoriesBody =>
      'No product categories have been configured yet. Create a root category to start building the taxonomy.';

  @override
  String get emptyRegionsTitle => 'No Regions Found';

  @override
  String get emptyRegionsBody =>
      'No regions have been configured yet. Create a root emirate or region to begin.';

  @override
  String get toastCategoryCreated => 'Category created successfully.';

  @override
  String get toastCategoryUpdated => 'Category updated successfully.';

  @override
  String get toastCategoryDeactivated => 'Category deactivated successfully.';

  @override
  String get toastRegionCreated => 'Region created successfully.';

  @override
  String get toastRegionUpdated => 'Region updated successfully.';

  @override
  String get toastRegionDeactivated => 'Region deactivated successfully.';

  @override
  String get levelLimitReached =>
      'Maximum hierarchy depth reached (2 levels). Cannot add children to this node.';

  @override
  String get selectNodeToEdit =>
      'Select a node from the tree to edit or create a child, or create a new root node.';
}
