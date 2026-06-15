import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MarketX'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navStores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get navStores;

  /// No description provided for @navUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navUsers;

  /// No description provided for @navFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// No description provided for @navCms.
  ///
  /// In en, this message translates to:
  /// **'CMS'**
  String get navCms;

  /// No description provided for @navAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit'**
  String get navAudit;

  /// No description provided for @navActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get navActive;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @common_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get common_seeAll;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get common_error;

  /// No description provided for @common_empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get common_empty;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

  /// No description provided for @common_required.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get common_required;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get auth_register;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirmPassword;

  /// No description provided for @auth_fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_fullName;

  /// No description provided for @auth_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phone;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get auth_otpTitle;

  /// No description provided for @auth_otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your phone'**
  String get auth_otpSubtitle;

  /// No description provided for @auth_signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get auth_signInWithGoogle;

  /// No description provided for @auth_dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_dontHaveAccount;

  /// No description provided for @auth_alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_alreadyHaveAccount;

  /// No description provided for @auth_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get auth_invalidEmail;

  /// No description provided for @auth_passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get auth_passwordTooShort;

  /// No description provided for @auth_passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get auth_passwordMismatch;

  /// No description provided for @auth_resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get auth_resendCode;

  /// No description provided for @onboarding_title1.
  ///
  /// In en, this message translates to:
  /// **'Discover Local Stores'**
  String get onboarding_title1;

  /// No description provided for @onboarding_title2.
  ///
  /// In en, this message translates to:
  /// **'Shop From Multiple Vendors'**
  String get onboarding_title2;

  /// No description provided for @onboarding_title3.
  ///
  /// In en, this message translates to:
  /// **'Fast Delivery To Your Door'**
  String get onboarding_title3;

  /// No description provided for @onboarding_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_getStarted;

  /// No description provided for @home_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get home_featured;

  /// No description provided for @home_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get home_categories;

  /// No description provided for @home_bestSellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get home_bestSellers;

  /// No description provided for @home_nearbyStores.
  ///
  /// In en, this message translates to:
  /// **'Nearby Stores'**
  String get home_nearbyStores;

  /// No description provided for @home_forYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get home_forYou;

  /// No description provided for @home_searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products, stores...'**
  String get home_searchPlaceholder;

  /// No description provided for @product_addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get product_addToCart;

  /// No description provided for @product_outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get product_outOfStock;

  /// No description provided for @product_inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get product_inStock;

  /// No description provided for @product_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get product_reviews;

  /// No description provided for @product_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get product_description;

  /// No description provided for @product_relatedProducts.
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get product_relatedProducts;

  /// No description provided for @product_notifyBackInStock.
  ///
  /// In en, this message translates to:
  /// **'Notify me when back in stock'**
  String get product_notifyBackInStock;

  /// No description provided for @product_notifyPriceDrop.
  ///
  /// In en, this message translates to:
  /// **'Notify me on price drop'**
  String get product_notifyPriceDrop;

  /// No description provided for @product_alertSet.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you'**
  String get product_alertSet;

  /// No description provided for @product_alertRemoved.
  ///
  /// In en, this message translates to:
  /// **'Alert removed'**
  String get product_alertRemoved;

  /// No description provided for @reviews_title.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews_title;

  /// No description provided for @reviews_empty.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviews_empty;

  /// No description provided for @reviews_writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get reviews_writeReview;

  /// No description provided for @reviews_yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get reviews_yourRating;

  /// No description provided for @reviews_comment.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get reviews_comment;

  /// No description provided for @reviews_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviews_submit;

  /// No description provided for @reviews_submitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review'**
  String get reviews_submitted;

  /// No description provided for @reviews_alreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'You have already reviewed this product'**
  String get reviews_alreadyReviewed;

  /// No description provided for @cart_title.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get cart_title;

  /// No description provided for @cart_empty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_empty;

  /// No description provided for @cart_checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get cart_checkout;

  /// No description provided for @cart_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get cart_subtotal;

  /// No description provided for @cart_deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get cart_deliveryFee;

  /// No description provided for @cart_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get cart_discount;

  /// No description provided for @cart_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cart_total;

  /// No description provided for @checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout_title;

  /// No description provided for @checkout_deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get checkout_deliveryAddress;

  /// No description provided for @checkout_paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get checkout_paymentMethod;

  /// No description provided for @checkout_cash.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get checkout_cash;

  /// No description provided for @checkout_card.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Card'**
  String get checkout_card;

  /// No description provided for @checkout_wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get checkout_wallet;

  /// No description provided for @checkout_placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get checkout_placeOrder;

  /// No description provided for @checkout_couponCode.
  ///
  /// In en, this message translates to:
  /// **'Coupon Code'**
  String get checkout_couponCode;

  /// No description provided for @checkout_applyCoupon.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get checkout_applyCoupon;

  /// No description provided for @checkout_addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get checkout_addAddress;

  /// No description provided for @checkout_addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g. Home, Work)'**
  String get checkout_addressLabel;

  /// No description provided for @checkout_fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get checkout_fullAddress;

  /// No description provided for @checkout_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get checkout_city;

  /// No description provided for @checkout_noAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet'**
  String get checkout_noAddresses;

  /// No description provided for @checkout_selectAddress.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Address'**
  String get checkout_selectAddress;

  /// No description provided for @checkout_orderNotes.
  ///
  /// In en, this message translates to:
  /// **'Order Notes (optional)'**
  String get checkout_orderNotes;

  /// No description provided for @checkout_orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get checkout_orderPlaced;

  /// No description provided for @checkout_emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get checkout_emptyCart;

  /// No description provided for @checkout_couponApplied.
  ///
  /// In en, this message translates to:
  /// **'Coupon applied'**
  String get checkout_couponApplied;

  /// No description provided for @checkout_couponInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired coupon'**
  String get checkout_couponInvalid;

  /// No description provided for @checkout_couponNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Coupon does not apply to your cart'**
  String get checkout_couponNotApplicable;

  /// No description provided for @checkout_couponMinOrder.
  ///
  /// In en, this message translates to:
  /// **'Order total too low for this coupon'**
  String get checkout_couponMinOrder;

  /// No description provided for @checkout_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get checkout_remove;

  /// No description provided for @checkout_insufficientWallet.
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance'**
  String get checkout_insufficientWallet;

  /// No description provided for @checkout_deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery Option'**
  String get checkout_deliveryType;

  /// No description provided for @checkout_immediate.
  ///
  /// In en, this message translates to:
  /// **'Standard Delivery'**
  String get checkout_immediate;

  /// No description provided for @checkout_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Delivery'**
  String get checkout_scheduled;

  /// No description provided for @checkout_pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get checkout_pickup;

  /// No description provided for @checkout_selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select date & time'**
  String get checkout_selectTime;

  /// No description provided for @checkout_scheduledAt.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for'**
  String get checkout_scheduledAt;

  /// No description provided for @orders_title.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get orders_title;

  /// No description provided for @orders_empty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orders_empty;

  /// No description provided for @orders_items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orders_items;

  /// No description provided for @orders_orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orders_orderDetails;

  /// No description provided for @orders_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orders_status_pending;

  /// No description provided for @orders_status_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orders_status_confirmed;

  /// No description provided for @orders_status_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orders_status_preparing;

  /// No description provided for @orders_status_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orders_status_ready;

  /// No description provided for @orders_status_pickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get orders_status_pickedUp;

  /// No description provided for @orders_status_onWay.
  ///
  /// In en, this message translates to:
  /// **'On the Way'**
  String get orders_status_onWay;

  /// No description provided for @orders_status_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orders_status_delivered;

  /// No description provided for @orders_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orders_status_cancelled;

  /// No description provided for @orders_status_refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get orders_status_refunded;

  /// No description provided for @store_about.
  ///
  /// In en, this message translates to:
  /// **'About Store'**
  String get store_about;

  /// No description provided for @store_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get store_products;

  /// No description provided for @store_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get store_reviews;

  /// No description provided for @store_workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get store_workingHours;

  /// No description provided for @store_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get store_open;

  /// No description provided for @store_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get store_closed;

  /// No description provided for @store_minOrder.
  ///
  /// In en, this message translates to:
  /// **'Min. order'**
  String get store_minOrder;

  /// No description provided for @profile_myWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get profile_myWallet;

  /// No description provided for @profile_loyaltyPoints.
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points'**
  String get profile_loyaltyPoints;

  /// No description provided for @wallet_title.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Loyalty'**
  String get wallet_title;

  /// No description provided for @wallet_balance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get wallet_balance;

  /// No description provided for @wallet_transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get wallet_transactions;

  /// No description provided for @wallet_noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get wallet_noTransactions;

  /// No description provided for @wallet_loyaltyTab.
  ///
  /// In en, this message translates to:
  /// **'Loyalty'**
  String get wallet_loyaltyTab;

  /// No description provided for @wallet_walletTab.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet_walletTab;

  /// No description provided for @wallet_points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get wallet_points;

  /// No description provided for @wallet_noLoyalty.
  ///
  /// In en, this message translates to:
  /// **'No loyalty activity yet'**
  String get wallet_noLoyalty;

  /// No description provided for @wallet_redeemGiftCard.
  ///
  /// In en, this message translates to:
  /// **'Redeem Gift Card'**
  String get wallet_redeemGiftCard;

  /// No description provided for @wallet_giftCardCode.
  ///
  /// In en, this message translates to:
  /// **'Gift Card Code'**
  String get wallet_giftCardCode;

  /// No description provided for @wallet_redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get wallet_redeem;

  /// No description provided for @wallet_giftCardRedeemed.
  ///
  /// In en, this message translates to:
  /// **'Gift card redeemed'**
  String get wallet_giftCardRedeemed;

  /// No description provided for @wallet_giftCardInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired gift card'**
  String get wallet_giftCardInvalid;

  /// No description provided for @profile_addresses.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get profile_addresses;

  /// No description provided for @profile_wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get profile_wishlist;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @profile_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profile_darkMode;

  /// No description provided for @profile_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profile_notifications;

  /// No description provided for @profile_referral.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get profile_referral;

  /// No description provided for @referral_title.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get referral_title;

  /// No description provided for @referral_yourCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get referral_yourCode;

  /// No description provided for @referral_copy.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get referral_copy;

  /// No description provided for @referral_copied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get referral_copied;

  /// No description provided for @referral_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get referral_share;

  /// No description provided for @referral_invitedFriends.
  ///
  /// In en, this message translates to:
  /// **'Invited Friends'**
  String get referral_invitedFriends;

  /// No description provided for @referral_none.
  ///
  /// In en, this message translates to:
  /// **'No invited friends yet'**
  String get referral_none;

  /// No description provided for @referral_rewardGiven.
  ///
  /// In en, this message translates to:
  /// **'Reward given'**
  String get referral_rewardGiven;

  /// No description provided for @referral_rewardPending.
  ///
  /// In en, this message translates to:
  /// **'Reward pending'**
  String get referral_rewardPending;

  /// No description provided for @referral_intro.
  ///
  /// In en, this message translates to:
  /// **'Share your code with friends. When they sign up, you both earn rewards.'**
  String get referral_intro;

  /// No description provided for @profile_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profile_support;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get profile_about;

  /// No description provided for @profile_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profile_logoutConfirm;

  /// No description provided for @profile_guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profile_guest;

  /// No description provided for @addresses_title.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get addresses_title;

  /// No description provided for @addresses_empty.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet'**
  String get addresses_empty;

  /// No description provided for @addresses_setDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get addresses_setDefault;

  /// No description provided for @addresses_default.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get addresses_default;

  /// No description provided for @wishlist_title.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist_title;

  /// No description provided for @wishlist_empty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get wishlist_empty;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get search_hint;

  /// No description provided for @search_noResults.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get search_noResults;

  /// No description provided for @search_minChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search'**
  String get search_minChars;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_empty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifications_empty;

  /// No description provided for @notifications_markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifications_markAllRead;

  /// No description provided for @chat_title.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat_title;

  /// No description provided for @chat_typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chat_typeMessage;

  /// No description provided for @chat_empty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chat_empty;

  /// No description provided for @chat_conversations.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chat_conversations;

  /// No description provided for @chat_noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chat_noConversations;

  /// No description provided for @vendor_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get vendor_dashboard;

  /// No description provided for @vendor_totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get vendor_totalOrders;

  /// No description provided for @vendor_totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get vendor_totalRevenue;

  /// No description provided for @vendor_addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get vendor_addProduct;

  /// No description provided for @vendor_storeSettings.
  ///
  /// In en, this message translates to:
  /// **'Store Settings'**
  String get vendor_storeSettings;

  /// No description provided for @vendor_pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get vendor_pendingOrders;

  /// No description provided for @vendor_noStore.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a store yet'**
  String get vendor_noStore;

  /// No description provided for @vendor_editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get vendor_editProduct;

  /// No description provided for @vendor_deleteProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this product?'**
  String get vendor_deleteProductConfirm;

  /// No description provided for @vendor_noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get vendor_noProducts;

  /// No description provided for @vendor_noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get vendor_noOrders;

  /// No description provided for @vendor_storeName.
  ///
  /// In en, this message translates to:
  /// **'Store Name (Arabic)'**
  String get vendor_storeName;

  /// No description provided for @vendor_storeNameEn.
  ///
  /// In en, this message translates to:
  /// **'Store Name (English)'**
  String get vendor_storeNameEn;

  /// No description provided for @vendor_storeDescription.
  ///
  /// In en, this message translates to:
  /// **'Store Description'**
  String get vendor_storeDescription;

  /// No description provided for @vendor_deliveryFeeAmount.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get vendor_deliveryFeeAmount;

  /// No description provided for @vendor_minOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Amount'**
  String get vendor_minOrderAmount;

  /// No description provided for @vendor_storeActive.
  ///
  /// In en, this message translates to:
  /// **'Store Active'**
  String get vendor_storeActive;

  /// No description provided for @vendor_inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory History'**
  String get vendor_inventory;

  /// No description provided for @vendor_noInventoryLogs.
  ///
  /// In en, this message translates to:
  /// **'No inventory changes yet'**
  String get vendor_noInventoryLogs;

  /// No description provided for @vendor_reason_sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get vendor_reason_sale;

  /// No description provided for @vendor_reason_restock.
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get vendor_reason_restock;

  /// No description provided for @vendor_reason_adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get vendor_reason_adjustment;

  /// No description provided for @vendor_reason_return.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get vendor_reason_return;

  /// No description provided for @vendor_reason_damage.
  ///
  /// In en, this message translates to:
  /// **'Damage'**
  String get vendor_reason_damage;

  /// No description provided for @admin_pendingStores.
  ///
  /// In en, this message translates to:
  /// **'Pending Stores'**
  String get admin_pendingStores;

  /// No description provided for @admin_approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get admin_approve;

  /// No description provided for @admin_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get admin_reject;

  /// No description provided for @admin_suspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get admin_suspend;

  /// No description provided for @admin_totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get admin_totalUsers;

  /// No description provided for @admin_totalStores.
  ///
  /// In en, this message translates to:
  /// **'Total Stores'**
  String get admin_totalStores;

  /// No description provided for @admin_allStores.
  ///
  /// In en, this message translates to:
  /// **'All Stores'**
  String get admin_allStores;

  /// No description provided for @admin_noPendingStores.
  ///
  /// In en, this message translates to:
  /// **'No pending stores'**
  String get admin_noPendingStores;

  /// No description provided for @admin_activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get admin_activate;

  /// No description provided for @admin_deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get admin_deactivate;

  /// No description provided for @admin_noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get admin_noUsers;

  /// No description provided for @admin_banners.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get admin_banners;

  /// No description provided for @admin_addBanner.
  ///
  /// In en, this message translates to:
  /// **'Add Banner'**
  String get admin_addBanner;

  /// No description provided for @admin_noBanners.
  ///
  /// In en, this message translates to:
  /// **'No banners yet'**
  String get admin_noBanners;

  /// No description provided for @admin_noAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'No audit log entries'**
  String get admin_noAuditLogs;

  /// No description provided for @admin_financeOverview.
  ///
  /// In en, this message translates to:
  /// **'Finance Overview'**
  String get admin_financeOverview;

  /// No description provided for @delivery_activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get delivery_activeOrders;

  /// No description provided for @delivery_orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get delivery_orderHistory;

  /// No description provided for @delivery_navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get delivery_navigate;

  /// No description provided for @delivery_available.
  ///
  /// In en, this message translates to:
  /// **'Available Orders'**
  String get delivery_available;

  /// No description provided for @delivery_myDeliveries.
  ///
  /// In en, this message translates to:
  /// **'My Deliveries'**
  String get delivery_myDeliveries;

  /// No description provided for @delivery_noActive.
  ///
  /// In en, this message translates to:
  /// **'No active deliveries'**
  String get delivery_noActive;

  /// No description provided for @delivery_noHistory.
  ///
  /// In en, this message translates to:
  /// **'No delivery history yet'**
  String get delivery_noHistory;

  /// No description provided for @common_markAs.
  ///
  /// In en, this message translates to:
  /// **'Mark as'**
  String get common_markAs;

  /// No description provided for @common_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get common_accept;

  /// No description provided for @common_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get common_active;

  /// No description provided for @common_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get common_inactive;

  /// No description provided for @common_name.
  ///
  /// In en, this message translates to:
  /// **'Name (Arabic)'**
  String get common_name;

  /// No description provided for @common_nameEn.
  ///
  /// In en, this message translates to:
  /// **'Name (English)'**
  String get common_nameEn;

  /// No description provided for @common_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get common_description;

  /// No description provided for @common_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get common_price;

  /// No description provided for @common_discount.
  ///
  /// In en, this message translates to:
  /// **'Discount %'**
  String get common_discount;

  /// No description provided for @common_stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get common_stock;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
