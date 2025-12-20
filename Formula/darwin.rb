# typed: false
# frozen_string_literal: true

class Darwin < Formula
  desc "Git-aware visual regression testing and development timelapse for iOS"
  homepage "https://github.com/dontoisme/darwin"
  url "https://github.com/dontoisme/darwin/archive/refs/tags/v1.4.1.tar.gz"
  sha256 "705221258fd70dd51740a8a439f3792ada3d04728f9a10876741d7fd1ec28e99"
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
    bin.install "bin/darwin-viewer"
    bin.install "bin/darwin-status"
    bin.install "bin/darwin-hook"
    bin.install "bin/darwin-map"
    bin.install "bin/darwin-manifest"
    bin.install "bin/darwin-detect"
    bin.install "bin/darwin-ai-rules"
    bin.install "bin/darwin-export"
    bin.install "bin/darwin-parse"

    # Install lib
    (libexec/"lib").install Dir["lib/*"]

    # Install templates
    (share/"darwin/templates").install Dir["templates/*"]

    # Update scripts to find lib relative to libexec
    inreplace bin/"darwin-capture", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-diff", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-viewer", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-status", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-hook", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-manifest", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-detect", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-export", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-parse", 'LIB_DIR="$SCRIPT_DIR/../lib"', "LIB_DIR=\"#{libexec}/lib\""
    inreplace bin/"darwin-init", 'TEMPLATES_DIR="$SCRIPT_DIR/../templates"', "TEMPLATES_DIR=\"#{share}/darwin/templates\""
    inreplace bin/"darwin-ai-rules", 'TEMPLATES_DIR="$SCRIPT_DIR/../templates/ai-rules"', "TEMPLATES_DIR=\"#{share}/darwin/templates/ai-rules\""
  end

  def caveats
    <<~EOS
      Darwin has been installed!

      Quick start:
        cd /path/to/your/ios/project
        darwin init
        darwin capture --baseline
        darwin viewer

      For pixel-level diffs, install ImageMagick:
        brew install imagemagick

      Documentation: https://github.com/dontoisme/darwin
    EOS
  end

  test do
    assert_match "darwin", shell_output("#{bin}/darwin version")
  end
end
