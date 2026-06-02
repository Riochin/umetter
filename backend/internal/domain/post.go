package domain

type Post struct {
	ID            string `json:"id"`
	AuthorID      string `json:"author_id"`
	PostType      int    `json:"post_type"`
	Category      string `json:"category"`
	Body          string `json:"body"`
	AttachmentURL string `json:"attachment_url"`
	IsPinned      bool   `json:"is_pinned"`
	CreatedAt     string `json:"created_at"`
}

type PublicPost struct {
	ID            string `json:"id"`
	PostType      int    `json:"post_type"`
	Category      string `json:"category"`
	Body          string `json:"body"`
	AttachmentURL string `json:"attachment_url"`
	IsPinned      bool   `json:"is_pinned"`
	CreatedAt     string `json:"created_at"`
}

type Report struct {
	ID         string `json:"id"`
	PostID     string `json:"post_id"`
	ReporterID string `json:"reporter_id"`
	Reason     string `json:"reason"`
	CreatedAt  string `json:"created_at"`
}
