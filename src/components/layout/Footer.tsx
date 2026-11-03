import Link from "next/link";
import { Mail, MessageSquare } from "lucide-react";
import { GithubIcon, LinkedinIcon } from "@/components/ui/Icons";
import { contactData, navigationItems } from "@/data/navigation";

export function Footer() {
  const currentYear = 2026;

  return (
    <footer className="w-full border-t border-slate-200/80 bg-slate-50/50 py-12 transition-colors dark:border-slate-800/80 dark:bg-slate-950/50">
      <div className="mx-auto max-w-6xl px-4 sm:px-6 lg:px-8">
        <div className="flex flex-col md:flex-row items-center justify-between gap-6">
          {/* Identity */}
          <div className="flex flex-col items-center md:items-start">
            <Link
              href="/"
              className="text-lg font-bold tracking-tight text-slate-900 transition-colors hover:text-blue-600 dark:text-slate-100 dark:hover:text-blue-400"
            >
              {contactData.name}
              <span className="text-blue-600 dark:text-blue-400 font-extrabold">.</span>
            </Link>
            <p className="mt-1 text-xs text-slate-500 dark:text-slate-400">
              {contactData.title}
            </p>
          </div>

          {/* Nav Links */}
          <nav className="flex flex-wrap items-center justify-center gap-6">
            {navigationItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="text-xs font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-400 dark:hover:text-blue-400"
              >
                {item.label}
              </Link>
            ))}
          </nav>

          {/* Social Icons */}
          <div className="flex items-center gap-4">
            <a
              href={contactData.github}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="GitHub profile"
              className="text-slate-500 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
            >
              <GithubIcon size={18} />
            </a>
            <a
              href={contactData.linkedin}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="LinkedIn profile"
              className="text-slate-500 transition-colors hover:text-blue-600 dark:text-slate-400 dark:hover:text-blue-400"
            >
              <LinkedinIcon size={18} />
            </a>
            <a
              href={`mailto:${contactData.email}`}
              aria-label="Email address"
              className="text-slate-500 transition-colors hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
            >
              <Mail size={18} />
            </a>
            <a
              href={contactData.whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              aria-label="WhatsApp direct contact"
              className="text-slate-500 transition-colors hover:text-emerald-600 dark:text-slate-400 dark:hover:text-emerald-400"
            >
              <MessageSquare size={18} />
            </a>
          </div>
        </div>

        <div className="mt-8 border-t border-slate-200/60 pt-6 text-center text-xs text-slate-400 dark:border-slate-800/60 dark:text-slate-500">
          <p>© {currentYear} {contactData.name}. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
