import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { ContactSection } from "@/components/sections/ContactSection";

export const metadata = {
  title: "Contact | Indra Oki Sandy",
  description: "Hubungi Indra Oki Sandy untuk penawaran kerja Flutter Developer, Web Developer, atau proyek freelance."
};

export default function ContactPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <Navbar />
      <main className="flex-1">
        <ContactSection />
      </main>
      <Footer />
    </div>
  );
}
