// ══════════════════════════════════════════════════════
// FLUTTER API — doPost handler
// ══════════════════════════════════════════════════════
function doPost(e) {
  try {
    var body = JSON.parse(e.postData.contents);
    var action = body.action;
    var params = body.params || {};
    var result;

    switch(action) {
      case 'login':
        result = loginUser(params.username, params.password);
        break;
      case 'getDashboardStats':
        result = getDashboardStats();
        break;
      case 'getStudents':
        result = searchStudentsAdvanced(params);
        break;
      case 'getDailyRoll':
        result = getDailyRoll(params.date, params.grade, params.teacherGrade);
        break;
      case 'saveDailyRoll':
        result = saveDailyRoll(params.date, params.entries, params.teacherGrade);
        break;
      case 'getTeacherDailyRoll':
        result = getTeacherDailyRoll(params.date);
        break;
      case 'saveTeacherDailyRoll':
        result = saveTeacherDailyRoll(params.date, params.entries);
        break;
      case 'getSettings':
        result = getSettings();
        break;
      case 'getTodayAttendanceSummary':
        result = getTodayAttendanceSummary();
        break;
      case 'getTeacherWorkload':
        result = getTeacherWorkload();
        break;
      case 'getAllTeachers':
        result = getAllTeachers();
        break;
      case 'getDuties':
        result = getDuties(params.teacherId);
        break;
      case 'getCommittees':
        result = getCommittees();
        break;
      case 'getTimetable':
        result = getTimetable(params.grade);
        break;
      case 'getStudentScores':
        result = getStudentScores(params.studentId, params.grade);
        break;
      default:
        result = {ok: false, error: 'Unknown action: ' + action};
    }

    return ContentService
      .createTextOutput(JSON.stringify(result))
      .setMimeType(ContentService.MimeType.JSON);

  } catch(err) {
    return ContentService
      .createTextOutput(JSON.stringify({ok: false, error: err.message}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
