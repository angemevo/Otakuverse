# create_structure.ps1

# Créer les dossiers principaux
$folders = @(
    "lib\config",
    "lib\core\constants",
    "lib\core\utils",
    "lib\core\widgets",
    "lib\models",
    "lib\controllers",
    "lib\services",
    "lib\views\auth",
    "lib\views\home",
    "lib\views\profile",
    "lib\views\posts",
    "lib\views\shorts",
    "lib\views\communities",
    "lib\views\events",
    "lib\bindings"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder
    Write-Host "✅ Créé: $folder" -ForegroundColor Green
}

Write-Host "`n🎉 Structure créée avec succès!" -ForegroundColor Cyan