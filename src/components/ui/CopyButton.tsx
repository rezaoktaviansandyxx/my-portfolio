"use client";

import { useState } from "react";
import { Copy, Check } from "lucide-react";

interface CopyButtonProps {
  textToCopy: string;
  label?: string;
  tooltipText?: string;
  ariaLabel: string;
  className?: string;
  size?: number;
  showText?: boolean;
}

export function CopyButton({
  textToCopy,
  label,
  tooltipText = "Tersalin!",
  ariaLabel,
  className = "",
  size = 16,
  showText = false,
}: CopyButtonProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    e.stopPropagation();

    try {
      if (navigator?.clipboard?.writeText) {
        await navigator.clipboard.writeText(textToCopy);
      } else {
        const textArea = document.createElement("textarea");
        textArea.value = textToCopy;
        textArea.style.position = "fixed";
        textArea.style.opacity = "0";
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        document.execCommand("copy");
        document.body.removeChild(textArea);
      }
      setCopied(true);
      setTimeout(() => {
        setCopied(false);
      }, 2000);
    } catch (err) {
      console.error("Gagal menyalin teks:", err);
    }
  };

  return (
    <div className="relative inline-flex items-center">
      <button
        type="button"
        onClick={handleCopy}
        aria-label={ariaLabel}
        title={ariaLabel}
        className={`group relative inline-flex items-center justify-center transition-all focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 ${className}`}
      >
        {copied ? (
          <Check size={size} className="text-emerald-500" />
        ) : (
          <Copy size={size} className="transition-transform group-hover:scale-105" />
        )}

        {showText && label && (
          <span className="ml-1.5 text-xs font-medium">{copied ? tooltipText : label}</span>
        )}
      </button>

      {/* Floating Tooltip Feedback */}
      {copied && !showText && (
        <div
          role="status"
          aria-live="polite"
          className="absolute top-full mt-2 left-1/2 -translate-x-1/2 z-50 pointer-events-none flex flex-col items-center"
        >
          {/* Panah tooltip ke atas */}
          <div className="w-0 h-0 border-x-4 border-x-transparent border-b-4 border-b-slate-900 dark:border-b-white" />
          <span className="rounded-md bg-slate-900 px-2.5 py-1 text-[11px] font-semibold text-white shadow-lg dark:bg-white dark:text-slate-900 whitespace-nowrap">
            {tooltipText}
          </span>
        </div>
      )}
    </div>
  );
}
