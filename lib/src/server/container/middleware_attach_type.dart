/// Used to know where to attach a middleware
enum MiddlewareAttachType {
  /// Called after the Uri has been extracted
  whenUriHasBeenExtracted,

  /// Called after the Method has been extracted
  whenMethodHasBeenExtracted,

  /// Called before the response is being sent
  afterEndpointExecution
}
