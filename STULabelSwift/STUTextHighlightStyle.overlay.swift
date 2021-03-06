// Copyright 2018 Stephan Tolksdorf

@_exported import STULabel

public extension STUTextHighlightStyle {

@inlinable
public convenience init(_ configure: (STUTextHighlightStyleBuilder) -> Void) {
  self.init(__block:configure)
}

}
