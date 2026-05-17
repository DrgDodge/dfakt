import 'package:pocketbase/pocketbase.dart' as pb_sdk; void main() { final pb = pb_sdk.PocketBase('a'); print(pb.authStore.record.runtimeType); }
