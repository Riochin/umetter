package domain

// Friendship statuses.
const (
	FriendshipPending  = "pending"
	FriendshipApproved = "approved"
	FriendshipRejected = "rejected"
)

// Friendship is a mutual-approval friend relationship between two users.
type Friendship struct {
	ID          string `json:"id"`
	RequesterID string `json:"requester_id"`
	AddresseeID string `json:"addressee_id"`
	Status      string `json:"status"`
	CreatedAt   string `json:"created_at"`
	UpdatedAt   string `json:"updated_at"`
}
