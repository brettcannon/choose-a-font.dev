pub type URL =
  String

pub type Font {
  Font(family: String, homepage: URL)
}

pub const fonts: List(Font) = [
  Font(
    "Anonymous Pro",
    "https://www.marksimonson.com/fonts/view/anonymous-pro/",
  ),
  Font("B612 Mono", "https://github.com/polarsys/b612"),
  Font("Fira Code", "https://github.com/tonsky/FiraCode"),
  Font("IBM Plex Mono", "https://www.ibm.com/plex/"),
  Font("Inconsolata", "https://levien.com/type/myfonts/inconsolata.html"),
  Font("JetBrains Mono", "https://www.jetbrains.com/lp/mono/"),
  Font("Noto Sans Mono", "https://notofonts.github.io"),
  Font("Red Hat Mono", "https://github.com/RedHatOfficial/RedHatFont"),
  Font("Roboto Mono", "https://github.com/googlefonts/robotomono"),
  Font("Source Code Pro", "https://adobe-fonts.github.io/source-code-pro/"),
  Font("Ubuntu Sans Mono", "https://design.ubuntu.com/font"),
]
