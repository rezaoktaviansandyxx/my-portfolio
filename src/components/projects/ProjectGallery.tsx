"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import {
  X,
  ChevronLeft,
  ChevronRight,
  ZoomIn,
  ZoomOut,
  Maximize2,
  ExternalLink,
} from "lucide-react";
import { useLanguage } from "@/components/providers/LanguageProvider";

interface ProjectGalleryProps {
  title: string;
  gallery: string[];
  isMobile?: boolean;
}

export function ProjectGallery({
  title,
  gallery,
  isMobile = false,
}: ProjectGalleryProps) {
  const { language } = useLanguage();
  const isEn = language === "en";

  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [isZoomed, setIsZoomed] = useState(false);

  // Reset zoom level whenever slide changes or closes
  useEffect(() => {
    setIsZoomed(false);
  }, [selectedIndex]);

  // Keyboard navigation for lightbox
  useEffect(() => {
    if (selectedIndex === null) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setSelectedIndex(null);
      } else if (e.key === "ArrowRight") {
        setSelectedIndex((prev) => (prev !== null ? (prev + 1) % gallery.length : 0));
      } else if (e.key === "ArrowLeft") {
        setSelectedIndex((prev) =>
          prev !== null ? (prev - 1 + gallery.length) % gallery.length : 0
        );
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    document.body.style.overflow = "hidden";

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      document.body.style.overflow = "auto";
    };
  }, [selectedIndex, gallery.length]);

  return (
    <>
      {/* Gallery Grid */}
      <div
        className={`mt-4 grid gap-4 ${
          isMobile
            ? "grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6"
            : "grid-cols-1 sm:grid-cols-2"
        }`}
      >
        {gallery.map((imgSrc, idx) => (
          <div
            key={idx}
            onClick={() => setSelectedIndex(idx)}
            className="group relative cursor-pointer overflow-hidden rounded-xl border border-slate-200 bg-slate-100 shadow-xs transition duration-200 hover:-translate-y-0.5 hover:border-blue-400 hover:shadow-md dark:border-slate-800 dark:bg-slate-900 dark:hover:border-blue-500"
          >
            <div
              className={`relative w-full ${
                isMobile ? "aspect-[9/19.5]" : "aspect-video"
              }`}
            >
              <Image
                src={imgSrc}
                alt={`${title} screenshot ${idx + 1}`}
                fill
                sizes={
                  isMobile
                    ? "(max-width: 640px) 50vw, (max-width: 768px) 33vw, 20vw"
                    : "(max-width: 640px) 100vw, 50vw"
                }
                className="object-contain p-1 transition-transform duration-300 group-hover:scale-[1.02]"
              />
              <div className="absolute inset-0 flex items-center justify-center bg-black/35 opacity-0 backdrop-blur-[1px] transition-opacity duration-200 group-hover:opacity-100">
                <span className="flex items-center gap-1.5 rounded-full bg-white/95 px-3 py-1.5 text-xs font-semibold text-slate-800 shadow-md dark:bg-slate-900/95 dark:text-slate-100">
                  <ZoomIn size={14} className="text-blue-600 dark:text-blue-400" />
                  {isEn ? "Enlarge Image" : "Perbesar Resolusi"}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Lightbox Modal */}
      {selectedIndex !== null && (
        <div
          className="fixed inset-0 z-50 flex flex-col items-center justify-between bg-black/95 p-3 sm:p-6 backdrop-blur-md transition-opacity animate-in fade-in"
          onClick={() => setSelectedIndex(null)}
        >
          {/* Top Controls Toolbar */}
          <div
            className="flex w-full max-w-6xl items-center justify-between py-2 z-50 text-white"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center gap-3">
              <span className="text-xs sm:text-sm font-semibold tracking-wide text-slate-200">
                {title}
              </span>
              <span className="rounded-full bg-white/15 px-2.5 py-0.5 text-xs font-medium text-slate-300">
                {selectedIndex + 1} / {gallery.length}
              </span>
            </div>

            <div className="flex items-center gap-2">
              {/* Toggle Zoom button */}
              <button
                type="button"
                onClick={() => setIsZoomed((prev) => !prev)}
                className="flex items-center gap-1.5 rounded-lg bg-white/10 px-3 py-1.5 text-xs font-medium text-white transition hover:bg-white/20"
                title={isZoomed ? (isEn ? "Reset Zoom" : "Reset Zoom") : (isEn ? "Zoom 1.5x" : "Zoom 100% (Detail Nyata)")}
              >
                {isZoomed ? (
                  <>
                    <ZoomOut size={15} />
                    <span className="hidden sm:inline">{isEn ? "Fit Screen" : "Fit Layar"}</span>
                  </>
                ) : (
                  <>
                    <ZoomIn size={15} />
                    <span className="hidden sm:inline">Zoom 1.5x</span>
                  </>
                )}
              </button>

              {/* Open raw image in new tab */}
              <a
                href={gallery[selectedIndex]}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-1.5 rounded-lg bg-white/10 px-3 py-1.5 text-xs font-medium text-white transition hover:bg-white/20"
                title={isEn ? "Open original image in new tab" : "Buka gambar asli di tab baru"}
              >
                <ExternalLink size={15} />
                <span className="hidden sm:inline">{isEn ? "Open Original" : "Buka Asli"}</span>
              </a>

              {/* Close button */}
              <button
                type="button"
                onClick={() => setSelectedIndex(null)}
                className="flex h-8 w-8 items-center justify-center rounded-lg bg-white/10 text-white transition hover:bg-white/20 hover:scale-105"
                aria-label={isEn ? "Close" : "Tutup"}
              >
                <X size={18} />
              </button>
            </div>
          </div>

          {/* Navigation Previous Button */}
          {gallery.length > 1 && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                setSelectedIndex((prev) =>
                  prev !== null ? (prev - 1 + gallery.length) % gallery.length : 0
                );
              }}
              className="absolute left-3 sm:left-6 top-1/2 -translate-y-1/2 z-50 flex h-11 w-11 items-center justify-center rounded-full bg-white/10 text-white backdrop-blur-sm transition hover:bg-white/25 hover:scale-105"
              aria-label={isEn ? "Previous" : "Sebelumnya"}
            >
              <ChevronLeft size={24} />
            </button>
          )}

          {/* Main Image Viewport */}
          <div
            className={`relative flex flex-1 w-full items-center justify-center overflow-auto py-2 ${
              isZoomed ? "cursor-zoom-out" : "cursor-zoom-in"
            }`}
            onClick={(e) => {
              e.stopPropagation();
              setIsZoomed((prev) => !prev);
            }}
          >
            <div
              className={`relative transition-all duration-300 ${
                isZoomed
                  ? isMobile
                    ? "h-[140vh] w-[600px] max-w-[95vw]"
                    : "h-[120vh] w-[1600px] max-w-[95vw]"
                  : isMobile
                  ? "h-[75vh] w-[380px] max-w-[85vw]"
                  : "h-[72vh] w-[1100px] max-w-[85vw]"
              }`}
            >
              <Image
                src={gallery[selectedIndex]}
                alt={`${title} detail view ${selectedIndex + 1}`}
                fill
                priority
                className="object-contain drop-shadow-2xl"
              />
            </div>
          </div>

          {/* Navigation Next Button */}
          {gallery.length > 1 && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                setSelectedIndex((prev) =>
                  prev !== null ? (prev + 1) % gallery.length : 0
                );
              }}
              className="absolute right-3 sm:right-6 top-1/2 -translate-y-1/2 z-50 flex h-11 w-11 items-center justify-center rounded-full bg-white/10 text-white backdrop-blur-sm transition hover:bg-white/25 hover:scale-105"
              aria-label={isEn ? "Next" : "Berikutnya"}
            >
              <ChevronRight size={24} />
            </button>
          )}

          {/* Bottom Thumbnail Strip */}
          {gallery.length > 1 && (
            <div
              className="flex items-center gap-2 overflow-x-auto py-2 max-w-2xl px-2 z-50"
              onClick={(e) => e.stopPropagation()}
            >
              {gallery.map((thumb, tIdx) => (
                <button
                  key={tIdx}
                  onClick={() => setSelectedIndex(tIdx)}
                  className={`relative h-12 w-16 shrink-0 overflow-hidden rounded-md border-2 transition ${
                    selectedIndex === tIdx
                      ? "border-blue-500 ring-2 ring-blue-500/50"
                      : "border-white/20 opacity-60 hover:opacity-100"
                  }`}
                >
                  <Image
                    src={thumb}
                    alt={`Thumbnail ${tIdx + 1}`}
                    fill
                    className="object-cover"
                  />
                </button>
              ))}
            </div>
          )}
        </div>
      )}
    </>
  );
}
