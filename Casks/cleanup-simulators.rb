cask "cleanup-simulators" do
  version "1.0.0"
  sha256 "0e2fe11f9e39aea44cf4a7005fd3189f3062fb65876908403c876d6b4e2eaa7c"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
