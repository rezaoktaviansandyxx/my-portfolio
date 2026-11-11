"use client";

import Link from "next/link";
import { useState, useEffect, useRef } from "react";
import { usePathname } from "next/navigation";
import { Menu, X, Sun, Moon, ArrowDownToLine, Search } from "lucide-react";
import { useTheme } from "@/components/providers/ThemeProvider";
import { useLanguage } from "@/components/providers/LanguageProvider";
import { useCommandMenu } from "@/components/providers/CommandMenuProvider";
import { contactData } from "@/data/navigation";
import { CopyButton } from "@/components/ui/CopyButton";
import { LanguageToggle } from "@/components/ui/LanguageToggle";
import { scrollToSection, ROUTE_SECTIONS, SECTION_ROUTES } from "@/lib/scroll";

const SECTION_IDS = ["home", "about", "skills", "projects", "experience", "education", "contact"];

export function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState<string>("home");
  const isUserClickingRef = useRef(false);
  const { toggleOpen, isMac } = useCommandMenu();
  const { theme, toggleTheme } = useTheme();
  const { t, language } = useLanguage();
  const cvFile = language === "en" ? "/cv/CV_Indra_Oki_Sandy_EN.pdf" : "/cv/CV_Indra_Oki_Sandy_ID.pdf";
  const cvDownloadName = language === "en" ? "CV_Indra_Oki_Sandy_EN.pdf" : "CV_Indra_Oki_Sandy_ID.pdf";
  const pathname = usePathname();

  const isSectionPage = Boolean(pathname && pathname in ROUTE_SECTIONS);

  // Track initial route & handle back/forward
  useEffect(() => {
    if (typeof window === "undefined") return;

    if (!isSectionPage) {
      setActiveSection("");
      return;
    }

    // 1. If loaded with an old hash URL (e.g. localhost:3000/#about), convert it to clean route /about
    if (window.location.hash) {
      const targetId = window.location.hash.replace("#", "");
      const targetPath = SECTION_ROUTES[targetId] || "/";
      const element = document.getElementById(targetId);
      if (element) {
        setTimeout(() => {
          element.scrollIntoView({ behavior: "smooth" });
        }, 80);
      }
      window.history.replaceState(null, "", targetPath);
      setActiveSection(targetId);
    } else {
      // 2. If loaded directly at a section route (e.g. /about, /skills, /projects, etc.)
      const section = ROUTE_SECTIONS[window.location.pathname];
      if (section && section !== "home") {
        setActiveSection(section);
        const element = document.getElementById(section);
        if (element) {
          setTimeout(() => {
            element.scrollIntoView({ behavior: "smooth" });
          }, 80);
        }
      } else if (section === "home") {
        setActiveSection("home");
      }
    }

    // 3. Handle browser Back / Forward buttons
    const handlePopState = () => {
      const section = ROUTE_SECTIONS[window.location.pathname];
      if (section === "home") {
        setActiveSection("home");
        window.scrollTo({ top: 0, behavior: "smooth" });
      } else if (section) {
        setActiveSection(section);
        const element = document.getElementById(section);
        if (element) {
          element.scrollIntoView({ behavior: "smooth" });
        }
      }
    };

    window.addEventListener("popstate", handlePopState);
    return () => window.removeEventListener("popstate", handlePopState);
  }, [isSectionPage]);

  // Active scroll spy & URL updater
  useEffect(() => {
    if (typeof window === "undefined") return;

    // Only enable scroll spy if on the main single-page sections
    if (!isSectionPage) return;

    const handleScroll = () => {
      // If user navigated away from section pages, don't update URL
      if (!ROUTE_SECTIONS[window.location.pathname]) return;

      // If scroll was triggered by a direct click, let the click handler control state temporarily
      if (isUserClickingRef.current) return;

      const scrollPosition = window.scrollY + 140; // offset below fixed navbar

      // If at the very top of the page
      if (window.scrollY < 80) {
        if (activeSection !== "home") {
          setActiveSection("home");
          if (window.location.pathname !== "/") {
            window.history.replaceState(null, "", "/");
          }
        }
        return;
      }

      // Check each section position
      let currentActive = "home";
      for (const id of SECTION_IDS) {
        const el = document.getElementById(id);
        if (el) {
          const top = el.offsetTop;
          if (scrollPosition >= top) {
            currentActive = id;
          }
        }
      }

      // Check if user reached bottom of page -> activate contact
      if (window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 50) {
        currentActive = "contact";
      }

      if (currentActive !== activeSection) {
        setActiveSection(currentActive);
        const targetPath = SECTION_ROUTES[currentActive] || "/";
        if (window.location.pathname !== targetPath) {
          window.history.replaceState(null, "", targetPath);
        }
      }
    };

    window.addEventListener("scroll", handleScroll, { passive: true });
    // Run once on mount
    handleScroll();

    return () => window.removeEventListener("scroll", handleScroll);
  }, [pathname, isSectionPage, activeSection]);

  const handleNavClick = (sectionId: string, e: React.MouseEvent) => {
    isUserClickingRef.current = true;
    setActiveSection(sectionId);
    scrollToSection(sectionId, e);

    setTimeout(() => {
      isUserClickingRef.current = false;
    }, 800);
  };

  const navLinks = [
    { id: "home", href: "/", label: t.nav.home },
    { id: "about", href: "/about", label: t.nav.about },
    { id: "skills", href: "/skills", label: t.nav.skills },
    { id: "projects", href: "/projects", label: t.nav.projects },
    { id: "experience", href: "/experience", label: t.nav.experience },
    { id: "education", href: "/education", label: t.nav.education },
    { id: "contact", href: "/contact", label: t.nav.contact },
  ];

  return (
    <header className="sticky top-0 z-40 w-full border-b border-slate-200/80 bg-white/80 backdrop-blur-md transition-colors dark:border-slate-800/80 dark:bg-slate-950/80">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-4 sm:px-6 lg:px-8 h-16 gap-3">
        {/* Brand / Logo */}
        <Link
          href="/"
          onClick={(e) => handleNavClick("home", e)}
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
        <nav className="hidden xl:flex items-center gap-1">
          {navLinks.map((item) => {
            const isActive = activeSection === item.id;
            return (
              <Link
                key={item.id}
                href={item.href}
                onClick={(e) => handleNavClick(item.id, e)}
                className={`relative px-3 py-1.5 text-sm font-medium rounded-lg transition-all ${
                  isActive
                    ? "text-blue-600 dark:text-blue-400 font-semibold bg-blue-50/80 dark:bg-blue-950/50"
                    : "text-slate-600 hover:text-slate-900 hover:bg-slate-100/70 dark:text-slate-300 dark:hover:text-white dark:hover:bg-slate-800/60"
                }`}
              >
                {item.label}
                {isActive && (
                  <span className="absolute bottom-0 left-3 right-3 h-0.5 bg-blue-600 dark:bg-blue-400 rounded-full" />
                )}
              </Link>
            );
          })}
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
            href={cvFile}
            download={cvDownloadName}
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
          <nav className="flex flex-col gap-1.5">
            {navLinks.map((item) => {
              const isActive = activeSection === item.id;
              return (
                <Link
                  key={item.id}
                  href={item.href}
                  onClick={(e) => {
                    setMobileMenuOpen(false);
                    handleNavClick(item.id, e);
                  }}
                  className={`text-sm font-medium px-3 py-2 rounded-lg transition-colors flex items-center justify-between ${
                    isActive
                      ? "bg-blue-50 text-blue-600 dark:bg-blue-950/60 dark:text-blue-400 font-semibold"
                      : "text-slate-700 hover:bg-slate-100 hover:text-blue-600 dark:text-slate-300 dark:hover:bg-slate-900 dark:hover:text-blue-400"
                  }`}
                >
                  <span>{item.label}</span>
                  {isActive && (
                    <span className="h-1.5 w-1.5 rounded-full bg-blue-600 dark:bg-blue-400" />
                  )}
                </Link>
              );
            })}

            <div className="mt-2 pt-3 border-t border-slate-100 dark:border-slate-800 flex flex-col gap-2">
              <a
                href={cvFile}
                download={cvDownloadName}
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
