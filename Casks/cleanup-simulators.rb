cask "cleanup-simulators" do
  version "0.0.2"
  sha256 "0d8208c3d9cec9f94a78cfad3dfcb08f4c1f3d5efda574cfc1a572edfc877ee4"

  url "https://github.com/dankinsoid/cleanup-simulators/releases/download/v#{version}/CleanupSimulators.dmg"
  name "CleanupSimulators"
  desc "Clean up Xcode simulators"
  homepage "https://github.com/dankinsoid/cleanup-simulators"

  depends_on macos: ">= :sonoma"

  app "CleanupSimulators.app"
end
