# Portfolio

A one-page portfolio site built with ASP.NET Core and static server-rendered Blazor (.NET 10).
The browser receives plain HTML and CSS: no JavaScript, no animations.

## Run

Open `Portfolio.sln` in Visual Studio and press F5, or:

```
dotnet run --project Portfolio
```

## Where things are

- `Portfolio/Components/Pages/Home.razor`: the page content and the project list.
- `Portfolio/wwwroot/app.css`: all styling. Colors and the background band width are at the top.

## Hosting

Every push to `main` publishes the site to GitHub Pages at https://tk-wk.github.io/portfolio/.
GitHub Pages can't run ASP.NET, so `.github/workflows/pages.yml` runs `scripts/export-static.sh`,
which starts the app for a moment and saves the page and its files as plain HTML and CSS.
To try the export yourself: `bash scripts/export-static.sh _site /portfolio/`.
