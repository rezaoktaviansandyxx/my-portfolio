"use client";

import React from "react";

export const SECTION_ROUTES: Record<string, string> = {
  home: "/",
  about: "/about",
  skills: "/skills",
  projects: "/projects",
  experience: "/experience",
  education: "/education",
  contact: "/contact",
};

export const ROUTE_SECTIONS: Record<string, string> = {
  "/": "home",
  "/about": "about",
  "/about/": "about",
  "/skills": "skills",
  "/skills/": "skills",
  "/projects": "projects",
  "/projects/": "projects",
  "/experience": "experience",
  "/experience/": "experience",
  "/education": "education",
  "/education/": "education",
  "/contact": "contact",
  "/contact/": "contact",
};

function isHomeOrSectionPage(pathname: string): boolean {
  return pathname in ROUTE_SECTIONS;
}

/**
 * Smoothly scrolls to a section and updates the browser address bar to a clean path
 * (e.g. /about, /skills, /projects) without any '#' hash symbol.
 */
export function scrollToSection(sectionId: string, e?: React.MouseEvent) {
  if (e) {
    e.preventDefault();
  }

  if (typeof window === "undefined") return;

  const targetPath = SECTION_ROUTES[sectionId] || "/";
  const currentPath = window.location.pathname;

  if (isHomeOrSectionPage(currentPath)) {
    if (sectionId === "home" || sectionId === "top") {
      window.scrollTo({ top: 0, behavior: "smooth" });
    } else {
      const element = document.getElementById(sectionId);
      if (element) {
        element.scrollIntoView({ behavior: "smooth" });
      }
    }

    // Update browser URL cleanly without '#' and without page reload
    if (window.location.pathname !== targetPath) {
      window.history.pushState({ sectionId }, "", targetPath);
    }
  } else {
    // If navigating from an external route (e.g. /project/list), perform full navigation
    window.location.href = targetPath;
  }
}
