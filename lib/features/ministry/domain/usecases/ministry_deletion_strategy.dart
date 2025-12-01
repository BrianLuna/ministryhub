/// Strategy for handling churches when deleting a ministry
enum MinistryDeletionStrategy {
  /// Delete all churches associated with the ministry
  deleteChurches,

  /// Reassign churches to another ministry
  reassignChurches,
}
