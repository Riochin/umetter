package mailer

import (
	"fmt"
	"net/smtp"
)

type Mailer struct {
	SMTPHost string
	SMTPPort string
	SMTPUser string
	SMTPPass string
	From     string
	Debug    bool
}

func (m *Mailer) SendVerificationCode(to string, code string) error {
	if m.Debug {
		fmt.Printf("[EMAIL_DEBUG] verification code for %s: %s\n", to, code)
		return nil
	}

	if m.SMTPHost == "" || m.SMTPPort == "" || m.SMTPUser == "" || m.SMTPPass == "" || m.From == "" {
		return fmt.Errorf("smtp settings are incomplete")
	}

	addr := m.SMTPHost + ":" + m.SMTPPort
	auth := smtp.PlainAuth("", m.SMTPUser, m.SMTPPass, m.SMTPHost)

	subject := "うめったー メール確認コード"
	body := fmt.Sprintf("うめったーの確認コードは %s です。\r\n\r\nこのコードは10分間有効です。\r\n", code)

	msg := []byte(
		"From: " + m.From + "\r\n" +
			"To: " + to + "\r\n" +
			"Subject: " + subject + "\r\n" +
			"Content-Type: text/plain; charset=UTF-8\r\n" +
			"\r\n" +
			body,
	)

	if err := smtp.SendMail(addr, auth, m.From, []string{to}, msg); err != nil {
		return fmt.Errorf("send verification email: %w", err)
	}

	return nil
}
