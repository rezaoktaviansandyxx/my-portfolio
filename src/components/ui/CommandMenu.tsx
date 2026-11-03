"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Command } from "cmdk";
import {
  Home,
  User,
  Cpu,
  FolderGit2,
  Briefcase,
  GraduationCap,
  Mail,
  Download,
  Moon,
  Sun,
  Globe,
  Copy,
  ExternalLink,
  Search,
  Check,
} from "lucide-react";
import { useTheme } from "@/components/providers/ThemeProvider";
import { useLanguage } from "@/components/providers/LanguageProvider";
import { useCommandMenu } from "@/components/providers/CommandMenuProvider";
import { contactData } from "@/data/navigation";

export function CommandMenu() {
  const { open, setOpen, isMac } = useCommandMenu();
  const router = useRouter();
  const { theme, toggleTheme } = useTheme();
  const { language, setLanguage, t } = useLanguage();
  const [copiedText, setCopiedText] = useState<string | null>(null);

  const runCommand = (command: () => void) => {
    command();
    setOpen(false);
  };

  const handleCopy = (text: string, label: string) => {
    if (navigator.clipboard) {
      navigator.clipboard.writeText(text);
      setCopiedText(label);
      setTimeout(() => {
        setCopiedText(null);
        setOpen(false);
      }, 700);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center pt-20 sm:pt-28 bg-slate-950/60 backdrop-blur-sm p-4 animate-in fade-in duration-150">
      <div
        className="fixed inset-0 -z-10"
        onClick={() => setOpen(false)}
        aria-hidden="true"
      />

      <div className="relative w-full max-w-xl overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl dark:border-slate-800 dark:bg-slate-900">
        <Command
          label="Global Command Menu"
          className="w-full flex flex-col focus:outline-none"
        >
          {/* Search Header Input */}
          <div className="flex items-center gap-3 border-b border-slate-100 px-4 py-3.5 dark:border-slate-800/80">
            <Search className="h-4 w-4 shrink-0 text-slate-400" />
            <Command.Input
              placeholder={t.cmdk.searchPlaceholder}
              autoFocus
              className="w-full bg-transparent text-sm font-medium text-slate-900 placeholder:text-slate-400 focus:outline-none dark:text-white"
            />
            <kbd className="hidden sm:inline-flex items-center gap-1 rounded bg-slate-100 px-1.5 py-0.5 text-[10px] font-semibold text-slate-500 dark:bg-slate-800 dark:text-slate-400">
              ESC
            </kbd>
          </div>

          {/* Items List */}
          <Command.List className="max-h-[350px] overflow-y-auto p-2 scrollbar-thin">
            <Command.Empty className="py-8 text-center text-sm text-slate-500 dark:text-slate-400">
              {t.cmdk.noResults}
            </Command.Empty>

            {/* Group: Navigation */}
            <Command.Group
              heading={t.cmdk.navigationGroup}
              className="px-2 py-1.5 text-xs font-semibold text-slate-400 dark:text-slate-500 uppercase tracking-wider [&_[cmdk-group-heading]]:py-1.5"
            >
              <Command.Item
                onSelect={() => runCommand(() => router.push("/"))}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <Home className="h-4 w-4 text-blue-500" />
                <span>{t.cmdk.goToHome}</span>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/#about"))}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <User className="h-4 w-4 text-blue-500" />
                <span>{t.cmdk.goToAbout}</span>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/#skills"))}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <Cpu className="h-4 w-4 text-blue-500" />
                <span>{t.cmdk.goToSkills}</span>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/projects"))}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <FolderGit2 className="h-4 w-4 text-blue-500" />
                <span>{t.cmdk.goToProjects}</span>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/#experience"))}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <Briefcase className="h-4 w-4 text-blue-500" />
                <span>{t.cmdk.goToExperience}</span>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/#education"))}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <GraduationCap className="h-4 w-4 text-blue-500" />
                <span>{t.cmdk.goToEducation}</span>
              </Command.Item>

              <Command.Item
                onSelect={() => runCommand(() => router.push("/contact"))}
                className="flex items-center gap-3 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <Mail className="h-4 w-4 text-blue-500" />
                <span>{t.cmdk.goToContact}</span>
              </Command.Item>
            </Command.Group>

            {/* Group: Actions */}
            <Command.Group
              heading={t.cmdk.actionsGroup}
              className="mt-2 px-2 py-1.5 text-xs font-semibold text-slate-400 dark:text-slate-500 uppercase tracking-wider [&_[cmdk-group-heading]]:py-1.5"
            >
              <Command.Item
                onSelect={() => {
                  const link = document.createElement("a");
                  link.href = "/cv/CV-Indra-Oki-Sandy.pdf";
                  link.download = "CV-Indra-Oki-Sandy-Software-Developer.pdf";
                  link.click();
                  setOpen(false);
                }}
                className="flex items-center justify-between rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3">
                  <Download className="h-4 w-4 text-emerald-500" />
                  <span>{t.cmdk.downloadCvAction}</span>
                </div>
                <span className="text-xs text-slate-400">PDF</span>
              </Command.Item>

              <Command.Item
                onSelect={() => handleCopy(contactData.email, "email")}
                className="flex items-center justify-between rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3">
                  {copiedText === "email" ? (
                    <Check className="h-4 w-4 text-emerald-500" />
                  ) : (
                    <Copy className="h-4 w-4 text-indigo-500" />
                  )}
                  <span>
                    {copiedText === "email"
                      ? language === "en"
                        ? "Copied to Clipboard!"
                        : "Tersalin ke Clipboard!"
                      : t.cmdk.copyEmailAction}
                  </span>
                </div>
                <span className="text-xs text-slate-400 font-mono">
                  {contactData.email}
                </span>
              </Command.Item>

              <Command.Item
                onSelect={() => handleCopy(contactData.whatsapp, "wa")}
                className="flex items-center justify-between rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3">
                  {copiedText === "wa" ? (
                    <Check className="h-4 w-4 text-emerald-500" />
                  ) : (
                    <Copy className="h-4 w-4 text-emerald-500" />
                  )}
                  <span>
                    {copiedText === "wa"
                      ? language === "en"
                        ? "Copied to Clipboard!"
                        : "Tersalin ke Clipboard!"
                      : t.cmdk.copyWhatsappAction}
                  </span>
                </div>
                <span className="text-xs text-slate-400 font-mono">
                  {contactData.whatsapp}
                </span>
              </Command.Item>

              <Command.Item
                onSelect={() => {
                  window.open(contactData.github, "_blank");
                  setOpen(false);
                }}
                className="flex items-center justify-between rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3">
                  <ExternalLink className="h-4 w-4 text-slate-500" />
                  <span>{t.cmdk.openGithub}</span>
                </div>
              </Command.Item>

              <Command.Item
                onSelect={() => {
                  window.open(contactData.linkedin, "_blank");
                  setOpen(false);
                }}
                className="flex items-center justify-between rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3">
                  <ExternalLink className="h-4 w-4 text-blue-500" />
                  <span>{t.cmdk.openLinkedin}</span>
                </div>
              </Command.Item>
            </Command.Group>

            {/* Group: Preferences */}
            <Command.Group
              heading={t.cmdk.preferencesGroup}
              className="mt-2 px-2 py-1.5 text-xs font-semibold text-slate-400 dark:text-slate-500 uppercase tracking-wider [&_[cmdk-group-heading]]:py-1.5"
            >
              <Command.Item
                onSelect={() => runCommand(() => toggleTheme())}
                className="flex items-center justify-between rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3">
                  {theme === "dark" ? (
                    <Sun className="h-4 w-4 text-amber-500" />
                  ) : (
                    <Moon className="h-4 w-4 text-indigo-500" />
                  )}
                  <span>{t.cmdk.toggleThemeAction}</span>
                </div>
                <span className="text-xs text-slate-400 capitalize">
                  {theme === "dark" ? "Dark Mode" : "Light Mode"}
                </span>
              </Command.Item>

              <Command.Item
                onSelect={() =>
                  runCommand(() => setLanguage(language === "id" ? "en" : "id"))
                }
                className="flex items-center justify-between rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-slate-800 dark:hover:text-white cursor-pointer transition-colors"
              >
                <div className="flex items-center gap-3">
                  <Globe className="h-4 w-4 text-blue-500" />
                  <span>
                    {language === "id"
                      ? "Switch to English (EN)"
                      : "Ganti ke Bahasa Indonesia (ID)"}
                  </span>
                </div>
                <span className="text-xs font-bold uppercase text-blue-600 dark:text-blue-400">
                  {language.toUpperCase()}
                </span>
              </Command.Item>
            </Command.Group>
          </Command.List>

          {/* Footer Shortcuts Info */}
          <div className="flex items-center justify-between border-t border-slate-100 px-4 py-2.5 text-[11px] text-slate-400 dark:border-slate-800/80">
            <div className="flex items-center gap-2">
              <span className="rounded bg-slate-100 px-1 py-0.5 font-mono text-[10px] text-slate-600 dark:bg-slate-800 dark:text-slate-400">
                ↵
              </span>
              <span>to select</span>
              <span className="rounded bg-slate-100 px-1 py-0.5 font-mono text-[10px] text-slate-600 dark:bg-slate-800 dark:text-slate-400 ml-2">
                ↑↓
              </span>
              <span>to navigate</span>
            </div>
            <span>{t.cmdk.shortcutHint}</span>
          </div>
        </Command>
      </div>
    </div>
  );
}
