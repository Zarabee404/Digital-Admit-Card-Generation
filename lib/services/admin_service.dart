import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admit_card_request_model.dart';

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<AdmitCardRequestModel>> requestsStream() {
    return _client
        .from('admit_card_requests')
        .stream(primaryKey: ['id'])
        .order('submitted_on', ascending: false)
        .map(
          (rows) => rows
              .map((request) => AdmitCardRequestModel.fromJson(request))
              .toList(),
        );
  }

  int countTotalApplications(List<AdmitCardRequestModel> requests) {
    return requests.length;
  }

  int countApprovedApplications(List<AdmitCardRequestModel> requests) {
    return requests.where((request) => request.status == 'approved').length;
  }
}