final class SyncConflictResolver {
  const SyncConflictResolver();

  bool preferRemote({required DateTime remoteUpdatedAt, required DateTime localUpdatedAt}) {
    if (remoteUpdatedAt.isAtSameMomentAs(localUpdatedAt)) {
      return true;
    }
    return remoteUpdatedAt.isAfter(localUpdatedAt);
  }
}
