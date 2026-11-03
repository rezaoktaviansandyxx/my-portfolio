"use client";

import Link from "next/link";
import { useState } from "react";
import { Menu, X, Sun, Moon, ArrowDownToLine, Search } from "lucide-react";
import { useTheme } from "@/components/providers/ThemeProvider";
import { useLanguage } from "@/components/providers/LanguageProvider";
import { useCommandMenu } from "@/components/providers/CommandMenuProvider";
import { contactData } from "@/data/navigation";
import { CopyButton } from "@/components/ui/CopyButton";
import { LanguageToggle } from "@/components/ui/LanguageToggle";

export function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { toggleOpen, isMac } = useCommandMenu();
  const { theme, toggleTheme } = useTheme();
  const { t } = useLanguage();

  return (
    <header className="sticky top-0 z-40 w-full border-b border-slate-200/80 bg-white/80 backdrop-blur-md transition-colors dark:border-slate-800/80 dark:bg-slate-950/80">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8 h-16 gap-3">
        {/* Brand / Logo */}
        <Link
          href="/"
          className="group flex items-center gap-2.5 transition-all focus:outline-none shrink-0"
        >
          {/* Logo Badge */}
          <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-linear-to-tr from-blue-600 to-indigo-600 text-white shadow-md shadow-blue-500/20 ring-2 ring-white transition-transform group-hover:scale-105 group-hover:shadow-blue-500/30 dark:ring-slate-900">
            <span className="text-sm font-black tracking-wider">IO</span>
          </div>

          {/* Name & Role tag */}
          <div className="hidden sm:flex flex-col text-left">
            <span className="text-sm font-bold tracking-tight text-slate-900 group-hover:text-blue-600 dark:text-slate-100 dark:group-hover:text-blue-400">
              {contactData.name}
            </span>
            <span className="text-[10px] font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400">
              Portfolio
            </span>
          </div>
        </Link>

        {/* Desktop Navigation Links */}
        <nav className="hidden xl:flex items-center gap-5">
          <Link
            href="/"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
          >
            {t.nav.home}
          </Link>
          <Link
            href="/#about"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
          >
            {t.nav.about}
          </Link>
          <Link
            href="/#skills"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
          >
            {t.nav.skills}
          </Link>
          <Link
            href="/projects"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
          >
            {t.nav.projects}
          </Link>
          <Link
            href="/#experience"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
          >
            {t.nav.experience}
          </Link>
          <Link
            href="/#education"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
          >
            {t.nav.education}
          </Link>
          <Link
            href="/contact"
            className="text-sm font-medium text-slate-600 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
          >
            {t.nav.contact}
          </Link>
        </nav>

        {/* Action Buttons: Cmd+K Search, Language Switch, Copy Email, Theme Toggle & CV */}
        <div className="hidden md:flex items-center gap-2 shrink-0">
          {/* Spotlight Command Menu Trigger Button */}
          <button
            onClick={toggleOpen}
            type="button"
            aria-label="Open Command Menu"
            className="flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50/80 px-2.5 py-1.5 text-xs text-slate-500 transition hover:bg-slate-100 hover:text-slate-900 hover:border-slate-300 dark:border-slate-800 dark:bg-slate-900/80 dark:text-slate-400 dark:hover:bg-slate-800 dark:hover:text-slate-200"
          >
            <Search size={14} className="text-slate-400 dark:text-slate-500" />
            <span className="hidden lg:inline text-xs font-medium text-slate-600 dark:text-slate-400">
              {t.nav.commandMenu}
            </span>
            <kbd className="inline-flex items-center rounded border border-slate-200 bg-white px-1.5 py-0.5 font-mono text-[10px] font-semibold text-slate-500 shadow-2xs dark:border-slate-700 dark:bg-slate-800 dark:text-slate-400">
              {isMac ? "⌘K" : "Ctrl+K"}
            </kbd>
          </button>

          {/* Language Switcher */}
          <LanguageToggle />

          {/* Copy Email Button */}
          <CopyButton
            textToCopy={contactData.email}
            ariaLabel={t.nav.copyEmail}
            tooltipText={t.contact.copySuccess}
            className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-slate-50 text-slate-600 transition hover:bg-blue-50 hover:text-blue-600 hover:border-blue-200 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800 dark:hover:text-blue-400"
          />

          {/* Theme Toggle */}
          <button
            onClick={toggleTheme}
            aria-label="Toggle theme"
            className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-slate-50 text-slate-600 transition hover:bg-slate-100 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
          >
            {theme === "dark" ? <Sun size={17} /> : <Moon size={17} />}
          </button>

          {/* Download CV */}
          <a
            href="/cv/CV-Indra-Oki-Sandy.pdf"
            download="CV-Indra-Oki-Sandy-Software-Developer.pdf"
            className="inline-flex items-center gap-1.5 rounded-lg bg-blue-600 px-3 py-2 text-xs font-semibold text-white shadow-sm transition hover:bg-blue-700 active:scale-95"
          >
            <ArrowDownToLine size={14} />
            <span>{t.nav.downloadCv}</span>
          </a>
        </div>

        {/* Mobile Header Buttons */}
        <div className="flex md:hidden items-center gap-1.5">
          {/* Mobile Cmdk Button */}
          <button
            onClick={toggleOpen}
            type="button"
            aria-label="Open Command Menu"
            className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-slate-50 text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300"
          >
            <Search size={17} />
          </button>

          {/* Mobile Language Switcher */}
          <LanguageToggle />

          {/* Mobile Theme Toggle */}
          <button
            onClick={toggleTheme}
            aria-label="Toggle theme"
            className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 bg-slate-50 text-slate-600 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300"
          >
            {theme === "dark" ? <Sun size={17} /> : <Moon size={17} />}
          </button>

          {/* Mobile Menu Hamburger */}
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            aria-label="Toggle mobile menu"
            className="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 text-slate-700 dark:border-slate-800 dark:text-slate-200"
          >
            {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </div>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="border-b border-slate-200 bg-white px-4 py-4 md:hidden dark:border-slate-800 dark:bg-slate-950">
          <nav className="flex flex-col gap-3">
            <Link
              href="/"
              onClick={() => setMobileMenuOpen(false)}
              className="text-sm font-medium text-slate-700 py-1.5 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
            >
              {t.nav.home}
            </Link>
            <Link
              href="/#about"
              onClick={() => setMobileMenuOpen(false)}
              className="text-sm font-medium text-slate-700 py-1.5 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
            >
              {t.nav.about}
            </Link>
            <Link
              href="/#skills"
              onClick={() => setMobileMenuOpen(false)}
              className="text-sm font-medium text-slate-700 py-1.5 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
            >
              {t.nav.skills}
            </Link>
            <Link
              href="/projects"
              onClick={() => setMobileMenuOpen(false)}
              className="text-sm font-medium text-slate-700 py-1.5 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
            >
              {t.nav.projects}
            </Link>
            <Link
              href="/#experience"
              onClick={() => setMobileMenuOpen(false)}
              className="text-sm font-medium text-slate-700 py-1.5 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
            >
              {t.nav.experience}
            </Link>
            <Link
              href="/#education"
              onClick={() => setMobileMenuOpen(false)}
              className="text-sm font-medium text-slate-700 py-1.5 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
            >
              {t.nav.education}
            </Link>
            <Link
              href="/contact"
              onClick={() => setMobileMenuOpen(false)}
              className="text-sm font-medium text-slate-700 py-1.5 transition-colors hover:text-blue-600 dark:text-slate-300 dark:hover:text-blue-400"
            >
              {t.nav.contact}
            </Link>

            <div className="pt-2 border-t border-slate-100 dark:border-slate-800 flex flex-col gap-2">
              <a
                href="/cv/CV-Indra-Oki-Sandy.pdf"
                download="CV-Indra-Oki-Sandy-Software-Developer.pdf"
                className="flex items-center justify-center gap-2 rounded-lg bg-blue-600 py-2.5 text-xs font-semibold text-white shadow-sm transition hover:bg-blue-700"
              >
                <ArrowDownToLine size={15} />
                {t.nav.downloadCv}
              </a>
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}
