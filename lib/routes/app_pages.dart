import 'package:get/get.dart';
import 'app_routes.dart';
import 'role_middleware.dart';
import '../core/constants/app_strings.dart';

// Splash Module
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';

// Auth Module
import '../modules/auth/login_view.dart';
import '../modules/auth/auth_binding.dart';

// Dashboard Module
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/dashboard_binding.dart';

// POS Module
import '../modules/pos/pos_view.dart';
import '../modules/pos/pos_binding.dart';

// Kitchen Module
import '../modules/kitchen/kitchen_view.dart';
import '../modules/kitchen/kitchen_binding.dart';

// Inventory Module
import '../modules/inventory/inventory_view.dart';
import '../modules/inventory/inventory_binding.dart';

// Table Management Module
import '../modules/tables/tables_view.dart';
import '../modules/tables/tables_binding.dart';

// Reports Module
import '../modules/reports/reports_view.dart';
import '../modules/reports/reports_binding.dart';

// Settings Module
import '../modules/settings/settings_view.dart';
import '../modules/settings/settings_binding.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      middlewares: [
        LoginMiddleware(),
      ],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [
        RoleMiddleware(allowedRoles: [
          AppStrings.roleSuperAdmin,
          AppStrings.roleOwner,
          AppStrings.roleManager,
          AppStrings.roleCashier,
          AppStrings.roleKitchen,
          AppStrings.roleWaiter,
        ]),
      ],
    ),
    GetPage(
      name: AppRoutes.pos,
      page: () => const PosView(),
      binding: PosBinding(),
      middlewares: [
        RoleMiddleware(allowedRoles: [
          AppStrings.roleSuperAdmin,
          AppStrings.roleOwner,
          AppStrings.roleManager,
          AppStrings.roleCashier,
        ]),
      ],
    ),
    GetPage(
      name: AppRoutes.kitchen,
      page: () => const KitchenView(),
      binding: KitchenBinding(),
      middlewares: [
        RoleMiddleware(allowedRoles: [
          AppStrings.roleSuperAdmin,
          AppStrings.roleOwner,
          AppStrings.roleManager,
          AppStrings.roleKitchen,
        ]),
      ],
    ),
    GetPage(
      name: AppRoutes.inventory,
      page: () => const InventoryView(),
      binding: InventoryBinding(),
      middlewares: [
        RoleMiddleware(allowedRoles: [
          AppStrings.roleSuperAdmin,
          AppStrings.roleOwner,
          AppStrings.roleManager,
        ]),
      ],
    ),
    GetPage(
      name: AppRoutes.tables,
      page: () => const TablesView(),
      binding: TablesBinding(),
      middlewares: [
        RoleMiddleware(allowedRoles: [
          AppStrings.roleSuperAdmin,
          AppStrings.roleOwner,
          AppStrings.roleManager,
          AppStrings.roleCashier,
          AppStrings.roleWaiter,
        ]),
      ],
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      middlewares: [
        RoleMiddleware(allowedRoles: [
          AppStrings.roleSuperAdmin,
          AppStrings.roleOwner,
        ]),
      ],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [
        RoleMiddleware(allowedRoles: [
          AppStrings.roleSuperAdmin,
          AppStrings.roleOwner,
        ]),
      ],
    ),
  ];
}
