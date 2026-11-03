import { ContactInfo, NavItem } from "@/types";

export const contactData: ContactInfo = {
  name: "Indra Oki Sandy",
  title: "Flutter Developer & Web Developer",
  email: "indraokisandy1@gmail.com",
  whatsapp: "089520603456",
  whatsappUrl: "https://wa.me/6289520603456",
  linkedin: "https://www.linkedin.com/in/indraokisandy/",
  github: "https://github.com/rezaoktaviansandyxx",
  location: "Indonesia"
};

export const navigationItems: NavItem[] = [
  { label: "Home", href: "/" },
  { label: "About", href: "/#about" },
  { label: "Skills", href: "/#skills" },
  { label: "Projects", href: "/projects" },
  { label: "Experience", href: "/#experience" },
  { label: "Education", href: "/#education" },
  { label: "Contact", href: "/contact" }
];
