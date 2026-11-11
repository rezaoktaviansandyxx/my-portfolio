"use client";

import { useState, useEffect } from "react";
import { Send, Loader2, CheckCircle2, AlertCircle, Info } from "lucide-react";
import { useLanguage } from "@/components/providers/LanguageProvider";
import { trackEvent } from "@/lib/analytics";

interface FormState {
  name: string;
  email: string;
  subject: string;
  message: string;
}

export function ContactForm() {
  const { t, language } = useLanguage();

  const [formData, setFormData] = useState<FormState>({
    name: "",
    email: "",
    subject: t.contact.formDefaultSubject,
    message: "",
  });

  // Update default subject when language changes if user hasn't typed a custom subject
  useEffect(() => {
    setFormData((prev) => {
      const prevDefaultSubject = language === "en" ? "Diskusi Penawaran Kerja / Proyek" : "Job Inquiry / Project Discussion";
      if (!prev.subject || prev.subject === prevDefaultSubject) {
        return { ...prev, subject: t.contact.formDefaultSubject };
      }
      return prev;
    });
  }, [language, t.contact.formDefaultSubject]);

  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [feedbackMessage, setFeedbackMessage] = useState<string>("");

  const accessKey = process.env.NEXT_PUBLIC_WEB3FORMS_ACCESS_KEY?.trim() || "";

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    if (!accessKey) {
      setStatus("error");
      setFeedbackMessage(
        language === "en"
          ? "Web3Forms Access Key is not configured. Please set NEXT_PUBLIC_WEB3FORMS_ACCESS_KEY in .env.local."
          : "Kunci Web3Forms belum dikonfigurasi. Harap atur NEXT_PUBLIC_WEB3FORMS_ACCESS_KEY di file .env.local."
      );
      return;
    }

    if (!formData.name.trim() || !formData.email.trim() || !formData.message.trim()) {
      setStatus("error");
      setFeedbackMessage(t.contact.formRequiredFields);
      return;
    }

    setStatus("loading");
    setFeedbackMessage("");

    try {
      const response = await fetch("https://api.web3forms.com/submit", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify({
          access_key: accessKey,
          name: formData.name,
          email: formData.email,
          subject: formData.subject || (language === "en" ? "New Portfolio Inquiry" : "Pesan Baru dari Web Portofolio"),
          message: formData.message,
          from_name: "Portfolio Contact Form",
        }),
      });

      const data = await response.json();

      if (data.success) {
        trackEvent("contact_form_submit", { form_name: "portfolio_contact" });
        setStatus("success");
        setFeedbackMessage(t.contact.formSuccess);
        setFormData({
          name: "",
          email: "",
          subject: t.contact.formDefaultSubject,
          message: "",
        });
      } else {
        setStatus("error");
        setFeedbackMessage(
          data.message || (language === "en" ? "Failed to send message. Please try again." : "Terjadi kendala saat mengirim pesan. Silakan coba kembali.")
        );
      }
    } catch (error) {
      console.error("Web3Forms error:", error);
      setStatus("error");
      setFeedbackMessage(
        language === "en"
          ? "Unable to reach the email service. Please check your connection or reach out via Email/WhatsApp directly."
          : "Gagal terhubung ke layanan pengiriman. Pastikan koneksi internet stabil atau hubungi via Email/WhatsApp."
      );
    }
  };

  return (
    <div className="rounded-2xl border border-slate-200 bg-white p-6 sm:p-8 shadow-xs dark:border-slate-800 dark:bg-slate-900">
      <div className="flex items-center justify-between gap-2">
        <h3 className="text-base font-bold text-slate-900 dark:text-white">
          {t.contact.formTitle}
        </h3>
        <span className="inline-flex items-center rounded-full bg-blue-50 px-2.5 py-0.5 text-[11px] font-semibold text-blue-700 dark:bg-blue-950/70 dark:text-blue-300">
          {t.contact.formBadge}
        </span>
      </div>
      <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
        {t.contact.formSubtitle}
      </p>

      {!accessKey && (
        <div className="mt-4 flex items-start gap-2.5 rounded-lg border border-amber-200 bg-amber-50 p-3 text-xs text-amber-800 dark:border-amber-900/50 dark:bg-amber-950/30 dark:text-amber-300">
          <Info size={16} className="mt-0.5 shrink-0 text-amber-600 dark:text-amber-400" />
          <div>
            <span className="font-semibold">
              {language === "en" ? "Configuration Required:" : "Konfigurasi Dibutuhkan:"}
            </span>{" "}
            {language === "en"
              ? "Set your Web3Forms Access Key in .env.local (NEXT_PUBLIC_WEB3FORMS_ACCESS_KEY) to activate direct email delivery."
              : "Masukkan Access Key Web3Forms Anda pada file .env.local (variabel: NEXT_PUBLIC_WEB3FORMS_ACCESS_KEY) agar form dapat mengirim email secara otomatis."}
          </div>
        </div>
      )}

      {status === "success" && (
        <div className="mt-4 flex items-center gap-2.5 rounded-lg border border-emerald-200 bg-emerald-50 p-3.5 text-xs font-medium text-emerald-800 dark:border-emerald-900/60 dark:bg-emerald-950/40 dark:text-emerald-300 animate-in fade-in">
          <CheckCircle2 size={18} className="shrink-0 text-emerald-600 dark:text-emerald-400" />
          <span>{feedbackMessage}</span>
        </div>
      )}

      {status === "error" && (
        <div className="mt-4 flex items-start gap-2.5 rounded-lg border border-red-200 bg-red-50 p-3 text-xs font-medium text-red-800 dark:border-red-900/60 dark:bg-red-950/40 dark:text-red-300 animate-in fade-in">
          <AlertCircle size={16} className="mt-0.5 shrink-0 text-red-600 dark:text-red-400" />
          <span>{feedbackMessage}</span>
        </div>
      )}

      <form onSubmit={handleSubmit} className="mt-6 space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label htmlFor="contact-name" className="block text-xs font-medium text-slate-700 dark:text-slate-300">
              {t.contact.formName} <span className="text-red-500">*</span>
            </label>
            <input
              id="contact-name"
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              placeholder={t.contact.formNamePlaceholder}
              required
              disabled={status === "loading"}
              className="mt-1.5 block w-full rounded-lg border border-slate-200 bg-slate-50 px-3.5 py-2.5 text-xs sm:text-sm text-slate-900 focus:border-blue-500 focus:bg-white focus:outline-none dark:border-slate-800 dark:bg-slate-800/50 dark:text-white dark:focus:border-blue-400 transition"
            />
          </div>

          <div>
            <label htmlFor="contact-email" className="block text-xs font-medium text-slate-700 dark:text-slate-300">
              {t.contact.formEmail} <span className="text-red-500">*</span>
            </label>
            <input
              id="contact-email"
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder={t.contact.formEmailPlaceholder}
              required
              disabled={status === "loading"}
              className="mt-1.5 block w-full rounded-lg border border-slate-200 bg-slate-50 px-3.5 py-2.5 text-xs sm:text-sm text-slate-900 focus:border-blue-500 focus:bg-white focus:outline-none dark:border-slate-800 dark:bg-slate-800/50 dark:text-white dark:focus:border-blue-400 transition"
            />
          </div>
        </div>

        <div>
          <label htmlFor="contact-subject" className="block text-xs font-medium text-slate-700 dark:text-slate-300">
            {t.contact.formSubject}
          </label>
          <input
            id="contact-subject"
            type="text"
            name="subject"
            value={formData.subject}
            onChange={handleChange}
            required
            disabled={status === "loading"}
            className="mt-1.5 block w-full rounded-lg border border-slate-200 bg-slate-50 px-3.5 py-2.5 text-xs sm:text-sm text-slate-900 focus:border-blue-500 focus:bg-white focus:outline-none dark:border-slate-800 dark:bg-slate-800/50 dark:text-white dark:focus:border-blue-400 transition"
          />
        </div>

        <div>
          <label htmlFor="contact-message" className="block text-xs font-medium text-slate-700 dark:text-slate-300">
            {t.contact.formMessage} <span className="text-red-500">*</span>
          </label>
          <textarea
            id="contact-message"
            name="message"
            rows={4}
            value={formData.message}
            onChange={handleChange}
            placeholder={t.contact.formMessagePlaceholder}
            required
            disabled={status === "loading"}
            className="mt-1.5 block w-full rounded-lg border border-slate-200 bg-slate-50 px-3.5 py-2.5 text-xs sm:text-sm text-slate-900 focus:border-blue-500 focus:bg-white focus:outline-none dark:border-slate-800 dark:bg-slate-800/50 dark:text-white dark:focus:border-blue-400 transition resize-y"
          />
        </div>

        <button
          type="submit"
          disabled={status === "loading"}
          className="inline-flex w-full items-center justify-center gap-2 rounded-lg bg-blue-600 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 active:scale-[0.99] disabled:opacity-70 disabled:cursor-not-allowed"
        >
          {status === "loading" ? (
            <>
              <Loader2 size={16} className="animate-spin" />
              <span>{t.contact.formSending}</span>
            </>
          ) : (
            <>
              <Send size={16} />
              <span>{t.contact.formSend}</span>
            </>
          )}
        </button>
      </form>
    </div>
  );
}
