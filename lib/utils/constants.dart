class AppConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String tractorsCollection = 'resources/tractors/items';
  static const String tubewellsCollection = 'resources/tubewells/items';
  static const String connectionsCollection = 'connections';
  static const String jobsTractorCollection = 'jobs_tractor';
  static const String jobsTubewellCollection = 'jobs_tubewell';
  static const String ratesDocument = 'rates/current';
  static const String expensesCollection = 'expenses';
  static const String paymentsCollection = 'payments';
  static const String settingsAuthDocument = 'settings/auth';

  // Roles
  static const String roleFarmer = 'farmer';
  static const String roleTractorOwner = 'tractor_owner';
  static const String roleTubewellOwner = 'tubewell_owner';
  static const String roleAdmin = 'admin';

  // Pricing modes
  static const String pricingFlat = 'flat';
  static const String pricingPerBigha = 'per_bigha';

  // Billing modes
  static const String billingHourly = 'hourly';
  static const String billingPerBigha = 'per_bigha';

  // Job status
  static const String statusPending = 'pending';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Payment status
  static const String paymentPending = 'pending';
  static const String paymentPaid = 'paid';
  static const String paymentPartial = 'partial';

  // Payment modes
  static const String paymentCash = 'cash';
  static const String paymentUpi = 'upi';

  // Expense types
  static const String expenseDiesel = 'diesel';
  static const String expenseElectricity = 'electricity';
  static const String expenseMaintenance = 'maintenance';
  static const String expenseOther = 'other';
}
