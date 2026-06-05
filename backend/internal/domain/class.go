package domain

// Class is a syllabus master record (seeded separately).
type Class struct {
	ID          string `json:"id"`
	ClassCode   string `json:"class_code"`
	Name        string `json:"name"`
	TeacherName string `json:"teacher_name"`
	DayOfWeek   int    `json:"day_of_week"`
	Period      int    `json:"period"`
	Room        string `json:"room"`
	Semester    string `json:"semester"`
	IsCanceled  bool   `json:"is_canceled"`
}

// UserTimetable maps a user to a registered class with attendance counts and a memo.
type UserTimetable struct {
	ID           string `json:"id"`
	UserID       string `json:"user_id"`
	ClassID      string `json:"class_id"`
	Memo         string `json:"memo"`
	CountPresent int    `json:"count_present"`
	CountAbsent  int    `json:"count_absent"`
	CountLate    int    `json:"count_late"`
	CreatedAt    string `json:"created_at"`
}

// TimetableEntry is the joined view returned by timetable listings:
// the user_timetables row enriched with its class details.
type TimetableEntry struct {
	ID           string `json:"id"`
	ClassID      string `json:"class_id"`
	ClassCode    string `json:"class_code"`
	Name         string `json:"name"`
	TeacherName  string `json:"teacher_name"`
	DayOfWeek    int    `json:"day_of_week"`
	Period       int    `json:"period"`
	Room         string `json:"room"`
	Semester     string `json:"semester"`
	IsCanceled   bool   `json:"is_canceled"`
	Memo         string `json:"memo"`
	CountPresent int    `json:"count_present"`
	CountAbsent  int    `json:"count_absent"`
	CountLate    int    `json:"count_late"`
	CreatedAt    string `json:"created_at"`
}
