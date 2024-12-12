import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Arch Wiki",
  description: "A simple Arch Linux installation guide",
  base: "/Arch-Wiki/",
  lastUpdated: true,

  head: [
        ["link", { rel: "icon", href: "/Arch-Wiki/archx.png" }],
    ],

  themeConfig: {
    siteTitle: "Arch Wiki",
    logo: "/archx.webp",
    outline: "deep",
    docsDir: "docs",
    editLink: {
      pattern: "https://github.com/Justus0405/arch-wiki/tree/main/docs/:path",
      text: "Edit this page on GitHub",
    },
    nav: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/getting-started/introduction" },
      { 
        text: "Resources",
        items: [
          { text: "Download Arch Linux", link: "https://archlinux.org/download/" },
          { text: "Arch Wiki", link: "https://wiki.archlinux.org/" },
        ],
      },
    ],
    sidebar: [
      {
        text: 'Getting Started',
        collapsible: true,
        collapsed: false,
        items: [
          { text: 'Introduction', link: '/getting-started/introduction' },
        ]
      },
      {
        text: 'Installation',
        collapsible: true,
        collapsed: false,
        items: [
          { text: 'Base Install', link: '/installation/baseinstall.md' },
          { text: 'Post-Install Configuration', link: '/installation/post-installation.md' },
          { text: 'Bootloader Setup', link: '/installation/grubinstall.md' }
        ]
      },
      {
        text: 'Package Management',
        collapsible: true,
        collapsed: false,
        items: [
          { text: 'Pacman', link: '/pacman/pacman.md' },
          { text: 'Mirror list', link: '/pacman/mirrorlist.md' }
        ]
      },
      { 
        text: 'Sound',
        collapsible: true,
        collapsed: false,
        items: [
        { text: 'PipeWire', link: '/sound/pipewire.md' },
        ]
      },
      {
        text: 'Desktop',
        collapsible: true,
        collapsed: false,
        items: [
        { text: 'Gnome Installation', link: '/desktop/desktopenv.md' },
        ]
      },
      {
        text: 'Graphic Setup',
        collapsible: true,
        collapsed: false,
        items: [
        { text: 'Nvidia', link: '/nvidia/installnvidia.md' },
        { text: 'Deprecated Method', link: '/nvidia/deprecated.md' },
        ]
      },
      {
        text: 'Essential',
        collapsible: true,
        collapsed: false,
        items: [
        { text: 'Ntp Setup', link: '/essential/ntp.md' },
        ]
      },
      {
        text: 'Laptop',
        collapsible: true,
        collapsed: false,
        items: [
        { text: 'Battery Optimization', link: '/laptop/batteryopt.md' },
        ]
      },
    ],

    socialLinks: [
      { icon: "github", link: "https://github.com/Justus0405" },
      { icon: "discord", link: "https://discord.com/invite/E2Bp7GtcaA" },
    ],
    footer: {
      message: "Released under the MIT License.",
      copyright: "Copyright © 2024 Justus0405",
    },
    search: {
      provider: "local",
    },
    returnToTopLabel: 'Go to Top',
    sidebarMenuLabel: 'Menu',
  },
});

