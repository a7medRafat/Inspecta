import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspecta/core/enums/job_status.dart';
import 'package:inspecta/features/requests/data/models/inspection_request_model.dart';
import 'package:inspecta/features/requests/domain/entities/request_source.dart';

void main() {
  test('parses a requests/{id} document', () {
    final receivedAt = DateTime.utc(2026, 9, 1, 9, 12);
    final model = InspectionRequestModel.fromJson('REQ-2026-0142', {
      'source': 'email',
      'clientId': 'client-1',
      'clientName': 'Delta Steel Co.',
      'subject': 'Annual thorough examination',
      'receivedAt': Timestamp.fromDate(receivedAt),
      'location': '10th of Ramadan',
      'status': 'quote_sent',
      'items': [
        {'id': 'item-1', 'type': 'Overhead crane', 'capacity': '10 t', 'quantity': 2},
        'not a map', // malformed entries are ignored, not crashed on.
      ],
    });

    final entity = model.toEntity()!;
    expect(entity.id, 'REQ-2026-0142');
    expect(entity.source, RequestSource.email);
    expect(entity.status, JobStatus.quoteSent);
    expect(entity.items, hasLength(1));
    expect(entity.items.single.displayTitle, 'Overhead crane — 10 t');
    expect(entity.receivedAt.isAtSameMomentAs(receivedAt), isTrue);
  });

  test('has no entity when the status is unknown', () {
    final model = InspectionRequestModel.fromJson('REQ-1', {
      'clientName': 'X',
      'status': 'something_new',
    });
    expect(model.toEntity(), isNull);
  });

  test('an unrecognised source falls back to email intake', () {
    final model = InspectionRequestModel.fromJson('REQ-1', {
      'clientName': 'X',
      'status': 'request_received',
    });
    expect(model.source, RequestSource.email);
  });
}
