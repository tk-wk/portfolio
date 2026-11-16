#!/usr/bin/env bash
# Turns the Blazor site into plain files for GitHub Pages, which can't run ASP.NET.
# It publishes the app, runs it for a moment, saves the HTML and the stylesheets it links to, then stops it.
#
#   bash scripts/export-static.sh [output folder] [base path]
#
# The base path is where the site lives on the host: "/portfolio/" for tk-wk.github.io/portfolio/.
set -euo pipefail

out="${1:-_site}"
base="${2:-/}"
port=5099
url="http://localhost:$port"

dotnet publish Portfolio -c Release -o publish --nologo -v quiet

(cd publish && exec dotnet Portfolio.dll --urls "$url") &
server=$!
trap 'kill "$server" 2>/dev/null || true' EXIT

for _ in $(seq 60); do
    curl -sf "$url/" -o /dev/null && break
    sleep 1
done

rm -rf "$out"
mkdir -p "$out"

# Anything you put in wwwroot (a CV, images, fonts), without the compressed copies publish makes
# and without Blazor's own scripts in _framework, which the page doesn't load.
(cd publish/wwwroot && find . -path ./_framework -prune -o -type f ! -name '*.gz' ! -name '*.br' -exec cp --parents {} "../../$out/" \;)

curl -sf "$url/" -o "$out/index.html"
curl -s "$url/not-found" -o "$out/404.html"   # answers 404 on purpose, so no -f

# Every stylesheet the page links to (their names carry a content hash, so save them as they are).
grep -oh 'href="[^"]*\.css"' "$out/index.html" "$out/404.html" | sort -u | sed 's/^href="//; s/"$//' |
while read -r path; do
    mkdir -p "$out/$(dirname "$path")"
    curl -sf "$url/$path" -o "$out/$path"
done

sed -i "s|<base href=\"/\"[^>]*>|<base href=\"$base\">|" "$out/index.html" "$out/404.html"
grep -q "<base href=\"$base\">" "$out/index.html" || { echo "Couldn't set the base path in index.html" >&2; exit 1; }
touch "$out/.nojekyll"   # serve the files as they are, without GitHub's Jekyll step

echo "Exported to $out:"
find "$out" -type f | sort
