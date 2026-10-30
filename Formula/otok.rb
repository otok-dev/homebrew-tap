# Otok (c) Alexander A Pototskiy
# SPDX-License-Identifier: GPL-3.0-only
#
# Builds otok from its source repository against Homebrew's packages. Lua is part of otok's sources and compiled
# as C++; Homebrew's lua is the C build. The dataforge submodule comes with the git checkout.
class Otok < Formula
  desc "Build native libraries from source and hand them to your build"
  homepage "https://git.e-poison.com/sasha/otok"
  url "https://git.e-poison.com/sasha/otok.git",
      tag:      "v0.1.35",
      revision: "4ccd8984fd15fb44c3afaae500d9a9ef7be61122"
  license "GPL-3.0-only"
  head "https://git.e-poison.com/sasha/otok.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "inja" => :build
  depends_on "nlohmann-json" => :build
  depends_on "libarchive"
  depends_on "tomlplusplus"

  uses_from_macos "curl"

  def install
    args = %W[
      -DOTOK_BUILD_TESTS=OFF
      -DOTOK_REVISION=#{version}
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    bin.install "build/otok"
  end

  test do
    assert_match "otok", shell_output("#{bin}/otok --version")

    # a project without dependencies resolves and locks offline
    (testpath/"otok.toml").write <<~TOML
      [otok]
      format = 1

      [native]
      platforms = ["native"]
    TOML
    system bin/"otok", "install", "--offline"
    assert_path_exists testpath/"otok.lock"
  end
end
