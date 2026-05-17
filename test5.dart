import 'package:pocketbase/pocketbase.dart'; void main() { final pb = PocketBase('a'); final r = pb.authStore.record; if (r != null) { print(r.getStringValue('email')); } }
