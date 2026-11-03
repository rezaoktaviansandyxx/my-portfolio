import { Mail, MessageSquare, MapPin, Send } from "lucide-react";
import { GithubIcon, LinkedinIcon } from "@/components/ui/Icons";
import { contactData } from "@/data/navigation";

export function ContactSection() {
  return (
    <section id="contact" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-2xl">
          <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
            Contact Me
          </h2>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
            Mari Berdiskusi & Berkolaborasi
          </p>
          <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
            Terbuka untuk tawaran posisi Full-Time (Flutter Developer / Web Developer) maupun proyek Freelance.
          </p>
        </div>

        <div className="mt-10 grid grid-cols-1 lg:grid-cols-12 gap-8">
          {/* Direct channels cards */}
          <div className="lg:col-span-6 space-y-4">
            {/* Email Card */}
            <a
              href={`mailto:${contactData.email}`}
              className="group flex items-center gap-4 rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-blue-500 hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                <Mail size={22} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-xs font-medium text-slate-500 dark:text-slate-400">Email Langsung</p>
                <p className="truncate text-base font-semibold text-slate-900 group-hover:text-blue-600 dark:text-white dark:group-hover:text-blue-400">
                  {contactData.email}
                </p>
              </div>
            </a>

            {/* WhatsApp Card */}
            <a
              href={contactData.whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="group flex items-center gap-4 rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-emerald-500 hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-emerald-50 text-emerald-600 dark:bg-emerald-950 dark:text-emerald-400">
                <MessageSquare size={22} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-xs font-medium text-slate-500 dark:text-slate-400">WhatsApp Chat</p>
                <p className="text-base font-semibold text-slate-900 group-hover:text-emerald-600 dark:text-white dark:group-hover:text-emerald-400">
                  {contactData.whatsapp}
                </p>
              </div>
            </a>

            {/* Professional Profiles */}
            <div className="grid grid-cols-2 gap-4">
              <a
                href={contactData.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="group flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-4 shadow-xs transition hover:border-blue-500 dark:border-slate-800 dark:bg-slate-900"
              >
                <LinkedinIcon size={20} className="text-slate-600 dark:text-slate-400 group-hover:text-blue-600 dark:group-hover:text-blue-400" />
                <span className="text-xs font-semibold text-slate-800 dark:text-slate-200">
                  LinkedIn Profile
                </span>
              </a>

              <a
                href={contactData.github}
                target="_blank"
                rel="noopener noreferrer"
                className="group flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-4 shadow-xs transition hover:border-slate-500 dark:border-slate-800 dark:bg-slate-900"
              >
                <GithubIcon size={20} className="text-slate-600 dark:text-slate-400 group-hover:text-slate-900 dark:group-hover:text-white" />
                <span className="text-xs font-semibold text-slate-800 dark:text-slate-200">
                  GitHub Profile
                </span>
              </a>
            </div>
          </div>

          {/* Quick Mailto Action Form */}
          <div className="lg:col-span-6 rounded-2xl border border-slate-200 bg-white p-6 sm:p-8 shadow-xs dark:border-slate-800 dark:bg-slate-900">
            <h3 className="text-base font-bold text-slate-900 dark:text-white">
              Kirim Pesan Cepat via Email Client
            </h3>
            <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
              Formulir ini menggunakan protokol resmi mailto agar langsung terhubung ke email Anda tanpa pihak ketiga.
            </p>

            <form
              action={`mailto:${contactData.email}`}
              method="GET"
              encType="text/plain"
              className="mt-6 space-y-4"
            >
              <div>
                <label className="block text-xs font-medium text-slate-700 dark:text-slate-300">
                  Subjek Pesan
                </label>
                <input
                  type="text"
                  name="subject"
                  defaultValue="Diskusi Penawaran Kerja / Proyek"
                  required
                  className="mt-1.5 block w-full rounded-lg border border-slate-200 bg-slate-50 px-3.5 py-2.5 text-xs sm:text-sm text-slate-900 focus:border-blue-500 focus:bg-white focus:outline-none dark:border-slate-800 dark:bg-slate-800/50 dark:text-white dark:focus:border-blue-400"
                />
              </div>

              <div>
                <label className="block text-xs font-medium text-slate-700 dark:text-slate-300">
                  Isi Pesan
                </label>
                <textarea
                  name="body"
                  rows={4}
                  placeholder="Tuliskan pesan atau penawaran kerja sama..."
                  required
                  className="mt-1.5 block w-full rounded-lg border border-slate-200 bg-slate-50 px-3.5 py-2.5 text-xs sm:text-sm text-slate-900 focus:border-blue-500 focus:bg-white focus:outline-none dark:border-slate-800 dark:bg-slate-800/50 dark:text-white dark:focus:border-blue-400"
                />
              </div>

              <button
                type="submit"
                className="inline-flex w-full items-center justify-center gap-2 rounded-lg bg-blue-600 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-blue-700 active:scale-[0.99]"
              >
                <Send size={16} />
                Buka Email untuk Mengirim
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
}
