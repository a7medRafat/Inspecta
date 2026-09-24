import 'package:flutter_test/flutter_test.dart';

import 'package:inspecta/core/builder/flow_state.dart';

void main() {
  test('FlowState.copyWith keeps unchanged fields', () {
    const state = FlowState(message: 'hi', type: StateType.loading);
    final next = state.copyWith(type: StateType.success);

    expect(next.message, 'hi');
    expect(next.type, StateType.success);
  });
}
