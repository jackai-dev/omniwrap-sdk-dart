class AgentLimits {
  final int maxSteps;
  final int maxToolCalls;
  final bool allowMutations;
  const AgentLimits({this.maxSteps = 8, this.maxToolCalls = 16, this.allowMutations = false});
}

class AgentSession {
  static const String sourceSha256 = '2289bcb0d661bdea6dd47c7967f37aace7d3a152e18e7d2f64c08514fb73e795';
  static const int registeredOperationsCount = 16;
  final AgentLimits limits;
  final Set<String> allowedOperations;
  int _stepsCompleted = 0;
  int _toolCallsCompleted = 0;
  AgentSession({this.limits = const AgentLimits(), Set<String>? allowedOperations})
      : allowedOperations = allowedOperations ?? <String>{};
  bool canInvoke(String operationId, {required bool isMutation}) {
    if (_stepsCompleted >= limits.maxSteps || _toolCallsCompleted >= limits.maxToolCalls) return false;
    if (isMutation && !limits.allowMutations) return false;
    return allowedOperations.isEmpty || allowedOperations.contains(operationId);
  }
  void recordStep({int toolCalls = 1}) {
    _stepsCompleted += 1;
    _toolCallsCompleted += toolCalls < 0 ? 0 : toolCalls;
  }
  Map<String, Object> checkpoint() => {
    'protocol_version': 'omniwrap.agent-session/v1',
    'source_sha256': sourceSha256,
    'steps_completed': _stepsCompleted,
    'tool_calls_completed': _toolCallsCompleted,
  };
}
