import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';

AuthController get authC => Get.find<AuthController>();

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _user = UserModel().obs;
  UserModel get user => _user.value;
  set user(UserModel value) => _user.value = value;

  late Rx<User?> firebaseUser;

  bool get isLoggedIn => firebaseUser.value != null;

  @override
  void onInit() {
    super.onInit();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _syncUser);
    _syncUser(firebaseUser.value);
    once<User?>(firebaseUser, (_) => navigateRoute());
  }

  void _syncUser(User? value) {
    try {
      if (value == null) {
        user = UserModel();
      } else {
        _user.bindStream(UserModel(id: value.uid).stream());
      }
    } catch (_) {
      user = UserModel();
    }
  }

  Future<UserModel?> getActiveUser() async {
    final current = _auth.currentUser;
    if (current == null) return null;
    return UserModel(id: current.uid).getUser();
  }

  Future<void> navigateRoute() async {
    final activeUser = await getActiveUser();
    if (activeUser == null) {
      Get.offAllNamed(Routes.AUTH_LOGIN);
      return;
    }
    user = activeUser;
    if (activeUser.isDriver) {
      Get.offAllNamed(Routes.DRIVER_HOME);
    } else {
      Get.offAllNamed(Routes.USER_HOME);
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final activeUser = await UserModel(id: credential.user?.uid).getUser();
      if (activeUser == null) {
        await _auth.signOut();
        return 'Data user tidak ditemukan';
      }
      user = activeUser;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    user = UserModel();
    Get.offAllNamed(Routes.AUTH_LOGIN);
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
