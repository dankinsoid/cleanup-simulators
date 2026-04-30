cask "cleanup-simulators" do
  version "1.0.4"
  sha256 "e6e8052e009e9401bb779169206536dae61f2d2dddcc84a8e148e1cb6bf11c8e"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
