cask "yourpcstats" do
  version "1.0.0"
  sha256 "08999a2254e60e68be27e7b4dbb3828b88bcd7f66264c9659e58e494baca4b63"

  url "https://github.com/REPLACE_WITH_YOUR_GITHUB_USERNAME/YourPcStats/releases/download/v#{version}/YourPcStats-#{version}.dmg"
  name "YourPcStats"
  desc "Vintage car dashboard PC telemetry menu bar application"
  homepage "https://github.com/REPLACE_WITH_YOUR_GITHUB_USERNAME/YourPcStats"

  depends_on macos: ">= :sonoma"

  app "YourPcStats.app"

  zap trash: [
    "~/Library/Preferences/Personal.YourPcStats.plist",
    "~/Library/Application Support/YourPcStats",
  ]
end
