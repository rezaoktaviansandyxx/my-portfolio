import { WorkExperience, Education } from "@/types";
import { Language } from "@/lib/i18n";

export interface LocalizedWorkExperience extends WorkExperience {
  periodEn?: string;
  locationEn?: string;
  typeEn?: string;
  descriptionEn?: string;
  responsibilitiesEn?: string[];
}

export const localizedExperienceData: LocalizedWorkExperience[] = [
  {
    company: "PT Thunder Labs Indonesia",
    position: "Frontend Developer",
    period: "November 2025 - Oktober 2026 (1 tahun)",
    periodEn: "November 2025 - October 2026 (1 year)",
    location: "Jawa Timur, Indonesia",
    locationEn: "East Java, Indonesia",
    type: "Contract / Professional",
    typeEn: "Contract / Professional",
    description: "Mengembangkan antarmuka frontend untuk produk dan sistem digital perusahaan.",
    descriptionEn: "Built frontend interfaces for company products and digital systems.",
    responsibilities: [
      "Membangun dan merawat antarmuka aplikasi menggunakan teknologi frontend.",
      "Menghubungkan antarmuka dengan layanan backend melalui REST API.",
      "Menyempurnakan performa dan konsistensi antarmuka bersama tim pengembang."
    ],
    responsibilitiesEn: [
      "Built and maintained application interfaces using frontend technologies.",
      "Connected user interfaces to backend services through REST APIs.",
      "Improved interface performance and consistency with the engineering team."
    ]
  },
  {
    company: "PT Integrasi Data ERP (IDE)",
    position: "Flutter Developer",
    period: "Januari 2025 - April 2025 (4 bulan)",
    periodEn: "January 2025 - April 2025 (4 months)",
    location: "Indonesia",
    locationEn: "Indonesia",
    type: "Contract / Project",
    typeEn: "Contract / Project",
    description: "Mengembangkan aplikasi mobile Flutter untuk kebutuhan sistem ERP.",
    descriptionEn: "Developed Flutter mobile applications for ERP system workflows.",
    responsibilities: [
      "Menyusun modul aplikasi Flutter dengan state management yang terstruktur.",
      "Mengintegrasikan fitur mobile dengan backend ERP melalui REST API.",
      "Menangani sinkronisasi data dan alur transaksi pada aplikasi."
    ],
    responsibilitiesEn: [
      "Structured Flutter application modules with maintainable state management.",
      "Integrated mobile features with ERP backends through REST APIs.",
      "Handled application data synchronization and transaction workflows."
    ]
  },
  {
    company: "PT. ARSOFT SOLUSI TEKNOLOGI",
    position: "Programmer",
    period: "April 2024 - September 2024 (6 bulan)",
    periodEn: "April 2024 - September 2024 (6 months)",
    location: "Surabaya, Jawa Timur, Indonesia",
    locationEn: "Surabaya, East Java, Indonesia",
    type: "Contract / Professional",
    typeEn: "Contract / Professional",
    description: "Mengerjakan pengembangan fitur dan pemeliharaan aplikasi sesuai kebutuhan pengguna.",
    descriptionEn: "Worked on application features and maintenance based on user needs.",
    responsibilities: [
      "Menerjemahkan spesifikasi kebutuhan menjadi fitur aplikasi.",
      "Menelusuri bug dan memperbaiki kode serta alur program.",
      "Mengikuti koordinasi tim teknis untuk menyelesaikan pekerjaan sprint."
    ],
    responsibilitiesEn: [
      "Turned user requirements and specifications into application features.",
      "Debugged issues and maintained code and program workflows.",
      "Coordinated with the technical team to complete sprint work."
    ]
  },
  {
    company: "Radya Labs Teknologi",
    position: "Associate Mobile Developer",
    period: "Januari 2023 - Juni 2023 (6 bulan)",
    periodEn: "January 2023 - June 2023 (6 months)",
    location: "Bandung, Jawa Barat, Indonesia",
    locationEn: "Bandung, West Java, Indonesia",
    type: "Internship / Associate",
    typeEn: "Internship / Associate",
    description: "Mendukung pengembangan aplikasi mobile Flutter sebagai bagian dari tim mobile.",
    descriptionEn: "Supported Flutter mobile application development as part of the mobile team.",
    responsibilities: [
      "Membangun komponen antarmuka mobile menggunakan Flutter.",
      "Menyelesaikan task pengembangan dengan arahan engineer senior.",
      "Berpartisipasi dalam daily stand-up dan sprint tim Agile."
    ],
    responsibilitiesEn: [
      "Built mobile interface components with Flutter.",
      "Completed development tasks under guidance from senior engineers.",
      "Participated in daily stand-ups and Agile team sprints."
    ]
  },
  {
    company: "Seven Inc.",
    position: "Programmer (Internship BS CI)",
    period: "Juli 2021 - Oktober 2021 (4 bulan)",
    periodEn: "July 2021 - October 2021 (4 months)",
    location: "Bantul, D.I. Yogyakarta",
    locationEn: "Bantul, D.I. Yogyakarta, Indonesia",
    type: "Internship",
    typeEn: "Internship",
    description: "Magang pemrograman dengan fokus pada pengembangan web menggunakan Laravel.",
    descriptionEn: "Programming internship focused on web development with Laravel.",
    responsibilities: [
      "Mengimplementasikan fitur web dan backend menggunakan Laravel dan PHP.",
      "Mengerjakan modul sesuai spesifikasi dan pembagian tugas proyek.",
      "Menggunakan Git untuk mengelola perubahan kode bersama tim."
    ],
    responsibilitiesEn: [
      "Implemented web and backend features with Laravel and PHP.",
      "Delivered modules based on project specifications and assigned tasks.",
      "Used Git to manage code changes with the team."
    ]
  }
];

export const experienceData: WorkExperience[] = localizedExperienceData;

export const educationData: Education[] = [
  {
    institution: "CODE.ID",
    degree: "Bootcamp Intensive",
    degreeEn: "Intensive Bootcamp",
    major: "Flutter Mobile Developer",
    majorEn: "Flutter Mobile Developer",
    graduationYear: "2023"
  },
  {
    institution: "STMIK PPKIA Pradnya Paramita Malang",
    degree: "Associate's Degree (D3)",
    degreeEn: "Associate Degree (D3)",
    major: "Manajemen Sistem Informasi",
    majorEn: "Information Systems Management",
    graduationYear: "2019 - 2022"
  }
];
