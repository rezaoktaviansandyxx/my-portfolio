export type ProjectCategory = "POS & Desktop" | "Mobile" | "Frontend" | "Personal Project";

export interface Project {
  slug: string;
  title: string;
  shortDescription: string;
  shortDescriptionEn?: string;
  technologies: string[];
  role: string;
  roleEn?: string;
  category: ProjectCategory;
  categoryEn?: string;
  featured?: boolean;
  overview?: string;
  overviewEn?: string;
  responsibilities?: string[];
  responsibilitiesEn?: string[];
  githubUrl?: string;
  liveUrl?: string;
  image?: string;
  gallery?: string[];
}

export interface WorkExperience {
  company: string;
  position: string;
  period: string;
  location?: string;
  type?: string;
  description: string;
  responsibilities?: string[];
}

export interface Education {
  institution: string;
  degree: string;
  degreeEn?: string;
  major: string;
  majorEn?: string;
  graduationYear: string;
}

export interface SkillCategory {
  category: string;
  skills: string[];
}

export interface ContactInfo {
  name: string;
  title: string;
  email: string;
  whatsapp: string;
  whatsappUrl: string;
  linkedin: string;
  github: string;
  location?: string;
}

export interface NavItem {
  label: string;
  href: string;
}
