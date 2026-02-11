cask "cleanup-simulators" do
  version "1.0.2"
  sha256 "28c2ffcebd78adb378c7bfd14ffd78fe01e5d3940340fdb27795fb4665872a05"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
