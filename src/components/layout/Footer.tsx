"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Mail, MessageSquare, MapPin } from "lucide-react";
import { GithubIcon, LinkedinIcon } from "@/components/ui/Icons";
import { contactData, navigationItems } from "@/data/navigation";

export function Footer() {
  const [currentYear, setCurrentYear] = useState<number | string>(2026);

  useEffect(() => {
    setCurrentYear(new Date().getFullYear());
  }, []);

  return (
    <footer className="w-full border-t border-slate-200/80 bg-slate-50/80 pt-16 pb-8 transition-colors dark:border-slate-800/80 dark:bg-slate-950">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-10 pb-12">
          {/* Kolom 1: Profil Singkat & Sosmed */}
          <div className="md:col-span-2 space-y-4">
            <Link href="/" className="inline-flex items-center gap-2 group">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600 text-white font-bold text-xs shadow-sm">
                IO
              </div>
              <span className="text-lg font-bold tracking-tight text-slate-900 dark:text-slate-100">
                {contactData.name}
                <span className="text-blue-600 dark:text-blue-400">.</span>
              </span>
            </Link>
            <p className="text-sm text-slate-600 dark:text-slate-400 max-w-sm leading-relaxed">
              {contactData.title}. Fokus membangun aplikasi mobile & web yang modern, cepat, dan terintegrasi dengan baik.
            </p>
            <div className="flex items-center gap-3 pt-2">
              <a
                href={contactData.github}
                target="_blank"
                rel="noopener noreferrer"
                aria-label="GitHub"
                className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 hover:text-slate-950 hover:border-slate-300 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-400 dark:hover:text-white transition-colors"
              >
                <GithubIcon size={17} />
              </a>
              <a
                href={contactData.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                aria-label="LinkedIn"
                className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 hover:text-blue-600 hover:border-blue-200 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-400 dark:hover:text-blue-400 transition-colors"
              >
                <LinkedinIcon size={17} />
              </a>
              <a
                href={`mailto:${contactData.email}`}
                aria-label="Email"
                className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 hover:text-red-600 hover:border-red-200 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-400 dark:hover:text-red-400 transition-colors"
              >
                <Mail size={17} />
              </a>
              <a
                href={contactData.whatsappUrl}
                target="_blank"
                rel="noopener noreferrer"
                aria-label="WhatsApp"
                className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 hover:text-emerald-600 hover:border-emerald-200 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-400 dark:hover:text-emerald-400 transition-colors"
              >
                <MessageSquare size={17} />
              </a>
            </div>
          </div>

          {/* Kolom 2: Navigasi Halaman (Vertikal) */}
          <div>
            <h3 className="text-xs font-semibold uppercase tracking-wider text-slate-900 dark:text-slate-100">
              Navigasi
            </h3>
            <ul className="mt-4 space-y-2.5">
              {navigationItems.map((item) => (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    className="text-sm text-slate-600 hover:text-blue-600 dark:text-slate-400 dark:hover:text-blue-400 transition-colors"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Kolom 3: Kontak Cepat */}
          <div>
            <h3 className="text-xs font-semibold uppercase tracking-wider text-slate-900 dark:text-slate-100">
              Kontak
            </h3>
            <div className="mt-4 space-y-3 text-sm text-slate-600 dark:text-slate-400">
              <div className="flex items-start gap-2.5">
                <MapPin size={16} className="mt-0.5 text-blue-600 dark:text-blue-400 shrink-0" />
                <span>{contactData.location}</span>
              </div>
              <div className="flex items-start gap-2.5">
                <Mail size={16} className="mt-0.5 text-blue-600 dark:text-blue-400 shrink-0" />
                <a href={`mailto:${contactData.email}`} className="hover:underline break-all">
                  {contactData.email}
                </a>
              </div>
              <div className="pt-2">
                <Link
                  href="/contact"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300"
                >
                  Kirim Pesan &rarr;
                </Link>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Bar / Hak Cipta */}
        <div className="border-t border-slate-200/80 pt-6 dark:border-slate-800/80 text-center text-xs text-slate-500 dark:text-slate-400">
          <p>© {currentYear} {contactData.name}. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
