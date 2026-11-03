"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import { Language, translations } from "@/lib/i18n";

type TranslationsType = typeof translations.id | typeof translations.en;

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  toggleLanguage: () => void;
  t: TranslationsType;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [language, setLanguageState] = useState<Language>("id");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    const saved = localStorage.getItem("language") as Language | null;
    if (saved === "id" || saved === "en") {
      setLanguageState(saved);
      document.documentElement.lang = saved;
    } else {
      // Check browser navigator language
      const browserLang = navigator.language.startsWith("id") ? "id" : "en";
      setLanguageState(browserLang);
      document.documentElement.lang = browserLang;
    }
  }, []);

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    localStorage.setItem("language", lang);
    document.documentElement.lang = lang;
  };

  const toggleLanguage = () => {
    const nextLang: Language = language === "id" ? "en" : "id";
    setLanguage(nextLang);
  };

  const currentTranslations: TranslationsType = translations[language];

  return (
    <LanguageContext.Provider
      value={{
        language,
        setLanguage,
        toggleLanguage,
        t: currentTranslations,
      }}
    >
      {children}
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return context;
}
