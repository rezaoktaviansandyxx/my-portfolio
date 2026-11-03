"use client";

import { Mail, MessageSquare } from "lucide-react";
import { GithubIcon, LinkedinIcon } from "@/components/ui/Icons";
import { CopyButton } from "@/components/ui/CopyButton";
import { ContactForm } from "@/components/sections/ContactForm";
import { contactData } from "@/data/navigation";
import { useLanguage } from "@/components/providers/LanguageProvider";

export function ContactSection() {
  const { t } = useLanguage();

  return (
    <section id="contact" className="py-20 border-t border-slate-200/80 dark:border-slate-800/80">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="max-w-2xl">
          <h2 className="text-xs font-bold uppercase tracking-wider text-blue-600 dark:text-blue-400">
            {t.contact.tag}
          </h2>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 sm:text-3xl dark:text-white">
            {t.contact.title}
          </p>
          <p className="mt-3 text-sm text-slate-600 dark:text-slate-400">
            {t.contact.desc}
          </p>
        </div>

        <div className="mt-10 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
          {/* Direct channels cards */}
          <div className="lg:col-span-6 space-y-4">
            {/* Email Card with Copy Button */}
            <div className="flex items-center justify-between rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-blue-500 hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
              <a
                href={`mailto:${contactData.email}`}
                className="group flex items-center gap-4 min-w-0 flex-1 mr-2"
              >
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                  <Mail size={22} />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-xs font-medium text-slate-500 dark:text-slate-400">{t.contact.directEmail}</p>
                  <p className="truncate text-base font-semibold text-slate-900 group-hover:text-blue-600 dark:text-white dark:group-hover:text-blue-400">
                    {contactData.email}
                  </p>
                </div>
              </a>

              <CopyButton
                textToCopy={contactData.email}
                ariaLabel={t.contact.directEmail}
                tooltipText={t.contact.copySuccess}
                className="h-9 w-9 rounded-lg border border-slate-200 bg-slate-50 text-slate-600 hover:bg-blue-50 hover:text-blue-600 hover:border-blue-200 dark:border-slate-800 dark:bg-slate-800 dark:text-slate-300 dark:hover:bg-slate-700 dark:hover:text-blue-400 shrink-0"
              />
            </div>

            {/* WhatsApp Card */}
            <a
              href={contactData.whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="group flex items-center justify-between rounded-xl border border-slate-200 bg-white p-5 shadow-xs transition hover:border-emerald-500 hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
            >
              <div className="flex items-center gap-4">
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-emerald-50 text-emerald-600 dark:bg-emerald-950 dark:text-emerald-400">
                  <MessageSquare size={22} />
                </div>
                <div>
                  <p className="text-xs font-medium text-slate-500 dark:text-slate-400">{t.contact.whatsappChat}</p>
                  <p className="text-base font-semibold text-slate-900 group-hover:text-emerald-600 dark:text-white dark:group-hover:text-emerald-400">
                    {contactData.whatsapp}
                  </p>
                </div>
              </div>
              <span className="rounded-full bg-emerald-50 px-2.5 py-1 text-xs font-medium text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300">
                {t.contact.fastResponse}
              </span>
            </a>

            {/* LinkedIn & GitHub Cards */}
            <div className="grid grid-cols-2 gap-4 pt-2">
              <a
                href={contactData.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-4 shadow-xs transition hover:border-blue-500 hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-blue-50 text-blue-600 dark:bg-blue-950 dark:text-blue-400">
                  <LinkedinIcon size={18} />
                </div>
                <div>
                  <p className="text-xs text-slate-500 dark:text-slate-400">Connect</p>
                  <p className="text-sm font-semibold text-slate-900 dark:text-white">LinkedIn</p>
                </div>
              </a>

              <a
                href={contactData.github}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-3 rounded-xl border border-slate-200 bg-white p-4 shadow-xs transition hover:border-slate-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-200">
                  <GithubIcon size={18} />
                </div>
                <div>
                  <p className="text-xs text-slate-500 dark:text-slate-400">Explore</p>
                  <p className="text-sm font-semibold text-slate-900 dark:text-white">GitHub</p>
                </div>
              </a>
            </div>
          </div>

          {/* Contact Message Form */}
          <div className="lg:col-span-6">
            <ContactForm />
          </div>
        </div>
      </div>
    </section>
  );
}
