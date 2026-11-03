"use client";

import { useLanguage } from "@/components/providers/LanguageProvider";

interface LanguageToggleProps {
  className?: string;
}

export function LanguageToggle({ className = "" }: LanguageToggleProps) {
  const { language, setLanguage } = useLanguage();

  return (
    <div
      role="group"
      aria-label="Pilih Bahasa / Select Language"
      className={`inline-flex items-center rounded-lg border border-slate-200 bg-slate-100/90 p-0.5 dark:border-slate-800 dark:bg-slate-900/90 ${className}`}
    >
      {/* Tombol ID */}
      <button
        type="button"
        onClick={() => setLanguage("id")}
        aria-pressed={language === "id"}
        className={`relative rounded-md px-2 py-1 text-[11px] font-semibold transition-all duration-200 ${
          language === "id"
            ? "bg-white text-blue-600 shadow-xs dark:bg-slate-800 dark:text-blue-400"
            : "text-slate-500 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
        }`}
        title="Bahasa Indonesia"
      >
        ID
      </button>

      {/* Tombol EN */}
      <button
        type="button"
        onClick={() => setLanguage("en")}
        aria-pressed={language === "en"}
        className={`relative rounded-md px-2 py-1 text-[11px] font-semibold transition-all duration-200 ${
          language === "en"
            ? "bg-white text-blue-600 shadow-xs dark:bg-slate-800 dark:text-blue-400"
            : "text-slate-500 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white"
        }`}
        title="English"
      >
        EN
      </button>
    </div>
  );
}
