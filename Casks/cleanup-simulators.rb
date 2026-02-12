cask "cleanup-simulators" do
  version "1.0.3"
  sha256 "0757d25fc5dabe86667a3395f3a3d8196a5771aa74fad64719f6337e64dd32b0"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
