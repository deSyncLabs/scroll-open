import { themes as prismThemes } from "prism-react-renderer";
import type { Config } from "@docusaurus/types";
import type * as Preset from "@docusaurus/preset-classic";

const config: Config = {
    title: "deSync Docs",
    tagline: "Understand how deSync generates the best yield for your assets",
    favicon: "img/favicon.ico",

    url: "https://docs.desync.fi",
    baseUrl: "/",
    organizationName: "deSync Labs",
    projectName: "docs",

    onBrokenLinks: "throw",
    onBrokenMarkdownLinks: "warn",

    i18n: {
        defaultLocale: "en",
        locales: ["en"],
    },

    presets: [
        [
            "classic",
            {
                docs: {
                    sidebarPath: "./sidebars.ts",
                    routeBasePath: "/",
                },
                blog: false,
                theme: {
                    customCss: "./src/css/custom.css",
                },
            } satisfies Preset.Options,
        ],
    ],

    themeConfig: {
        colorMode: {
            defaultMode: "dark",
            disableSwitch: true,
            respectPrefersColorScheme: false,
        },
        navbar: {
            title: "deSync Docs",
            items: [
                {
                    href: "https://desync.fi/",
                    label: "Home",
                    position: "right",
                },
                // {
                //     href: "https://github.com/deSyncLabs/scroll-open/",
                //     label: "Testnet",
                //     position: "right",
                // },
                {
                    href: "https://github.com/deSyncLabs/scroll-open/",
                    label: "GitHub",
                    position: "right",
                },
            ],
        },
        footer: {
            style: "light",
            links: [
                {
                    label: "Home",
                    href: "https://desync.fi/",
                },
                // {
                //     href: "https://github.com/deSyncLabs/scroll-open/",
                //     label: "Testnet",
                //     position: "right",
                // },
                {
                    label: "GitHub",
                    href: "https://github.com/deSyncLabs/scroll-open/",
                },
            ],
            copyright: `© ${new Date().getFullYear()} deSync Labs`,
        },
        prism: {
            theme: prismThemes.github,
            darkTheme: prismThemes.dracula,
        },
    } satisfies Preset.ThemeConfig,
};

export default config;
