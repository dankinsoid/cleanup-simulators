cask "cleanup-simulators" do
  version "1.0.5"
  sha256 "524d1e4e1f8c6072beae43a2aa6f2ba84cf2a22906341c7da8a92c8e302d5b5d"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
