# typed: false
# frozen_string_literal: true

class Darwin < Formula
  desc "Git-aware visual regression testing and development timelapse for iOS"
  homepage "https://github.com/dontoisme/darwin"
  url "https://github.com/dontoisme/darwin/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"
  head "https://github.com/dontoisme/darwin.git", branch: "main"

  depends_on "jq"
  depends_on :macos

  def install
    # Install bin scripts
    bin.install "bin/darwin"
    bin.install "bin/darwin-init"
    bin.install "bin/darwin-capture"
    bin.install "bin/darwin-diff"

    # Install lib
    (libexec/"lib").install Dir["lib/*"]

    # Install templates
    (share/"darwin/templates").install Dir["templates/*"]

    # Update scripts to find lib relative to libexec
    inreplace bin/"darwin-capture", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-diff", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-init", 'TEMPLATES_DIR="$SCRIPT_DIR/../templates"', "TEMPLATES_DIR=\"#{share}/darwin/templates\""
  end

  def caveats
    <<~EOS
      Darwin has been installed!

      Quick start:
        cd /path/to/your/ios/project
        darwin init
        darwin capture --baseline

      For pixel-level diffs, install ImageMagick:
        brew install imagemagick

      Documentation: https://github.com/dontoisme/darwin
    EOS
  end

  test do
    assert_match "darwin", shell_output("#{bin}/darwin version")
  end
end
