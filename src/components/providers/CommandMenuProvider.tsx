"use client";

import React, { createContext, useContext, useState, useEffect } from "react";

interface CommandMenuContextType {
  open: boolean;
  setOpen: (open: boolean) => void;
  toggleOpen: () => void;
  isMac: boolean;
}

const CommandMenuContext = createContext<CommandMenuContextType | undefined>(undefined);

export function CommandMenuProvider({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const [isMac, setIsMac] = useState(false);

  useEffect(() => {
    // Detect OS for shortcut hint (Ctrl + K on Windows/Linux, ⌘K on macOS)
    if (typeof window !== "undefined") {
      setIsMac(/(Mac|iPhone|iPod|iPad)/i.test(navigator.platform));
    }

    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.key === "k" || e.key === "K") && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen((prev) => !prev);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  const toggleOpen = () => setOpen((prev) => !prev);

  return (
    <CommandMenuContext.Provider value={{ open, setOpen, toggleOpen, isMac }}>
      {children}
    </CommandMenuContext.Provider>
  );
}

export function useCommandMenu() {
  const context = useContext(CommandMenuContext);
  if (!context) {
    throw new Error("useCommandMenu must be used within a CommandMenuProvider");
  }
  return context;
}
