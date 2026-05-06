import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/Fusion.jl/dev/', // TODO: replace this in makedocs!
  title: 'Fusion',
  description: 'Documentation for Fusion.jl',
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../1', // This is required for MarkdownVitepress to work correctly...
  head: [['link', { rel: 'icon', href: '/Fusion.jl/dev/favicon.ico' }]],
  ignoreDeadLinks: true,

  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
        md.use(mathjax3),
        md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"
    }
  },
  themeConfig: {
    outline: 'deep',
    logo: { src: '/logo.png', width: 24, height: 24},
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav: [
{ text: 'Home', link: '/index' },
{ text: 'Colliding Beam Fusion', link: '/colliding_beam_fusion' },
{ text: 'Appendices', collapsed: false, items: [
{ text: 'Nuclear Fusion in a Nutshell', link: '/nuclear_fusion_nutshell' }]
 }
]
,
    sidebar: [
{ text: 'Home', link: '/index' },
{ text: 'Colliding Beam Fusion', link: '/colliding_beam_fusion' },
{ text: 'Appendices', collapsed: false, items: [
{ text: 'Nuclear Fusion in a Nutshell', link: '/nuclear_fusion_nutshell' }]
 }
]
,
    editLink: { pattern: "https://github.com/brian-dellabetta/Fusion.jl/edit/main/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/brian-dellabetta/Fusion.jl' }
    ],
    footer: {
      message: 'Made with <a href="https://luxdl.github.io/DocumenterVitepress.jl/dev/" target="_blank"><strong>DocumenterVitepress.jl</strong></a><br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()}.`
    }
  }
})
