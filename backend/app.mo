import Array "mo:base/Array";

actor ExamProctor {
  // Stable variable to store exam session data (persists across upgrades)
  stable var sessions : [(Text, [Text])] = []; // (studentId, [logs])

  // Stable variable to track active students
  stable var activeStudents : [Text] = []; // List of student IDs currently in an exam

  // Start an exam session for a student
  public func startSession(studentId : Text) : async () {
    // Add student to active list if not already present
    let studentExists = Array.find<Text>(activeStudents, func (id) { id == studentId });
    if (studentExists == null) {
      activeStudents := Array.append<Text>(activeStudents, [studentId]);
      sessions := Array.append<(Text, [Text])>(sessions, [(studentId, [])]);
    };
  };

  // Log an event (e.g., tab switch, face detection result)
  public func logEvent(studentId : Text, event : Text) : async () {
    // Find the student's session and append the event
    let updatedSessions = Array.map<(Text, [Text]), (Text, [Text])>(sessions, func (session) {
      if (session.0 == studentId) {
        (session.0, Array.append<Text>(session.1, [event]))
      } else {
        session
      }
    });
    sessions := updatedSessions;
  };

  // Query the logs for a student
  public query func getLogs(studentId : Text) : async [Text] {
    switch (Array.find<(Text, [Text])>(sessions, func (session) { session.0 == studentId })) {
      case (null) { [] };
      case (?session) { session.1 };
    };
  };

  // End the session for a student
  public func endSession(studentId : Text) : async () {
    activeStudents := Array.filter<Text>(activeStudents, func (id) { id != studentId });
  };
};