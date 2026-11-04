"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Mail, MessageSquare, MapPin } from "lucide-react";
import { GithubIcon, LinkedinIcon } from "@/components/ui/Icons";
import { CopyButton } from "@/components/ui/CopyButton";
import { contactData } from "@/data/navigation";
import { useLanguage } from "@/components/providers/LanguageProvider";

export function Footer() {
  const [currentYear, setCurrentYear] = useState<number | string>(2026);
  const { t } = useLanguage();

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
              {contactData.title}. {t.footer.bio}
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
                className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-white text-slate-600 hover:text-red-500 hover:border-red-200 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-400 dark:hover:text-red-400 transition-colors"
              >
                <Mail size={17} />
              </a>
            </div>
          </div>

          {/* Kolom 2: Navigasi Cepat */}
          <div className="space-y-3">
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-slate-200">
              {t.footer.navTitle}
            </h3>
            <ul className="space-y-2 text-sm text-slate-600 dark:text-slate-400">
              <li>
                <Link href="/" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  {t.nav.home}
                </Link>
              </li>
              <li>
                <Link href="/#about" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  {t.nav.about}
                </Link>
              </li>
              <li>
                <Link href="/#skills" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  {t.nav.skills}
                </Link>
              </li>
              <li>
                <Link href="/projects" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  {t.nav.projects}
                </Link>
              </li>
              <li>
                <Link href="/#experience" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  {t.nav.experience}
                </Link>
              </li>
              <li>
                <Link href="/contact" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  {t.nav.contact}
                </Link>
              </li>
            </ul>
          </div>

          {/* Kolom 3: Kontak & Lokasi */}
          <div className="space-y-3">
            <h3 className="text-xs font-bold uppercase tracking-wider text-slate-900 dark:text-slate-200">
              {t.footer.contactTitle}
            </h3>
            <div className="space-y-2.5 text-xs text-slate-600 dark:text-slate-400">
              <div className="flex items-center gap-2">
                <MapPin size={15} className="text-blue-600 dark:text-blue-400 shrink-0" />
                <span>{contactData.location}</span>
              </div>
              <div className="flex items-center gap-2">
                <Mail size={15} className="text-blue-600 dark:text-blue-400 shrink-0" />
                <span className="truncate">{contactData.email}</span>
              </div>
              <div className="flex items-center gap-2">
                <MessageSquare size={15} className="text-emerald-500 shrink-0" />
                <span>{contactData.whatsapp}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Baris Bawah: Hak Cipta */}
        <div className="pt-8 border-t border-slate-200 dark:border-slate-800 flex items-center justify-center text-xs text-slate-500 dark:text-slate-400 text-center">
          <p>© {currentYear} {contactData.name}. {t.footer.copyright}</p>
        </div>
      </div>
    </footer>
  );
}
