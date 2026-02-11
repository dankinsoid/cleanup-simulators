cask "cleanup-simulators" do
  version "1.0.1"
  sha256 "cd6b1807472d32940c3b06e4c27dcc5c2ca93eeb08cf72a607f7845d64190a12"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
