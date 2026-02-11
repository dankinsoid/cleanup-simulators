cask "cleanup-simulators" do
  version "0.0.1"
  sha256 "897a9661bf784f01516033110428d2a849f068d9ae835cbbf307308d8b240c02"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
