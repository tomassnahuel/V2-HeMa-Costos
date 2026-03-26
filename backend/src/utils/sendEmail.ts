// src/utils/sendEmail.ts
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function sendEmail(email: string, code: string): Promise<void> {
  try {
    await resend.emails.send({
      from: 'HeMa Costos <onboarding@hema.com>',
      to: email,
      subject: 'Tu código de acceso',
      html: `
        <div style="font-family:sans-serif">
          <h2>Tu código es:</h2>
          <h1>${code}</h1>
          <p>Expira en ${process.env.CODE_TTL_MINUTES ?? 5} minutos.</p>
        </div>
      `,
    });
    console.log("Email enviado a", email);
  } catch (err) {
    console.error("Error enviando email:", err);
  }
}