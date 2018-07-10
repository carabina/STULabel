
// Copyright 2018 Stephan Tolksdorf

public func styleName(fontName: String) -> String {
  guard let i = fontName.index(of: "-") else {
    if fontName.hasPrefix("Damascus") {    
      return fontName == "Damascus" ? "Regular"
           : String(fontName.dropFirst(8))
    }
    return "Regular"
  }
  return String(fontName[fontName.index(after: i)...])
}

private func italicFontName(fontName: String) -> String {
  return fontName + (fontName.index(of: "-") != nil ? "Italic" : "-Italic")
}

private let uiFontWeights: [UIFont.Weight] = [
  .ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black
]

private let sfTextRegularFontNames =
  Array(Set(uiFontWeights.map { UIFont.systemFont(ofSize: 16, weight: $0).fontName }))

private let sfDisplayRegularFontNames =
  Array(Set(uiFontWeights.map { UIFont.systemFont(ofSize: 24, weight: $0).fontName }))


private let sfTextFontNames = sfTextRegularFontNames
                    + sfTextRegularFontNames.map { italicFontName(fontName: $0) }

private let sfDisplayFontNames = sfDisplayRegularFontNames
                       + sfDisplayRegularFontNames.map { italicFontName(fontName: $0) }

private let lowercaseFontWeightNames = [
  "ultralight", "thin", "light", "book", "regular", "medium", "demibold", "semibold", "bold", "extrabold", "heavy", "black"
]

private func fontSortOrder(f1: String, f2: String) -> Bool {
  var s1 = styleName(fontName: f1).lowercased()
  var s2 = styleName(fontName: f2).lowercased()

  func stripMT(_ s: inout String) {
    if s.hasSuffix("mt") {
      s = String(s.dropLast(2))
    }
  }
  func stripRoman(_ s: inout String) {
    if s.hasPrefix("roman") {
      s = String(s.dropFirst(5))
    }
  }

  func stripCondensed(_ s: inout String) -> Bool {
    let isCondensed = s.hasPrefix("condensed")
    guard isCondensed else { return false }
    s = String(s.dropFirst(9))
    return true
  }

  func stripItalic(_ s: inout String) -> Bool {
    if s.hasSuffix("italic") {
      s = String(s.dropLast(6))
      return true
    }
    if s.hasSuffix("it") {
      s = String(s.dropLast(2))
      return true
    }
    if s.hasSuffix("ita") {
      s = String(s.dropLast(2))
      return true
    }
    if s.hasSuffix("oblique") {
      s = String(s.dropLast(7))
      return true
    }
    return false
  }

  stripRoman(&s1)
  stripRoman(&s2)

  stripMT(&s1)
  stripMT(&s2)

  let isItalic1 = stripItalic(&s1)
  let isItalic2 = stripItalic(&s2)

  let isCondensed1 = stripCondensed(&s1)
  let isCondensed2 = stripCondensed(&s2)

  if s1.isEmpty {
    s1 = "regular"
  }
  if s2.isEmpty {
    s2 = "regular"
  }

  switch (lowercaseFontWeightNames.index(of: s1), lowercaseFontWeightNames.index(of: s2)) {
   case let (index1?, index2?):
     return isCondensed1 != isCondensed2 ? isCondensed1
          : index1 < index2
            || (index1 == index2 && !isItalic1 && isItalic2)
   case (_?, nil): return true
   case (nil, _?): return false
   case (nil, nil): return s1 < s2
  }
}

public typealias FontFamilyArray =
  [(familyName: String, styles: [(fontName: String, styleName: String)])]

private func getFontFamliesAndFonts() -> FontFamilyArray {
  let sfFonts: FontFamilyArray = [
    (".SF UI Text",
     sfTextFontNames.sorted(by: fontSortOrder).map { ($0, styleName(fontName: $0)) }),
    (".SF UI Display",
     sfDisplayFontNames.sorted(by: fontSortOrder).map { ($0, styleName(fontName: $0)) })
  ]
  let otherFonts: FontFamilyArray =
    UIFont.familyNames.sorted().map { familyName in
      (familyName,
       UIFont.fontNames(forFamilyName: familyName)
             .sorted(by: fontSortOrder).map { ($0, styleName(fontName: $0)) })
    }.filter { !$0.1.isEmpty }
  var styles = Set<String>()
  for f in otherFonts {
    for s in f.1 {
      styles.insert(s.styleName)
    }
  }
  print(styles)
  return sfFonts + otherFonts
}


let fontFamilies: FontFamilyArray = getFontFamliesAndFonts()