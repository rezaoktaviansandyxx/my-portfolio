"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import { X, ChevronLeft, ChevronRight, ZoomIn } from "lucide-react";

interface ProjectGalleryProps {
  title: string;
  gallery: string[];
  isMobile?: boolean;
}

export function ProjectGallery({ title, gallery, isMobile = false }: ProjectGalleryProps) {
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);

  // Keyboard navigation for lightbox
  useEffect(() => {
    if (selectedIndex === null) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setSelectedIndex(null);
      } else if (e.key === "ArrowRight") {
        setSelectedIndex((prev) => (prev !== null ? (prev + 1) % gallery.length : 0));
      } else if (e.key === "ArrowLeft") {
        setSelectedIndex((prev) => (prev !== null ? (prev - 1 + gallery.length) % gallery.length : 0));
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
              <div className="absolute inset-0 flex items-center justify-center bg-black/30 opacity-0 backdrop-blur-[1px] transition-opacity duration-200 group-hover:opacity-100">
                <span className="flex items-center gap-1 rounded-full bg-white/90 px-2.5 py-1 text-xs font-semibold text-slate-800 shadow dark:bg-slate-900/90 dark:text-slate-200">
                  <ZoomIn size={14} />
                  Perbesar
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Lightbox Modal */}
      {selectedIndex !== null && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 p-4 backdrop-blur-sm transition-opacity animate-in fade-in"
          onClick={() => setSelectedIndex(null)}
        >
          {/* Close button */}
          <button
            onClick={() => setSelectedIndex(null)}
            className="absolute top-4 right-4 z-50 flex h-10 w-10 items-center justify-center rounded-full bg-white/10 text-white transition hover:bg-white/20 hover:scale-105"
            aria-label="Tutup"
          >
            <X size={20} />
          </button>

          {/* Navigation previous */}
          {gallery.length > 1 && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                setSelectedIndex((prev) => (prev !== null ? (prev - 1 + gallery.length) % gallery.length : 0));
              }}
              className="absolute left-4 top-1/2 -translate-y-1/2 z-50 flex h-11 w-11 items-center justify-center rounded-full bg-white/10 text-white transition hover:bg-white/20 hover:scale-105"
              aria-label="Sebelumnya"
            >
              <ChevronLeft size={24} />
            </button>
          )}

          {/* Main image container */}
          <div
            className="relative flex max-h-[90vh] max-w-[90vw] items-center justify-center"
            onClick={(e) => e.stopPropagation()}
          >
            <div
              className={`relative ${
                isMobile ? "h-[85vh] w-[400px] max-w-[85vw]" : "h-[75vh] w-[1200px] max-w-[85vw]"
              }`}
            >
              <Image
                src={gallery[selectedIndex]}
                alt={`${title} modal view ${selectedIndex + 1}`}
                fill
                priority
                className="object-contain"
              />
            </div>
          </div>

          {/* Navigation next */}
          {gallery.length > 1 && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                setSelectedIndex((prev) => (prev !== null ? (prev + 1) % gallery.length : 0));
              }}
              className="absolute right-4 top-1/2 -translate-y-1/2 z-50 flex h-11 w-11 items-center justify-center rounded-full bg-white/10 text-white transition hover:bg-white/20 hover:scale-105"
              aria-label="Berikutnya"
            >
              <ChevronRight size={24} />
            </button>
          )}

          {/* Image indicator caption */}
          <div className="absolute bottom-4 left-1/2 -translate-x-1/2 rounded-full bg-white/15 px-3 py-1 text-xs font-medium text-white backdrop-blur-sm">
            {selectedIndex + 1} / {gallery.length}
          </div>
        </div>
      )}
    </>
  );
}
